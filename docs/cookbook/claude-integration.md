# Claude Desktop / Claude Code Integration (Anthropic Messages API)

> **Doc type:** Cookbook — user-facing setup guide
> **Related:** setup guides: [claude-desktop/SETUP.md](../../claude-desktop/SETUP.md) · [chatgpt-codex/SETUP.md](../../chatgpt-codex/SETUP.md)
> **Version:** v1.1.0 | **Date:** 2026-08-09
> **Author:** AIRO (deepseek-v4-flash)

Use **Claude Desktop** (Third-Party Inference) and **Claude Code** (CLI)
directly with your **AIOrouter API key** (`ak-...`) through the Anthropic
Messages API–compatible endpoint (`POST /v1/messages`), with the PII Shield,
AI Firewall and billing running on every request — or run any of the 15+
AIOrouter models (DeepSeek, Qwen, GLM, Kimi, Grok, …) from inside Claude
Desktop via the one-command bridge.

---

## 1. How it works

Claude Desktop's "Third-Party Inference" feature lets you point the app at a
custom gateway that speaks the Anthropic Messages API. AIOrouter exposes
`POST /v1/messages`, which:

1. Translates the Anthropic request into the canonical chat format;
2. Runs the **entire** AIOrouter pipeline — PII Shield pseudonymization,
   AI Firewall, billing, model routing — exactly as `/v1/chat/completions`;
3. Translates the response back into Anthropic format (`content` blocks,
   including streaming SSE and `tool_use`).

```
Claude Desktop / Claude Code ── x-api-key / Bearer ──► POST /v1/messages
    └─ 3P profile (static inferenceModels)             └─ PII Shield → AI Firewall → billing → router
                                                           └─ DeepSeek / Qwen / GLM / Kimi / Grok …
```

By default Claude Desktop only shows **Claude** models it discovers from the
gateway. The **bridge** (`scripts/aiorouter-claude-bridge.mjs`) writes a
profile with a static model list so the picker shows **all** AIOrouter
models.

---

## 2. Prerequisites

- **AIOrouter account + API key** (`ak-...`) from
    <https://dashboard.aiorouter.ca/keys> — new accounts get a one-time free
    trial (25,000 tokens / 7 days, `deepseek-v4-flash` only). Subscriptions
    (from $19/month) unlock all 19 models; your same key keeps working after
    upgrade.
- **Claude Desktop** with Third-Party Inference support (Windows:
  `%LOCALAPPDATA%\Claude-3p\`), or **Claude Code** CLI.

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

### 3.2 One-command apply (recommended — shows all models)

The Import-template flow scopes the picker to Claude discovery models. To
show **all AIOrouter models** in the picker, apply the profile with the
bridge:

```bash
node scripts/aiorouter-claude-bridge.mjs --apply
```

The bridge fetches the model list from the gateway (`/v1/models`), writes the
profile `{uuid}.json` into the Claude Desktop 3P config library
(`%LOCALAPPDATA%\Claude-3p\configLibrary\`), sets `modelDiscoveryEnabled:
false`, and backs up the previous profile. Check the result:

```bash
node scripts/aiorouter-claude-bridge.mjs --status
node scripts/verify-claude-profile.mjs   # structural check (alias shape, label, tier, default)
```

> 🔑 **紅線 4 — the bridge never prints or persists your API key.** A fresh
> `--api-key` is used only for the in-memory model-list fetch; the profile
> carries forward only an **existing** key verbatim. If no key exists yet,
> fill it in the Desktop GUI afterwards.
>
> ℹ️ **Why the picker now shows all models:** the bridge writes
> `inferenceModels[].name` as Claude-shaped aliases (`claude-opus-4-8-{code}`)
> because Claude Desktop's client-side picker filter only shows
> `claude`/`anthropic`-prefixed ids. The gateway serves `/v1/models` in
> OpenAI shape (real ids), so the bridge derives the alias itself — the same
> SHA-256 algorithm the server uses to decode it.

### 3.3 Switch models

Pick a model in the Desktop GUI, or use the CLI (supports the "切換到 X"
spoken command):

```bash
node scripts/aiorouter-claude-bridge.mjs --switch-model qwen3.7-max
node scripts/aiorouter-claude-bridge.mjs --switch-model qwen3.7-max --dry-run   # preview only
```

`--switch-model` moves `isFamilyDefault` to the matching `inferenceModels`
entry and **preserves all other profile fields** (your API key, auth scheme,
custom base URL, GUI-managed settings).

### 3.4 Refresh the model list

New models appear in the gateway catalog; refresh the static list in the
profile without touching anything else:

```bash
node scripts/aiorouter-claude-bridge.mjs --refresh-models
```

---

## 4. Setup — Claude Code (CLI)

```bash
# macOS / Linux
export ANTHROPIC_BASE_URL="https://api.aiorouter.ca"
export ANTHROPIC_API_KEY="ak-YOUR_KEY"

# Windows PowerShell
$env:ANTHROPIC_BASE_URL = "https://api.aiorouter.ca"
$env:ANTHROPIC_API_KEY = "ak-YOUR_KEY"

claude "Hello, are you connected to AIOrouter?"
```

> ⚠️ **Never** hard-code the key in scripts, commit it, or echo it to logs.

---

## 5. Security posture

- **TLS enforced.** The bridge refuses to send an API key over plain `http:`
  except to loopback hosts (`127.0.0.1`, `localhost`, `::1`) for local
  testing. Use `https://` for anything reachable over the network.
- **Redirects are never followed.** The key is never forwarded to a different
  host via an HTTP redirect (`redirect: "error"`).
- **The bridge never prints or persists an API key** (紅線 4). `--api-key` is
  fetch-only, in-memory.

---

## 6. Troubleshooting

| Symptom | Cause / Fix |
|:---|:---|
| `401` / `invalid_api_key` | Wrong key, or key revoked/expired. Regenerate at <https://dashboard.aiorouter.ca/keys>. |
| Picker only shows Claude models | The 3P profile has no static `inferenceModels`. Run `--apply` (or `--refresh-models` after a gateway update). |
| `--apply` aborts with "corrupt `_meta.json`" | A previous run left an unparseable `_meta.json`; the bridge refuses to overwrite it. Delete the corrupt file (or restore a `.bak`) and re-run. |
| `--switch-model` fails fast with a usage error | No slug was given, or the slug was swallowed by a following flag (`--dry-run`). Pass a non-flag slug. |
| `Refusing to send the API key over plain http…` | `--base-url` was `http://` to a non-loopback host. Use `https://` (or `http://127.0.0.1`/`localhost` for local testing). |
| Desktop shows the model but the reply is slow | The model is a non-Claude model going through format translation; `tool_use` is fully supported only for Claude models. |

---

## 7. Related

- [Anthropic Gateway plan (開発文檔)](../../claude-desktop/SETUP.md)
- [Codex CLI Integration (`/v1/responses`)](codex-integration.md)
- [Codex model switch bridge](codex-model-switch.md)
- Bridge source: `scripts/aiorouter-claude-bridge.mjs`