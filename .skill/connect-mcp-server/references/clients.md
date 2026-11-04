# Client reference

Commands and file formats for persisting an MCP server in each client. Read only the section for the
client you are configuring.

- [Claude Code](#claude-code)
- [Codex CLI](#codex-cli)
- [Gemini CLI](#gemini-cli)
- [Cursor](#cursor)
- [VS Code / GitHub Copilot](#vs-code--github-copilot)
- [Claude Desktop](#claude-desktop)
- [Other clients](#other-clients)

---

## Claude Code

**Scopes** (all persistent):

| Scope | Flag | Written to |
|---|---|---|
| local (default) | `-s local` | `~/.claude.json`, under the current project's path. Only you, only this project |
| project | `-s project` | `.mcp.json` in the project root. Shared through git |
| user | `-s user` | `~/.claude.json`. Only you, every project |

When the same name exists in several scopes, local wins over project, which wins over user. The
whole entry from the winning scope is used; fields are not merged.

**Add**: options go *before* the name; everything after `--` is the server's own command.

```bash
# stdio (--env must NOT come right before the name; see the note below)
claude mcp add --env API_KEY=value -s user --transport stdio airtable -- npx -y airtable-mcp-server@1.2.3

# Streamable HTTP
claude mcp add -s user --transport http notion https://mcp.notion.com/mcp

# HTTP with a token header
claude mcp add -s user --transport http my-api https://api.example.com/mcp \
  --header "Authorization: Bearer $MY_API_TOKEN"

# Any entry as JSON (also the way to add WebSocket servers)
claude mcp add-json -s user weather '{"type":"http","url":"https://api.weather.com/mcp"}'
```

- `--env` takes several `KEY=value` pairs. If the server name comes right after `--env`, it is read
  as another pair and rejected — put another option (such as `--transport stdio`) in between.
- Names may contain letters, numbers, hyphens and underscores.
- `--transport sse` still exists but is deprecated.

**Inspect / remove**:

```bash
claude mcp list              # every server with ✔ Connected / ! Needs authentication / ✘ Failed to connect
claude mcp get <name>        # one server; failures show on an "Issue:" line
claude mcp remove <name> -s user
```

**OAuth**: add the server, then run `/mcp` inside Claude Code, or from a shell
`claude mcp login <name>` (`--no-browser` prints the URL instead of opening it).

**`.mcp.json`** (project scope) format, with environment variable expansion:

```json
{
  "mcpServers": {
    "api-server": {
      "type": "http",
      "url": "${API_BASE_URL:-https://api.example.com}/mcp",
      "headers": { "Authorization": "Bearer ${API_KEY}" }
    },
    "local-tool": {
      "type": "stdio",
      "command": "npx",
      "args": ["-y", "some-mcp-server@1.0.0"],
      "env": { "TOOL_TOKEN": "${TOOL_TOKEN}" }
    }
  }
}
```

- `${VAR}` and `${VAR:-default}` expand in `command`, `args`, `env`, `url` and `headers`. An unset
  variable without a default is left as literal text and `claude mcp list` warns about it.
- Each person must approve project-scoped servers on their first interactive run.
- Per-server `"timeout"` (ms) sets the tool timeout. Startup timeout: env var `MCP_TIMEOUT` (ms).

**Loading**: a server added during a running session may not appear until a new session starts.
Check with `/mcp`; `/mcp reconnect all` retries failed servers.

---

## Codex CLI

**Add**:

```bash
codex mcp add context7 -- npx -y @upstash/context7-mcp@1.0.0      # stdio
codex mcp add docs --env API_KEY=value -- uvx docs-mcp==2.1.0      # stdio with env
codex mcp add example --url https://mcp.example.com/mcp            # Streamable HTTP
codex mcp add api --url https://api.example.com/mcp --bearer-token-env-var API_TOKEN
codex mcp login example                                            # OAuth
codex mcp list                                                     # also: get <name>, remove <name>, logout <name>
```

- `codex mcp list` shows what is configured, **not** whether it connects. Verify with
  `scripts/probe_mcp.py`, then have the user start a new Codex session.
- `codex mcp add` doesn't set a startup timeout. For `npx`/`uvx` servers add
  `startup_timeout_sec = 60` to the entry in `config.toml` afterwards.

**File**: `~/.codex/config.toml` (user, persistent). A project can use `.codex/config.toml`, but
Codex only reads it for trusted projects.

```toml
[mcp_servers.context7]
command = "npx"
args = ["-y", "@upstash/context7-mcp@1.0.0"]
env_vars = ["LOCAL_TOKEN"]        # forward these variables from the launching environment
startup_timeout_sec = 60          # default 10 — too short for a first npx/uvx download
tool_timeout_sec = 60
enabled = true                    # false disables without deleting

[mcp_servers.context7.env]
MY_ENV_VAR = "value"

[mcp_servers.figma]
url = "https://mcp.figma.com/mcp"
bearer_token_env_var = "FIGMA_OAUTH_TOKEN"
http_headers = { "X-Figma-Region" = "us-east-1" }
```

- stdio fields: `command` (required), `args`, `env`, `env_vars`, `cwd`.
- HTTP fields: `url` (required), `bearer_token_env_var`, `http_headers`, `env_http_headers`.
- For secrets prefer `env_vars` / `bearer_token_env_var` over literal values in `env`.
- Validate after editing: `python3 -c "import tomllib; tomllib.load(open('$HOME/.codex/config.toml','rb'))"`.

---

## Gemini CLI

**Add**: `gemini mcp add [options] <name> <commandOrUrl> [args...]`

**The default scope is `project`** (`.gemini/settings.json`). Pass `-s user` for
`~/.gemini/settings.json` when the user wants it everywhere.

```bash
gemini mcp add -s user -e API_KEY=value my-server /path/to/server arg1
gemini mcp add -s user --transport http -H "Authorization: Bearer $TOKEN" secure-api https://api.example.com/mcp
gemini mcp list                  # name, config and connection status
gemini mcp remove -s user my-server
```

- `-t/--transport`: `stdio` (default), `http`, `sse`. Also `--timeout`, `--trust`,
  `--include-tools`, `--exclude-tools`.
- If the server's args start with `-` (for example `npx -y pkg`), the CLI may read them as its own
  flags. Edit `settings.json` directly in that case.
- **Avoid underscores in names**: Gemini's policy parser splits on them.
- stdio servers in an untrusted folder show as "Disconnected"; `gemini trust` trusts the folder.

**File format** — exactly one of `command` (stdio), `httpUrl` (Streamable HTTP) or `url` (SSE):

```json
{
  "mcpServers": {
    "local-tool": {
      "command": "npx",
      "args": ["-y", "some-mcp-server@1.0.0"],
      "env": { "API_KEY": "$MY_API_TOKEN" },
      "timeout": 30000
    },
    "remote": {
      "httpUrl": "https://api.example.com/mcp",
      "headers": { "Authorization": "Bearer ${REMOTE_TOKEN}" }
    }
  }
}
```

`$VAR` and `${VAR}` expand everywhere (`%VAR%` on Windows only). An undefined variable becomes an
empty string. `"trust": true` skips every tool confirmation for that server — only on the user's
explicit request.

---

## Cursor

No CLI is documented; edit the file.

- User (every project): `~/.cursor/mcp.json`
- Project: `.cursor/mcp.json`

```json
{
  "mcpServers": {
    "local-tool": {
      "type": "stdio",
      "command": "/absolute/path/to/npx",
      "args": ["-y", "some-mcp-server@1.0.0"],
      "env": { "API_KEY": "${env:SOME_API_KEY}" },
      "envFile": "${userHome}/.config/some-mcp/.env"
    },
    "remote": {
      "url": "https://api.example.com/mcp",
      "headers": { "Authorization": "Bearer ${env:REMOTE_TOKEN}" }
    }
  }
}
```

- Interpolation in `command`, `args`, `env`, `url`, `headers`: `${env:NAME}`, `${userHome}`,
  `${workspaceFolder}`, `${workspaceFolderBasename}`, `${/}`.
- `envFile` works for stdio servers only.
- Cursor is a GUI app: use an absolute `command` path. Restart Cursor (or toggle the server in its
  MCP settings) to load the change.

---

## VS Code / GitHub Copilot

**The top-level key is `servers`, not `mcpServers`.**

- Workspace: `.vscode/mcp.json`.
- User (every workspace): run **MCP: Open User Configuration** from the Command Palette, or add from
  a shell:

  ```bash
  code --add-mcp '{"name":"my-server","command":"npx","args":["-y","some-mcp-server@1.0.0"]}'
  ```

```json
{
  "inputs": [
    { "type": "promptString", "id": "api-key", "description": "API key for my-server", "password": true }
  ],
  "servers": {
    "my-server": {
      "type": "stdio",
      "command": "npx",
      "args": ["-y", "some-mcp-server@1.0.0"],
      "env": { "API_KEY": "${input:api-key}" }
    },
    "remote": {
      "type": "http",
      "url": "https://api.example.com/mcp"
    }
  }
}
```

- `inputs` with `${input:<id>}` keeps secrets out of the file: VS Code asks once and stores the
  value securely. Use it for anything committed to a workspace.
- Workspace servers start once the workspace is trusted. Servers from other sources show a trust
  dialog on first start or after their config changes.
- VS Code also reads a portable root `.mcp.json` (top-level `mcpServers`). The GitHub Copilot CLI
  reads `~/.copilot/mcp-config.json` (or `$COPILOT_HOME/mcp-config.json`), also `mcpServers`.

---

## Claude Desktop

Edit `claude_desktop_config.json`:

- macOS: `~/Library/Application Support/Claude/claude_desktop_config.json`
- Windows: `%APPDATA%\Claude\claude_desktop_config.json`

```json
{
  "mcpServers": {
    "local-tool": {
      "command": "/absolute/path/to/npx",
      "args": ["-y", "some-mcp-server@1.0.0"],
      "env": { "API_KEY": "value" }
    }
  }
}
```

- This file is for local (stdio) servers. Remote servers are added in the app under
  Settings → Connectors.
- GUI app: use absolute paths. Fully quit and reopen the app to load the change.
- Claude Code can import these entries with `claude mcp add-from-claude-desktop` (macOS and WSL).

---

## Other clients

Most clients use the same `mcpServers` JSON shape (`command` / `args` / `env` for stdio, `url`
plus optional `headers` for remote). Find the client's documented user-level config file, follow
the editing rules in SKILL.md step 5, then restart the client and confirm the server's tools appear.
