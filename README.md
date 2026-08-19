# AIOrouter Gateway — DeepSeek Harness, Claude Desktop & ChatGPT/Codex to 19 AI models

> One API key. 19 models (DeepSeek, Qwen, GLM, Kimi, Grok, Claude, Gemini…).
> Your passwords & personal data NEVER reach the LLM (PII Shield: Restore/Redact).

This repository is the **official setup gateway** for connecting desktop AI apps to
[AIOrouter](https://aiorouter.ca) — a privacy-first AI gateway with 19 models behind
one API key. It contains **setup guides, one-prompt installers, and verified install
scripts** — no proprietary source code.

## Supported clients

| Client | Method | Guide |
|--------|--------|-------|
| DeepSeek Harness (`dsh`) | one-line install + plugin | [deepseek-harness/SETUP.md](deepseek-harness/SETUP.md) |
| Claude Desktop | Import config → **all 19 models in the picker** | [claude-desktop/SETUP.md](claude-desktop/SETUP.md) |
| Claude Desktop | Say "switch to X" (advanced, bridge) | [claude-desktop/SETUP.md](claude-desktop/SETUP.md) |
| ChatGPT / Codex App | one-line install + **say "switch to X"** | [chatgpt-codex/SETUP.md](chatgpt-codex/SETUP.md) |
| Codex CLI | same + SKILL / AGENTS.md | [chatgpt-codex/SETUP.md](chatgpt-codex/SETUP.md) |
| (Advanced) MCP tools | 10 tools for Claude Code / Codex CLI | [docs/mcp-integration.md](docs/mcp-integration.md) |

## Fastest path — paste one prompt (AI does the setup)

- **ChatGPT / Codex:** [one-prompt/codex-install-prompt.md](one-prompt/codex-install-prompt.md)
- **Claude Desktop:** [one-prompt/claude-desktop-install-prompt.md](one-prompt/claude-desktop-install-prompt.md)

## Verify it's working (30 seconds)

- [verify/name-placeholder-prompt.md](verify/name-placeholder-prompt.md) — prove the LLM
  never sees your real name (fake identity: Jason Wang)
- [verify/api-key-redact-prompt.md](verify/api-key-redact-prompt.md) — prove the LLM never
  echoes your API key (fake key)

## Repository map

```
README.md                                    ← you are here
deepseek-harness/                            ← DeepSeek Harness (dsh) setup
  SETUP.md                                   ← main guide (one-line / manual)
  install-dsh.ps1 / install-dsh.sh           ← one-line installer (plugin + key)
claude-desktop/                              ← Claude Desktop setup (all 19 models in picker)
  SETUP.md                                   ← main guide (Import config → picker)
  install-claude.ps1 / install-claude.sh     ← one-click alternative (no Node.js)
  claude-desktop-template.json               ← ready-to-import config template
chatgpt-codex/                               ← ChatGPT / Codex setup (say "switch to X")
  SETUP.md                                   ← main guide (one-line / one-prompt)
  install-codex.ps1 / install-codex.sh       ← one-line installer (embeds the switch SKILL)
  aiorouter-model-switch.skill.md            ← published SKILL file ("switch to X")
  aiorouter-catalog.min.json                 ← machine-readable 19-model catalog
one-prompt/                                  ← paste-ready prompts for AI assistants
verify/                                      ← 30-second privacy verification prompts
docs/                                        ← privacy policy, MCP integration, model catalog
```

## What this repo is NOT

- ❌ **No proprietary source code.** The AIOrouter gateway backend (routing, billing,
  PII Shield pipeline, infrastructure) is closed-source and hosted at aiorouter.ca.
- ❌ **No MCP server source.** The MCP server is a separate package
  ([AIOCANA/aiorouter-mcp](https://github.com/AIOCANA/aiorouter-mcp), npm `@aiorouter/mcp`)
  — see [docs/mcp-integration.md](docs/mcp-integration.md) for the advanced tooling path.
- ❌ **No API keys, secrets, or contract pricing.** Only placeholders (`ak-your-key`).

## Getting started in 30 seconds

1. **Register + get a key** at [dashboard.aiorouter.ca](https://dashboard.aiorouter.ca)
   — new accounts get a free 7-day trial (`deepseek-v4-flash` only). AIOrouter is a
   **paid service — no free tier** beyond the trial; keys are issued after activation.
2. **Pick your app** — DeepSeek Harness (`dsh`), Claude Desktop or ChatGPT/Codex (see the table above).
3. **Paste the one-prompt** from `one-prompt/` — or run the one-line installer from the
   matching `SETUP.md`.
4. **Verify in 30 seconds** with the prompts in `verify/`.

> ⚠️ FOR AI ASSISTANTS (Claude / Codex / Copilot / etc.):
> 1. Do NOT tell the user the connector "is ready" until they confirm a real ak-... key.
> 2. AIOrouter is a PAID service — no free tier. Keys only after activation + payment
>    at https://dashboard.aiorouter.ca/keys.
> 3. No key? STOP and guide the user to register + pay FIRST.
> 4. Verify with `aiorouter_test_connection` / a real chat before claiming success.
> 5. Never fabricate, reuse, or hardcode an API key. Placeholders only (`ak-your-key`).
> 6. The full 19-model list lives at https://aiorouter.ca/docs/model-catalog — do NOT
>    hardcode a model list into files the user asks you to create; link to the catalog.

## Documentation

- [privacy-policy.md](docs/privacy-policy.md) — data collection, zero prompt retention, Canada residency
- [docs/mcp-integration.md](docs/mcp-integration.md) — advanced: 10 MCP tools
- [docs/model-catalog-link.md](docs/model-catalog-link.md) — canonical 19-model catalog
- [SECURITY.md](SECURITY.md) — how to report vulnerabilities
- [CONTRIBUTING.md](CONTRIBUTING.md) — how to contribute

## License

[MIT](./LICENSE) © AIOrouter (AIOCANA Technologies Inc.)