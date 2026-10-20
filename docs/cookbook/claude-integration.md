# Claude Desktop / Claude Code Integration (Anthropic Messages API)

> **Doc type:** Cookbook — user-facing setup guide
> **Version:** v1.2.0 | **Date:** 2026-09-07
> **Author:** AIRO

Use **Claude Desktop** (Third-Party Inference) and **Claude Code** (CLI) with
your **AIOrouter API key** (`ak-...`) through the Anthropic Messages
API–compatible endpoint (`POST /v1/messages`), with the PII Shield,
AI Firewall and billing running on every request.

---

## 1. How it works

Claude Desktop's "Third-Party Inference" feature lets you point the app at a
custom gateway that speaks the Anthropic Messages API. AIOrouter exposes
`POST /v1/messages`, which:

1. Translates the Anthropic request into the canonical chat format;
2. Runs the **entire** AIOrouter pipeline — PII Shield pseudonymization,
   AI Firewall (chat detect-only: scans and logs injection patterns, never
   blocks agent work), billing, model routing — exactly as `/v1/chat/completions`;
3. Translates the response back into Anthropic format (`content` blocks,
   including streaming SSE and `tool_use`).

```
Claude Desktop / Claude Code ── x-api-key / Bearer ──► POST /v1/messages
    └─ 3P profile                               └─ PII Shield → AI Firewall (chat detect-only) → billing → router
                                                     └─ DeepSeek / Qwen / GLM / Kimi / Grok …
```

---

## 2. Prerequisites

- **AIOrouter account + API key** (`ak-...`) from
    <https://dashboard.aiorouter.ca/keys> — new accounts get a one-time free
    trial (see the trial note on the setup page). One-time Top-Up credits
    unlock every model; your same API key keeps working.
- **Claude Desktop** with Third-Party Inference support, or **Claude Code**
    CLI. See the [Claude Desktop setup page](/claude-desktop-setup) for the
    supported version notes.

---

## 3. Setup — Claude Desktop (GUI)

### 3.1 Import the configuration template

1. Download the template:
   `https://api.aiorouter.ca/claude-desktop-template.json`
2. Claude Desktop → Developer → **Configure Third-Party Inference…** →
   **Import configuration**.
3. Select the downloaded JSON file → import.
4. Fill in the **Gateway API key**: `ak-...`.
5. Choose the Gateway auth scheme: **`x-api-key`**.
6. Restart Claude Desktop.

> The one-line installer (`/setup/install-claude.ps1` / `.sh`) automates
> this flow with masked key input and backs up your existing files before any
> change. You can review the script first.

### 3.2 Switch models

Pick a model in the Desktop GUI, or switch by conversation where the client
supports it. Every AIOrouter model is reachable through the same key — the
catalogue is served from the gateway, so new models appear without a client
update. See the [Claude Desktop setup page](/claude-desktop-setup) for the
current switching instructions.

---

## 4. Setup — Claude Code (CLI)

```bash
# macOS / Linux
export ANTHROPIC_BASE_URL="https://api.aiorouter.ca"
export ANTHROPIC_API_KEY="ak-YOUR-KEY"

# Windows PowerShell
$env:ANTHROPIC_BASE_URL = "https://api.aiorouter.ca"
$env:ANTHROPIC_API_KEY = "ak-YOUR-KEY"

claude "Hello, are you connected to AIOrouter?"
```

> ⚠️ **Never** hard-code the key in scripts, commit it, or echo it to logs.
> Use your shell's secret store or a secret manager when possible.

---

## 5. Security posture

- **One key, no key on disk.** The API key is supplied at call time or through
  your shell's secret store — never written into a profile or a log.
- **HTTPS only.** Use `https://` for anything reachable over the network;
  plain `http://` is refused except to loopback hosts for local testing.
- **Redirects are not followed with credentials.** The key is never forwarded
  to a different host via an HTTP redirect.

---

## 6. Troubleshooting

| Symptom | Cause / Fix |
|:---|:---|
| `401` / `invalid_api_key` | Wrong key, or key revoked/expired. Regenerate at <https://dashboard.aiorouter.ca/keys>. |
| Picker only shows a subset of models | The 3P profile lists the models the client discovered. Check the [Claude Desktop setup page](/claude-desktop-setup) for the current model-list guidance. |
| Desktop shows the model but the reply is slow | A non-Claude model goes through format translation; `tool_use` is fully supported for Claude models. |

---

## 7. Related

- [Claude Desktop setup overview](/claude-desktop-setup)
- [Codex CLI Integration (`/v1/responses`)](/docs/cookbook/codex-integration)
- [Codex model switch guide](/docs/cookbook/codex-model-switch)
