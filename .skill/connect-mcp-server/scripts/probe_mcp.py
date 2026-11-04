#!/usr/bin/env python3
"""Check that an MCP server starts and answers: initialize, then tools/list.

Usage:
  probe_mcp.py [--env KEY=VALUE ...] -- <command> [args...]       stdio server
  probe_mcp.py [--header "Name: value"] [--bearer-env VAR] <url>   Streamable HTTP server

Exit codes: 0 = server answered and listed its tools, 3 = server requires authentication,
1 = anything else failed, 2 = bad arguments. Standard library only.
"""
import argparse
import collections
import json
import os
import queue
import shutil
import subprocess
import sys
import threading
import time
import urllib.error
import urllib.request

PROTOCOL_VERSION = "2025-06-18"
CLIENT_INFO = {"name": "probe-mcp", "version": "1.0"}


class ProbeError(Exception):
    pass


class AuthRequired(Exception):
    pass


def initialize_msg():
    return {
        "jsonrpc": "2.0",
        "id": 1,
        "method": "initialize",
        "params": {"protocolVersion": PROTOCOL_VERSION, "capabilities": {}, "clientInfo": CLIENT_INFO},
    }


INITIALIZED = {"jsonrpc": "2.0", "method": "notifications/initialized"}
LIST_TOOLS = {"jsonrpc": "2.0", "id": 2, "method": "tools/list", "params": {}}


def result_of(msg, what):
    if "error" in msg:
        err = msg["error"]
        raise ProbeError(f"{what} returned error {err.get('code')}: {err.get('message')}")
    if "result" not in msg:
        raise ProbeError(f"{what} reply has no result: {json.dumps(msg)[:300]}")
    return msg["result"]


# ---------- stdio ----------

def probe_stdio(cmd, env_pairs, timeout):
    env = dict(os.environ)
    env.update(env_pairs)
    exe = shutil.which(cmd[0], path=env.get("PATH")) or cmd[0]
    try:
        proc = subprocess.Popen(
            [exe] + cmd[1:],
            stdin=subprocess.PIPE,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            env=env,
            text=True,
            encoding="utf-8",
            errors="replace",
            bufsize=1,
        )
    except FileNotFoundError:
        raise ProbeError(f"command not found: {cmd[0]} (not on PATH; try an absolute path)")

    stdout_lines = queue.Queue()
    stderr_tail = collections.deque(maxlen=25)

    def pump_stdout():
        for line in proc.stdout:
            stdout_lines.put(line)
        stdout_lines.put(None)

    def pump_stderr():
        for line in proc.stderr:
            stderr_tail.append(line.rstrip("\n"))

    threading.Thread(target=pump_stdout, daemon=True).start()
    threading.Thread(target=pump_stderr, daemon=True).start()

    def send(msg):
        try:
            proc.stdin.write(json.dumps(msg) + "\n")
            proc.stdin.flush()
        except (BrokenPipeError, OSError):
            raise ProbeError("server closed its input (it exited)")

    def wait_for(msg_id, what):
        deadline = time.monotonic() + timeout
        while True:
            remaining = deadline - time.monotonic()
            if remaining <= 0:
                raise ProbeError(f"no reply to {what} within {timeout:g}s")
            try:
                line = stdout_lines.get(timeout=remaining)
            except queue.Empty:
                continue
            if line is None:
                time.sleep(0.2)  # let stderr drain
                raise ProbeError(f"server exited (code {proc.poll()}) before answering {what}")
            line = line.strip()
            if not line:
                continue
            try:
                msg = json.loads(line)
            except ValueError:
                print(f"warning: non-JSON line on stdout (stdio servers must log to stderr): {line[:200]}",
                      file=sys.stderr)
                continue
            if isinstance(msg, dict) and msg.get("id") == msg_id and "method" not in msg:
                return msg

    try:
        send(initialize_msg())
        init = result_of(wait_for(1, "initialize"), "initialize")
        send(INITIALIZED)
        send(LIST_TOOLS)
        tools = result_of(wait_for(2, "tools/list"), "tools/list")
        return init, tools
    except ProbeError as e:
        if stderr_tail:
            e.args = (e.args[0] + "\n--- server stderr (last lines) ---\n" + "\n".join(stderr_tail),)
        raise
    finally:
        if proc.poll() is None:
            proc.terminate()
            try:
                proc.wait(timeout=5)
            except subprocess.TimeoutExpired:
                proc.kill()


# ---------- Streamable HTTP ----------

def iter_sse_data(resp):
    data = []
    for raw in resp:
        line = raw.decode("utf-8", "replace").rstrip("\r\n")
        if not line:
            if data:
                yield "\n".join(data)
                data = []
        elif line.startswith("data:"):
            value = line[5:]
            data.append(value[1:] if value.startswith(" ") else value)
    if data:
        yield "\n".join(data)


def http_post(url, headers, msg, session_id, protocol_version, timeout):
    # Python's default User-Agent is blocked by some CDNs' bot protection
    h = {
        "Content-Type": "application/json",
        "Accept": "application/json, text/event-stream",
        "User-Agent": f"{CLIENT_INFO['name']}/{CLIENT_INFO['version']}",
    }
    h.update(headers)
    if session_id:
        h["Mcp-Session-Id"] = session_id
    if protocol_version:
        h["MCP-Protocol-Version"] = protocol_version
    req = urllib.request.Request(url, data=json.dumps(msg).encode(), headers=h, method="POST")
    try:
        resp = urllib.request.urlopen(req, timeout=timeout)
    except urllib.error.HTTPError as e:
        body = " ".join(e.read(300).decode("utf-8", "replace").split())
        challenge = e.headers.get("WWW-Authenticate", "")
        # 401 is the MCP auth signal; a 403 counts only with a challenge (otherwise it's a block/forbidden)
        if e.code == 401 or (e.code == 403 and challenge):
            raise AuthRequired(f"HTTP {e.code}{' — ' + challenge if challenge else ''}{(': ' + body) if body else ''}")
        if e.code in (404, 405):
            raise ProbeError(f"HTTP {e.code} from {url} — wrong path, or an SSE-only server "
                             f"(try its /sse URL with the client's sse transport). {body}")
        raise ProbeError(f"HTTP {e.code}: {body}")
    except urllib.error.URLError as e:
        raise ProbeError(f"cannot reach {url}: {e.reason}")

    with resp:
        session_id = resp.headers.get("Mcp-Session-Id") or session_id
        if "id" not in msg:
            return None, session_id
        ctype = resp.headers.get("Content-Type", "")
        if "text/event-stream" in ctype:
            for data in iter_sse_data(resp):
                try:
                    reply = json.loads(data)
                except ValueError:
                    continue
                if isinstance(reply, dict) and reply.get("id") == msg["id"] and "method" not in reply:
                    return reply, session_id
            raise ProbeError(f"event stream ended without a reply to {msg['method']}")
        body = resp.read()
        try:
            return json.loads(body), session_id
        except ValueError:
            raise ProbeError(f"reply to {msg['method']} is not JSON ({ctype}): {body[:200]!r}")


def probe_http(url, headers, timeout):
    reply, sid = http_post(url, headers, initialize_msg(), None, None, timeout)
    init = result_of(reply, "initialize")
    version = init.get("protocolVersion", PROTOCOL_VERSION)
    http_post(url, headers, INITIALIZED, sid, version, timeout)
    reply, sid = http_post(url, headers, LIST_TOOLS, sid, version, timeout)
    return init, result_of(reply, "tools/list")


# ---------- main ----------

def main():
    argv = sys.argv[1:]
    command = None
    if "--" in argv:
        i = argv.index("--")
        argv, command = argv[:i], argv[i + 1:]

    parser = argparse.ArgumentParser(
        description="Check that an MCP server starts and lists its tools.",
        usage="%(prog)s [--env KEY=VALUE] -- <command> [args...]\n"
              "       %(prog)s [--header 'Name: value'] [--bearer-env VAR] <url>",
    )
    parser.add_argument("url", nargs="?", help="Streamable HTTP endpoint")
    parser.add_argument("--env", action="append", default=[], metavar="KEY=VALUE",
                        help="extra environment variable for a stdio server (repeatable)")
    parser.add_argument("--header", action="append", default=[], metavar="'Name: value'",
                        help="extra HTTP header (repeatable)")
    parser.add_argument("--bearer-env", metavar="VAR",
                        help="send 'Authorization: Bearer $VAR' without putting the token on the command line")
    parser.add_argument("--timeout", type=float, default=90,
                        help="seconds to wait for each reply (default 90; first npx/uvx runs download packages)")
    args = parser.parse_args(argv)

    if bool(command) == bool(args.url):
        parser.error("give either a URL, or -- followed by the server's command")

    try:
        if command:
            env_pairs = {}
            for pair in args.env:
                key, sep, value = pair.partition("=")
                if not sep or not key:
                    parser.error(f"--env expects KEY=VALUE, got {pair!r}")
                env_pairs[key] = value
            init, tools = probe_stdio(command, env_pairs, args.timeout)
        else:
            headers = {}
            for h in args.header:
                name, sep, value = h.partition(":")
                if not sep:
                    parser.error(f"--header expects 'Name: value', got {h!r}")
                headers[name.strip()] = value.strip()
            if args.bearer_env:
                token = os.environ.get(args.bearer_env)
                if not token:
                    parser.error(f"environment variable {args.bearer_env} is not set")
                headers["Authorization"] = f"Bearer {token}"
            init, tools = probe_http(args.url, headers, args.timeout)
    except AuthRequired as e:
        print(f"AUTH REQUIRED: {e}")
        print("The server is reachable but needs credentials. For OAuth servers this is expected: "
              "save the config, then log in through the client.")
        return 3
    except ProbeError as e:
        print(f"FAILED: {e}")
        return 1

    info = init.get("serverInfo", {})
    names = [t.get("name", "?") for t in tools.get("tools", [])]
    print(f"OK: {info.get('name', '?')} {info.get('version', '')} (protocol {init.get('protocolVersion', '?')})")
    print(f"{len(names)} tools: " + (", ".join(names[:40]) + (" …" if len(names) > 40 else "") if names else "(none)"))
    if tools.get("nextCursor"):
        print("(more tools on further pages)")
    return 0


if __name__ == "__main__":
    sys.exit(main())
