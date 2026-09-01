# Codex CLI Integration (Responses API / `wire_api = "responses"`)

> **Doc type:** Cookbook — user-facing setup guide
> **Version:** v1.3.1 | **Date:** 2026-08-10
> **Author:** AIRO (deepseek-v4-flash)

Use **OpenAI Codex CLI** (and, when official support lands, the Codex App) directly
  with your **AIOrouter API key** (`ak-...`) to access all 19 models — DeepSeek,
  Qwen, GLM, Kimi, Grok, Claude and Gemini — through a single `POST /v1/responses`
  endpoint, with the PII Shield, AI Firewall and billing running on every request.

---

## 1. How it works

Codex's `model_providers.<id>.wire_api` supports **only `responses`** (the OpenAI
Responses API). AIOrouter therefore exposes a Responses API–compatible endpoint
(`POST https://api.aiorouter.ca/v1/responses`) that:

1. Translates the Responses request (`instructions` + `input` items) into the
   canonical chat format;
2. Runs the **entire** AIOrouter pipeline — PII Shield pseudonymization,
   AI Firewall, billing, model routing — exactly as `/v1/chat/completions` does;
3. Translates the response back into Responses API format (`output` items +
   `output_text`), including SSE streaming and tool calls.

Because the Codex Gateway endpoint is authenticated with your AIOrouter key, the
AI Firewall treats the agent's **own** system prompt as trusted (source-based
trust, not content-based). Since v0.4 the chat path also runs the firewall in
**detect-only** mode — it scans and logs injection patterns but never blocks or
redacts legitimate agent content — so Codex updates never trigger false
`PROMPT_INJECTION_DETECTED` blocks, while PII protection stays fully intact.

```
Codex CLI ── AIOROUTER_API_KEY ──► POST /v1/responses
  └─ wire_api = "responses"          └─ PII Shield → AI Firewall → billing → router
                                         └─ DeepSeek / Qwen / GLM / Kimi / Grok …
```

---

## 2. Prerequisites

- **AIOrouter account + API key** (`ak-...`) from
    <https://dashboard.aiorouter.ca/keys> — new accounts get a one-time free trial
    (25,000 tokens / 7 days, `deepseek-v4-flash` only). One-time Top-Up
    credits (from $10 CAD, balance never expires) unlock all 19 models; your
    same API key keeps working.
- **Codex CLI** installed (`codex --version`), v0.146.0 or newer recommended.

> ### ⚠️ Windows desktop app (ChatGPT / Codex) — read before installing
>
> The ChatGPT desktop app keeps running in the **background** (system tray) even
> after you close its window — and a running app can **overwrite
> `~/.codex/auth.json`** (OAuth token refresh) right after the installer writes
> your AIOrouter key, which silently breaks the setup (the app then shows your
> ChatGPT name instead of “AIOrouter”).
>
> **Before running the one-line installer, do this:**
> 1. **Quit the app completely** — right-click the tray icon → **Quit** (many
>    users only close the window; the tray icon keeps it alive).
> 2. If you are unsure, **reboot Windows** and **do not start ChatGPT** before
>    running the command.
> 3. Then run (in PowerShell):
>    ```powershell
>    irm https://aiorouter.ca/setup/install-codex.ps1 | iex
>    ```
>    The installer itself now **detects a background app** and warns you (answer
>    `y` only if you are sure the app cannot overwrite `auth.json`).
> 4. After it finishes, **relaunch the app** — the bottom-left name should be
>    **AIOrouter** and the model menu should show **Custom**.

---

## 3. Setup — Codex CLI

### 3.1 Create `~/.codex/config.toml`

```toml
  # ── AIOrouter × Codex — configuration ──────────────────────────────
  # How to switch models:
  #   1. Say "switch to X" in the app/CLI (SKILL + bridge). New chats use the
  #      new model immediately — no restart needed.
  #   2. Or uncomment exactly ONE "model =" line below (keep all others commented).
  #   3. Per run (CLI):  codex exec -m <model> "your prompt"
  #   4. Desktop App: the app's model menu is OpenAI-limited (hardcoded) — do
  #      NOT use it to switch; say "switch to X" in the chat instead (SKILL).
  # Full guide: https://aiorouter.ca/codex-integration#setup
  # ────────────────────────────────────────────────────────────────────
  # MODEL — uncomment exactly ONE line (default = deepseek-v4-flash).
  # Full 19-model list: https://aiorouter.ca/docs/model-catalog
  model = "deepseek-v4-flash"      # default — fast & cost-effective
  # model = "deepseek-v4-pro"      # deeper reasoning
  # model = "qwen3.8-max"
  # model = "qwen3.8-flash"
  # model = "qwen3.7-max"
  # model = "qwen3.7-plus"
  # model = "glm-5.2"
  # model = "glm-5.3"
  # model = "glm-5.3-flash"
  # model = "kimi-k3"
  # model = "kimi-k2.7-code"
  # model = "kimi-k2.6"
  # model = "grok-4.6"
  # model = "claude-opus-5"
  # model = "claude-sonnet-5"
  # model = "claude-haiku-4.5"
  # model = "claude-fable-5"
  # model = "gemini-2.5-pro"
  # model = "gemini-2.5-flash"

  model_provider = "aiorouter"

[model_providers.aiorouter]
name = "AIOrouter"
base_url = "https://api.aiorouter.ca/v1"
wire_api = "responses"                # only supported value (official docs)
# Key source: prefer `codex login --with-api-key` (stores the key in
# ~/.codex/auth.json — works for the CLI AND the desktop app without env-var
# inheritance issues). env_key is intentionally commented out below: the desktop
# app's onboarding fails when a provider requires an env var the app cannot see
# (apps launched from the Start menu don't inherit new User env vars until the
# next Windows sign-in). If you DO use env_key instead, the installer sets the
# User env var for you.
# env_key = "AIOROUTER_API_KEY"
# env_key_instructions = "Get your key at https://dashboard.aiorouter.ca/keys"
```

> ⚠️ **切換模型時一次只取消註解一行 `model = ...`**（TOML 不允許重複 key）。
> 想暫時用別的模型而不改預設，用 `codex exec -m <model> "..."`。

### 3.2 Set your API key (do not commit it)

**Desktop app users (Windows):** run `codex login --with-api-key` once and paste
your key — it is stored in `~/.codex/auth.json`, shared by the CLI and the
desktop app. This avoids environment-variable inheritance problems entirely.

**CLI-only users:** either use the same `codex login --with-api-key` command, or
set the env var for your shell session:

```bash
# macOS / Linux
export AIOROUTER_API_KEY=ak-xxxx

# Windows PowerShell
$env:AIOROUTER_API_KEY = "ak-xxxx"
```

> ⚠️ **Never** paste the key into `config.toml`, commit it, or echo it to logs.
> Use your shell's secret store or a secret manager when possible.

### 3.3 Verify

```bash
codex "Hello, are you connected to AIOrouter?"
codex exec -m deepseek-v4-flash "2+2=?"
```

You should see a normal reply. The `provider` in Codex's startup output should
read `aiorouter`, and the model shown should be the AIOrouter model you set.

---

## 4. What you get

| Feature | Behavior |
|:---|:---|
| Models | All AIOrouter models (`deepseek-v4-pro`, `qwen3.7-max`, `glm-5.2`, `kimi-k3`, `grok-4.6`, `claude-*`, `gemini-*`, …) |
| Streaming (SSE) | Supported — `response.created` → `output_text.delta` → `response.completed` |
| Tool calls | `function_call` / `function_call_output` items round-trip correctly |
| PII Shield | Sensitive values (emails, phones, SINs, secrets…) pseudonymized **before** routing, restored on the way back |
| AI Firewall | Chat path is detect-only (v0.4) — injection patterns scanned/logged/FP-captured, never blocking agent work; media/TTS surfaces still block when Shield is active |
| Billing | Metered normally — visible on the dashboard |
| Reasoning models | `reasoning_content` mapped to `reasoning` output items |

---

## 5. Troubleshooting

| Symptom | Cause / Fix |
|:---|:---|
| `PROMPT_INJECTION_DETECTED` | Your deployed Gateway predates the trustedAgent fix. Redeploy with v3.17.x and re-test. |
| `401` / `invalid_api_key` | `AIOROUTER_API_KEY` not set in the shell, or key revoked/expired. Fix: `codex login --with-api-key` (stores the key in `~/.codex/auth.json`, works for CLI and the desktop app without env-var inheritance issues). |
| Desktop app works, then fails with `model not found`-style errors | The app's model menu was used — it overwrote `model` in `config.toml` with an OpenAI ID (5.6/5.5/5.4/5.2…). Fix: quit the app, restore `model = "deepseek-v4-flash"` in `~/.codex/config.toml`, relaunch. Do not switch models from the app menu (it is OpenAI-limited) — say "switch to X" in the chat instead (SKILL), or edit `config.toml` manually (quit the app first so it doesn't overwrite the file while running). |
| `404` on `/v1/responses` | Gateway not deployed with the Responses endpoint, or `ENABLE_RESPONSES_INTEGRATION=false`. |
| Codex shows no tools | Confirm `wire_api = "responses"` is set; the MCP plugin path is a separate integration. |
| Agent update changes prompts | Run the compatibility checker (see §6) to catch firewall conflicts before users are affected. |

---

## 6. Agent / Firewall compatibility checker

AIOrouter ships a monitoring script that scans your local Codex system prompt
against the AI Firewall rules in both scan modes (default and trustedAgent):

```bash
npx tsx scripts/check-agent-firewall-compat.ts          # Codex (reads ~/.codex/models_cache.json)
npx tsx scripts/check-agent-firewall-compat.ts --file <prompt.txt>   # explicit prompt file
```

Exit codes: `0` = PASS, `1` = a prompt triggers a BLOCK, `2` = cache/file error.

---

## 7. Codex App (mobile/desktop)

The Codex App currently supports OpenAI/ChatGPT-account login. API-key provider
login with a custom `base_url` UI is pending official support. Once the app
exposes a provider/base URL setting, point it at:

- Base URL: `https://api.aiorouter.ca/v1`
- Wire API: `responses`
- API key: your `AIOROUTER_API_KEY`

---

## 8. Related

- [Claude Desktop / Claude Code (`/v1/messages`)](claude-integration.md)
- [Codex model switch bridge](codex-model-switch.md)
- MCP plugin integration: `/mcp-integration` on the public site
