# Advanced: MCP Tools (10 tools for Claude Code / Codex CLI)

> 🎯 **This is an ADVANCED, OPTIONAL path.** For normal use you do **not** need MCP:
> Claude Desktop already shows all 19 models in its picker, and ChatGPT/Codex use all
> models via the one-line install + "say switch to X". MCP only adds **tool** access
> for agentic workflows (Claude Code, Codex CLI).

## What you get

The **AIOrouter MCP Server** (`@aiorouter/mcp`) exposes **10 tools**:

| # | Tool | Description |
|:---|:---|:---|
| 1 | `aiorouter_chat` | Send a chat completion to any AIOrouter model |
| 2 | `aiorouter_list_models` | List all available models with provider info |
| 3 | `aiorouter_get_presets` | Show preset configuration |
| 4 | `aiorouter_get_pricing` | Get public retail pricing (USD per 1M tokens) |
| 5 | `aiorouter_get_usage` | Get usage, billing, and subscription status |
| 6 | `aiorouter_test_connection` | Test API key validity and show account info |
| 7 | `aiorouter_export_config` | Generate MCP config JSON for Claude Desktop/Code/Codex |
| 8 | `aiorouter_compare_models` | Compare 2-5 models side-by-side |
| 9 | `aiorouter_estimate_cost` | Estimate cost for a prompt (input + output tokens) |
| 10 | `aiorouter_get_model_info` | Get detailed info for a single model |

## Where to get it

The MCP server is a **separate open-source package** in its own repository:

- **Repo:** [github.com/AIOCANA/aiorouter-mcp](https://github.com/AIOCANA/aiorouter-mcp)
- **npm:** `@aiorouter/mcp`

```bash
npm install -g @aiorouter/mcp
# or run without installing:
npx @aiorouter/mcp
```

> The MCP server source code lives in the `aiorouter-mcp` repo — it is **not** part
> of this repository (this repo is the setup gateway only).

## Quick start

### Claude Desktop / Claude Code

Add to your MCP config (e.g. `claude_desktop_config.json` or project `.mcp.json`):

```json
{
  "mcpServers": {
    "aiorouter": {
      "command": "npx",
      "args": ["-y", "@aiorouter/mcp"],
      "env": { "AIOROUTER_API_KEY": "ak-your-key" }
    }
  }
}
```

### Codex CLI

```bash
# 1. Add this repository as a Codex plugin marketplace (once):
codex plugin marketplace add AIOCANA/aiorouter-mcp

# 2. Install the plugin — the MCP server is declared via mcpServers in plugin.json:
codex plugin add aiorouter

# 3. Set your API key when prompted (or export in your shell):
export AIOROUTER_API_KEY=ak-your-key

# 4. Verify:
codex mcp list    # → aiorouter with 10 tools
```

### Remote HTTP MCP Server

AIOrouter also provides a Remote HTTP MCP Server at `https://api.aiorouter.ca/mcp`
(Streamable HTTP, stateless; auth via API key or OAuth 2.1) with the same 10 tools.

## Security

- **PII Shield:** personal information and technical secrets are protected before
  routing to any model
- **API Key Safety:** your key stays in your environment — never written to disk
- **HTTPS Only:** all communication with AIOrouter uses HTTPS
- **No Package Secrets:** the npm package contains zero API keys or secrets

## See also

- Setup guides: [claude-desktop/SETUP.md](../claude-desktop/SETUP.md),
  [chatgpt-codex/SETUP.md](../chatgpt-codex/SETUP.md)
- Canonical 19-model list: [docs/model-catalog-link.md](model-catalog-link.md)
- [docs/privacy-policy.md](privacy-policy.md)