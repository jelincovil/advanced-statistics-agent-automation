---
name: connect-mcp-server
description: "Connect an MCP server in Open Math OS or configure one in Claude Code, Codex CLI, Gemini CLI, Cursor, VS Code or Claude Desktop. Use when the user wants to connect, configure, persist, debug or remove an MCP server."
---

# Connect an MCP server

## Open Math OS

When `mcp_connect` is available, use it directly for Streamable HTTP:

```json
{"name":"example","url":"https://example.com/mcp","tools":["search","fetch"]}
```

Replace the URL and tool names with those documented by the server. Use existing
connected tools when available. The result names the callable tools and their
environment; use those schemas for subsequent calls. No `plugin_capabilities`,
adapter path, endpoint identifier or plugin development guide is needed.

Connections last for the current agent. An identical connection request reuses
the running adapter; `plugin_stop` with its name disconnects it. This does not
persist a server configuration across agents. If persistence is requested,
explain this limitation. Authentication and legacy SSE are not supported by
this entry point. If `mcp_connect` is absent in Open Math OS, report the missing
tool; the runtime or the agent's access may need updating. Stop here rather than
applying another client's configuration below.

## Other clients: persistent configuration

Done means: the server is saved in the client's own config file, it survives a restart, and it
actually connects. Writing the config is only half the job — always verify.

## 1. Pin down the server

Collect these before touching any config:

- **Name** — short, lowercase, hyphens only (`github`, `postgres-prod`). Underscores and other
  characters break some clients.
- **Transport**
  - *stdio*: the client launches a local process — `npx -y <pkg>`, `uvx <pkg>`,
    `docker run -i --rm <image>`, or a binary.
  - *Streamable HTTP*: a remote URL, usually ending in `/mcp`.
  - *SSE*: legacy remote URL ending in `/sse`. Use only if the server offers nothing else.
- **Credentials** — env vars the server reads, an `Authorization` header, or OAuth (the client
  runs a browser login after the server is added).
- **Scope** — see step 2.

If the user gave only a name or a link, read the server's README for the exact command, env vars
and auth method. Never guess a package name: a near-miss npm/PyPI name can be someone else's code,
and an MCP server runs with the user's full permissions. If the publisher isn't clearly the
service's official one or a source the user trusts, say so before installing.

## 2. Choose where it persists

| The user wants | Scope | Lives in |
|---|---|---|
| It in every project (default when they just say "keep it" / "persist it") | user | client's user-level config |
| It shared with the team for one repo | project | project config file, committed to git |
| It for one repo, only for themselves | local (Claude Code) | elsewhere: user-level, or a git-ignored project file |

All of these survive restarts. Session-only options (such as `claude --mcp-config`) do not — don't
use them when the user asked for persistence.

## 3. Identify the client

Configure the client you are running in unless the user names another. Clues: Claude Code →
`claude` CLI, `~/.claude/`; Codex → `codex`, `~/.codex/`; Gemini CLI → `gemini`, `~/.gemini/`;
Cursor → `.cursor/`; VS Code → `.vscode/`. If it's still unclear, ask.

**Read that client's section in [references/clients.md](references/clients.md) before writing
anything.** Commands, file locations and key names differ between clients, and a config that is
valid for one is silently ignored by another.

## 4. Probe the server before saving it

`scripts/probe_mcp.py` (in this skill's directory, Python 3 standard library only) starts or
contacts the server, performs the MCP handshake and lists its tools:

```bash
python3 scripts/probe_mcp.py -- npx -y @modelcontextprotocol/server-everything   # stdio
python3 scripts/probe_mcp.py --env API_KEY=... -- uvx some-server==1.2.0         # stdio with env
python3 scripts/probe_mcp.py https://mcp.example.com/mcp                         # HTTP
python3 scripts/probe_mcp.py --bearer-env EXAMPLE_TOKEN https://mcp.example.com/mcp
```

- **Exit 0** — prints the server's name and tools. Go ahead.
- **Exit 3** — the server requires authentication. Expected for OAuth servers: save it and let the
  client run the login. For token servers, re-probe with `--header` or `--bearer-env`.
- **Exit 1** — prints the error and the server's stderr. Fix it now (missing env var, wrong
  package, Node/Python/Docker not installed, wrong URL) instead of saving a broken config.

## 5. Write the config

- **Prefer the client's own CLI** (`claude mcp add`, `codex mcp add`, `gemini mcp add`,
  `code --add-mcp`). It writes the right file in the right format.
- **When a file must be edited by hand**: read it first, copy it to `<file>.bak`, change only this
  server's entry, keep every other server, then parse the file to prove it is still valid
  JSON/TOML.
- **Never hand-edit `~/.claude.json`** — it holds Claude Code's state. Use `claude mcp add` or
  `claude mcp add-json`.
- **To change an existing server**, remove it and add it again; most CLIs refuse to overwrite.

Make it keep working later, not just today:

- **Pin package versions**: `npx -y pkg@1.4.2`, `uvx pkg==1.4.2`. An unpinned server can change or
  break under the user at any later launch.
- **Use absolute paths for `command` in GUI clients** (Cursor, VS Code, Claude Desktop). Apps
  launched from a dock or menu don't load the shell profile, so `npx` or `uvx` from nvm, asdf,
  Homebrew or `~/.local/bin` may not be found. Resolve with `command -v npx`. nvm paths change
  when the active Node version changes; mention this if you use one.
- **Allow for slow first starts**: the first `npx`/`uvx` run downloads the package. Raise the
  client's startup timeout if it has a low default (Codex: 10 s).
- **Windows**: `npx` is a `.cmd` shim. If the client can't start it, use command `cmd` with args
  `["/c", "npx", "-y", "pkg"]`.

## 6. Handle secrets

- **Never put a secret in a project-scoped file** that goes into git. Reference an environment
  variable instead (syntax per client in `references/clients.md`) and tell the user which variable
  to set.
- A reference only works if the variable exists where the client is launched. For CLI clients
  that means the shell profile (`~/.zshrc`, `~/.bashrc`). GUI apps often don't read it; use the
  client's own mechanism there (`envFile`, VS Code `inputs`).
- A literal secret in a user-level config (readable only by the user) is acceptable if the user
  prefers it. Say exactly which file holds it.
- Don't repeat secret values in your replies or print them in command output.

## 7. Verify and hand over

1. Run the client's own check — `claude mcp list` / `claude mcp get <name>` (shows `✔ Connected`,
   `! Needs authentication` or `✘ Failed to connect`), `gemini mcp list`. `codex mcp list` only
   shows the saved config, so for Codex the probe from step 4 is the connection check. For clients
   without a CLI, confirm the file parses and the entry is under the right top-level key.
2. If the server uses OAuth, tell the user how to log in (Claude Code: `/mcp` or
   `claude mcp login <name>`; Codex: `codex mcp login <name>`).
3. Tell the user to start a new session or restart the app so the client loads the server, and how
   to see it there (Claude Code: `/mcp`).
4. Report: server name, scope, the file that was written, env vars they must set, and the command
   to remove it.
