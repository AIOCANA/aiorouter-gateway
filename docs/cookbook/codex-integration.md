# Codex CLI Integration (Responses API / `wire_api = "responses"`)

> **Doc type:** Cookbook — user-facing setup guide
> **Version:** v1.4.0 | **Date:** 2026-10-19
> **Author:** AIRO (deepseek-flash)

Use **OpenAI Codex CLI** (and, when official support lands, the Codex App) directly
  with your **AIOrouter API key** (`ak-...`) to access all 14 models — DeepSeek,
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
    (25,000 tokens / 7 days, `qwen3.8-flash` only). One-time Top-Up
    credits (from $10 CAD, balance never expires) unlock all 14 models; your
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
  # MODEL — uncomment exactly ONE line (default = deepseek-flash).
  # Full model list: https://aiorouter.ca/docs/model-catalog
  model = "deepseek-flash"      # default
  # model = "qwen3.8-max"
  # model = "qwen3.8-flash"
  # model = "qwen3.7-plus"
  # model = "glm-5.2"
  # model = "glm-5.3"
  # model = "kimi-k3"
  # model = "grok-4.7"
  # model = "claude-opus-5-5"
  # model = "claude-sonnet-5"
  # model = "claude-haiku-5-5"
  # model = "claude-fable-5-1"
  # model = "gemini-3.8-flash"

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
codex exec -m deepseek-flash "2+2=?"
```

You should see a normal reply. The `provider` in Codex's startup output should
read `aiorouter`, and the model shown should be the AIOrouter model you set.

---

## 4. What you get

| Feature | Behavior |
|:---|:---|
| Models | All AIOrouter models (`deepseek-flash`, `qwen3.8-max`, `glm-5.2`, `kimi-k3`, `grok-4.7`, `claude-*`, `gemini-*`, …) |
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
| `PROMPT_INJECTION_DETECTED` | The chat path is detect-only on current releases — this should not block legitimate agent work. If you still see it, contact support. |
| `401` / `invalid_api_key` | `AIOROUTER_API_KEY` not set in the shell, or key revoked/expired. Fix: `codex login --with-api-key` (stores the key in `~/.codex/auth.json`, works for CLI and the desktop app without env-var inheritance issues). |
| Desktop app works, then fails with `model not found`-style errors | The app's model menu was used — it overwrote `model` in `config.toml` with an OpenAI ID (5.6/5.5/5.4/5.2…). Fix: quit the app, restore `model = "deepseek-flash"` in `~/.codex/config.toml`, relaunch. Do not switch models from the app menu (it is OpenAI-limited) — say "switch to X" in the chat instead (SKILL), or edit `config.toml` manually (quit the app first so it doesn't overwrite the file while running). |
| `404` on `/v1/responses` | The Responses endpoint is not available for your account — check the model catalog docs for the supported endpoint, or contact support. |
| Codex shows no tools | Confirm `wire_api = "responses"` is set; the MCP plugin path is a separate integration. |
| Agent update changes prompts | Firewall behavior on the chat path is detect-only by design — an agent update cannot trigger a false block on your own prompts. |

---

## 6. Codex App (mobile/desktop)

The Codex App currently supports OpenAI/ChatGPT-account login. API-key provider
login with a custom `base_url` UI is pending official support. Once the app
exposes a provider/base URL setting, point it at:

- Base URL: `https://api.aiorouter.ca/v1`
- Wire API: `responses`
- API key: your `AIOROUTER_API_KEY`

---



---

## 7. Legacy track — the one-prompt setup (full text)

> **Legacy.** New installs should configure the **AIOrouter Gateway route** instead
> (one-line setup: `irm https://aiorouter.ca/setup/install-codex.ps1 | iex` on Windows,
> `curl -fsSL https://aiorouter.ca/setup/install-codex.sh | bash` on macOS/Linux — see the
> [Codex integration page](/codex-integration)). The `codex-aiorouter-mas` plugin and the
> `aiorouter-codex` CLI are **retired (2026-09-28)**. This appendix keeps the historical
> AI-assisted one-prompt flow in full so existing installs can still follow it.

### Phase 1 — paste once, before restart

```text
Please set up AIOrouter × Codex for me. Do the following in order:

【0】Account note — tell me this clearly before starting:
- You will sign in with a FREE ChatGPT account once to install Codex.
- After that you switch to your AIOrouter API key (codex login --with-api-key).
- All model usage is then billed by AIOrouter, not OpenAI.

【0】Check what is installed:
- Run codex --version. If Codex is not installed, tell me how to install it
  first and stop.
- Check if ~/.codex/ exists. Do NOT modify anything yet.

  【1】Set up the AIOrouter API key (Key FIRST — never paste it into this chat):
- If I don't have a key yet, guide me to register FREE at
  https://dashboard.aiorouter.ca (email + MFA) — my first key is issued
  immediately with a free trial (25,000 tokens / 7 days,
  qwen3.8-flash). No payment needed to start.
- Trial covers qwen3.8-flash only. Want to use all 14 models (DeepSeek,
    Qwen, GLM, Kimi, Grok, Claude, Gemini) at full quota? Subscribe from the
    Dashboard — secure Stripe checkout (Visa/MC/Amex, CAD, we never store your
    full card number), Top-Up pay-as-you-go. Same key keeps working — no re-setup.
- Your key also works with other BYOK tools (VS Code, KILO CODE, CLINE,
  Copilot, and AIOrouter's own CODE-MAS) — you are never locked into one tool.
- If I already have a key (trial or paid), continue directly.
  - If ~/.codex/auth.json already contains a ChatGPT login, warn me that
    switching to an API key will REPLACE it, and ask for my confirmation first.
    Do NOT proceed until I say yes.
  - ⚠️ ALSO tell me (if a ChatGPT login exists): my previous chat sessions are
    NOT deleted — Codex groups session history by login method. After switching
    to the AIOrouter API key, sessions created under my ChatGPT subscription
    will be hidden (not lost). They come back if I log in with ChatGPT again.
  - Back up ~/.codex/auth.json first (auth.json.bak) and ~/.codex/config.toml
    (config.toml.bak) BEFORE making any change, so I can restore my previous
    login later.
- Open a PowerShell window: run
      start powershell -NoExit
  ⚠️ If Codex shows a permission/authorization request at the bottom of the
  chat input (e.g. "allow Codex to run this command"), I must click ALLOW —
  please remind me to check for that button.
  If you cannot start PowerShell (no permission), just tell me to open a
  PowerShell window myself (Windows key → type "powershell" → Enter).
- Tell me to paste this ENTIRE block into that PowerShell window (all 5 lines
  at once, then press Enter):
      $s = Read-Host "Paste your AIOrouter key" -AsSecureString
      $b = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($s)
      $p = [System.Runtime.InteropServices.Marshal]::PtrToStringBSTR($b)
      $p | codex login --with-api-key
      [System.Runtime.InteropServices.Marshal]::ZeroFreeBSTR($b)
  Expected behavior: PowerShell pauses at "Paste your AIOrouter key:" — I paste
  the key (masked) and press Enter. Then it should print
  "Reading API key from stdin..." then "Successfully logged in".
  Note: the final line will echo back in the window — that is normal, not an error.
- If anything other than "Successfully logged in" appears, STOP and tell me
  what you see.
- After I say "done", verify WITHOUT printing the key:
      Test-Path "$env:USERPROFILE\.codex\auth.json"
  and confirm the file no longer contains a ChatGPT account login.
- Only continue to 【2】 after the key is confirmed stored.

【2】Make sure ~/.codex/config.toml has the FULL AIOrouter setup — write the
  ENTIRE block below, every line, exactly as shown. Do NOT omit the
  [model_providers.aiorouter] section. Do NOT add any settings that are not
  in the template (e.g. do NOT add model_reasoning_effort, notify, or any
  other key unless it was already in the file).
  - If the file does not exist, create it from the template below (all lines).
  - If it exists but has no aiorouter provider, MERGE the whole block in —
    keep unrelated existing lines (like notify = [...]), keep other provider
    sections, do NOT delete or modify them.
  - If model_provider is currently NOT "aiorouter", tell me that this will
    switch my default provider and ask before changing.
  - Back up the file first (config.toml.bak) if you edit it.
- Template — write ALL of these lines:
      # MODEL — uncomment exactly ONE line (default = deepseek-flash).
      # Full model list: https://aiorouter.ca/docs/model-catalog
      model = "deepseek-flash"      # default
      # model = "qwen3.8-max"
      # model = "qwen3.8-flash"
      # model = "qwen3.7-plus"
      # model = "glm-5.2"
      # model = "glm-5.3"
      # model = "kimi-k3"
      # model = "grok-4.7"
      # model = "claude-opus-5-5"
      # model = "claude-sonnet-5"
      # model = "claude-haiku-5-5"
      # model = "claude-fable-5-1"
      # model = "gemini-3.8-flash"
      model_provider = "aiorouter"
    [model_providers.aiorouter]
    name = "AIOrouter"
    base_url = "https://api.aiorouter.ca/v1"
    wire_api = "responses"
    env_key = "AIOROUTER_API_KEY"
    env_key_instructions = "Get your key at https://dashboard.aiorouter.ca/keys"
  - Important: model / model_provider must stay at the TOML top level (before
    the [model_providers.*] table). The [model_providers.aiorouter] section
    with base_url/wire_api/env_key is REQUIRED — without it Codex sends
    requests to OpenAI instead of AIOrouter.
  - After writing, RE-READ the file and verify EVERY item, then report PASS or
    FAIL for each:
    [1] model = "deepseek-flash" present (exactly one uncommented model line)
    [2] the commented model list (# model = ...) present
    [3] model_provider = "aiorouter" present at top level
    [4] [model_providers.aiorouter] section present
    [5] base_url = "https://api.aiorouter.ca/v1" present and NOT empty
    [6] wire_api = "responses" present
    [7] env_key = "AIOROUTER_API_KEY" present
    [8] NO extra keys added (no model_reasoning_effort, no notify unless it
        was already there)
    If ANY item FAILS, STOP and tell me exactly which one — do not continue.
  - If you cannot write to this file (permission denied), STOP and tell me — I
  will use the manual / one-click script method instead.

【3】Install the AIOrouter model-switch SKILL so I can just SAY "switch to X":
    - Download https://aiorouter.ca/setup/aiorouter-model-switch.skill.md
      and write it to ~/.codex/skills/aiorouter-model-switch/SKILL.md
      (create the directory if missing; back up any existing file first).
    - If the file already exists and is recent, skip.
    - If the network is blocked, fall back to writing the AGENTS.md procedure
      (the text below) instead — same behavior, just less deterministic.
    - Then append the AGENTS.md fallback procedure below to ~/.codex/AGENTS.md
      (add only; do not delete other content). Write this EXACT text — every line:

  ## AIOrouter model switch procedure
  When the user asks to "switch to / change to / use <model>":
  1. Read ~/.codex/config.toml
  2. Confirm model_provider = "aiorouter"; if not, tell the user you cannot
     proceed
  3. Determine if <model> is supported:
     a. Check the commented "model =" list in ~/.codex/config.toml
     b. If not there, fetch https://aiorouter.ca/docs/model-catalog (canonical
        list)
     c. If the network is blocked, tell the user you could not verify the
        catalog and list the local models you know about
  4. If <model> is not supported → refuse, list available models, ask the user
     to re-specify. Do NOT edit config.toml.
  5. Edit config.toml (back it up first as config.toml.bak):
     - Change the currently uncommented model = "..." line to the target model
     - Keep exactly ONE uncommented "model =" line; leave all others commented
     - If the target model line does not exist yet, add it (commented) first,
       then uncomment it — this keeps the local list up to date
     - Do NOT change model_provider / base_url / env_key or anything else
     - Do NOT add any new keys (no model_reasoning_effort, no notify, etc.)
6. Re-read config.toml to verify: exactly one uncommented "model =" line and
       model_provider is still "aiorouter", and NO extra keys were added, then
       say: "Switched to <model> — new chats use it immediately (no restart needed)."

【4】Restart Codex completely — END of Phase 1 (setup):
    - Desktop app: tell me to quit (including the tray icon) and relaunch once,
      so it loads the new config — a normal Phase 1 step. If possible, suggest a
      full Windows restart — closing the window alone may leave the app running
      in the background.
    - CLI: tell me to open a NEW terminal window (the new session loads the new
      config.toml and key).
    - Switching models later does NOT require quitting: just say "switch to X"
      in the chat (SKILL + bridge) — new chats use the new model immediately.
    - Remind me: the app's model menu is OpenAI-limited (hardcoded) — don't use
      it to switch; say "switch to X" in the chat instead.
    - 🔄 IMPORTANT (restart breaks this conversation): after I relaunch, this
      chat session is GONE. Tell me clearly: "After restart, open a new chat and
      paste the 'Phase 2 — continue after restart' prompt below."
```

### Phase 2 — paste into a NEW chat after restart

```text
I just restarted Codex after setting up AIOrouter (API key, config.toml,
AGENTS.md). Please finish verifying and enable my setup:

【5】Verify the connection — the "wow" test:
- Desktop app: I should see my account name at the bottom-left showing
  "AIOrouter" (not a ChatGPT/OpenAI account). Ask me to confirm that.
- Then ask me to paste this verification PROMPT in the main chat:
      My name is Jason Wang. What's the second letter of my first name?
      Please type my name here and let me know what LLM see in my name.
  Expected: the LLM says it sees a placeholder (e.g. "Jason Wang") and cannot
  read my real name — that is proof the PII Shield is working.
- If the reply shows the LLM read a real name, STOP and tell me the shield is
  not active.
- (CLI users only) In a fresh terminal: codex exec -m deepseek-flash "2+2=?"
  → expect "4" and output showing provider: aiorouter.
- If it fails with "Missing environment variable: AIOROUTER_API_KEY", the key
    was not picked up — re-run codex login --with-api-key; also comment out any
    leftover uncommented "env_key = ..." line in ~/.codex/config.toml
    (auth.json-first; the re-run installer does this automatically), fully
    restart the app (incl. tray icon), then retry.
- ⚠️ If the error mentions "api.openai.com" or "Incorrect API key", STOP and
  tell me "base_url is wrong — requests are going to OpenAI instead of
  AIOrouter" — the config.toml base_url must be https://api.aiorouter.ca/v1.
- Only say "setup complete" after the verification succeeds.

【6】Explain how AIOrouter protects me — a short, friendly technical summary:
- Tell me (in plain language, 3-4 short sentences):
  1. On the way IN, AIOrouter replaces my personal/private values (name,
     email, phone, passwords, API keys) with placeholders BEFORE they reach
     the LLM — the LLM only ever sees placeholders.
  2. On the way BACK, AIOrouter restores the placeholders to my real values
     (Restore) or keeps them redacted (Redact), exactly as I configured in
     the Dashboard — that's why I see my correct name in the reply even
     though the LLM said it saw a placeholder.
  3. For security secrets (passwords, API keys) the default is Redact — so
     they come back as [REDACTED ...] and the AI can never write my real
     password into any file or reply.
  4. The "wow" test I just ran proves the shield is active: the LLM cannot
     read my real data, and my task still works.
- Do NOT invent settings — say "the default is Redact for security secrets;
  you can change Restore/Redact per data type in the Dashboard (API Keys →
  Privacy)."
  - End with: "You're fully set up. From now on, just say 'switch to X' and I'll
    change the model for you."

  【7】(Optional) A short note about my plan:
  - I'm currently on the free trial (25,000 tokens / 7 days,
      qwen3.8-flash only). To unlock all 14 models at full quota: open
      dashboard.aiorouter.ca → Billing → Add Top-Up credits (one-time packs
      from $10 CAD). Checkout is secured by Stripe (Visa/MC/Amex, CAD) — we
      never store my full card number. My key keeps working — no re-setup, and
      it works with many BYOK tools.
```

---

## 8. Related

- [DeepSeek Harness setup](deepseek-harness-setup.md)
- [Codex model switch bridge](codex-model-switch.md)
- MCP plugin integration: `/mcp-integration` on the public site
