# ChatGPT / Codex Setup — Say "switch to X" to Change Models

> **Applies to:** ChatGPT desktop app (Codex), Codex CLI + AIOrouter
> **Result:** one-line install (or one prompt) → your AIOrouter key works in the app
> and CLI → **say "switch to X"** in the chat and the AI switches your model for you
> (verified in-app, new chats use the new model immediately — no restart needed).

---

## Before you start (Prerequisites)

1. **Register + get an API key** at [dashboard.aiorouter.ca](https://dashboard.aiorouter.ca)
   — new accounts get a free 7-day trial (`deepseek-v4-flash` only). AIOrouter is a
   **paid service — no free tier** beyond the trial; keys are issued after activation.
2. Install the **ChatGPT desktop app** (Windows/macOS) **or** the **Codex CLI**
   (`codex --version`, v0.146+ recommended).
3. ⚠️ **Quit the ChatGPT/Codex app completely** before installing (including the tray
   icon) — a background app can overwrite `~/.codex/auth.json` right after the
   installer writes your AIOrouter key. If unsure: **reboot Windows** and don't start
   the app before running the command.

---

## Option 0 — One-line install (fastest, recommended)

Run this in a terminal (PowerShell on Windows, Terminal on macOS/Linux):

- **Windows (PowerShell):**
  ```powershell
  irm https://aiorouter.ca/setup/install-codex.ps1 | iex
  ```
- **macOS / Linux (Terminal):**
  ```bash
  curl -fsSL https://aiorouter.ca/setup/install-codex.sh | bash
  ```

The installer:
1. Backs up `~/.codex/config.toml` and `~/.codex/auth.json` (if present).
2. Creates/merges the `aiorouter` model provider into `~/.codex/config.toml`
   (`wire_api = "responses"`) — never overwrites other providers.
3. Prompts for your AIOrouter API key with **masked input** and pipes it to
   `codex login --with-api-key` (stored in `~/.codex/auth.json` — shared by the app
   and CLI). **The key is never written into `config.toml` and never echoed.**
4. Installs the **AIOrouter model-switch SKILL** → after relaunch you can just
   **say "switch to X"**.
5. Prints the Phase 2 continuation prompt — paste it into a NEW chat after relaunch.

Scripts are also in this repo for review:
[install-codex.ps1](install-codex.ps1) / [install-codex.sh](install-codex.sh).

---

## Option 1 — One prompt (AI does the setup)

Paste the full prompt from
[one-prompt/codex-install-prompt.md](../one-prompt/codex-install-prompt.md) into the
ChatGPT/Codex chat. The AI will: set up your key (never pasted into the chat), write
`~/.codex/config.toml`, **install the SKILL** (downloaded from
`https://aiorouter.ca/setup/aiorouter-model-switch.skill.md`), write the AGENTS.md
fallback procedure, then guide you through restart + verification.

---

## Switching models — say "switch to X"

After install (either option), open a new chat and say:

> **"switch to qwen3.7-max"** (or any model slug)

The AI (via the SKILL) edits exactly one `model =` line in `~/.codex/config.toml`
(after backing it up), verifies the change, and confirms. **New chats use the new
model immediately — no restart needed** (verified in-app, 2026-08-09).

Supported triggers: "switch to / change to / use <model>".

**Fallbacks if you don't want the SKILL:**
- CLI per-run: `codex exec -m <model> "your prompt"`
- Manual: uncomment exactly ONE `model = "..."` line in `~/.codex/config.toml`
  (quit the app first so it doesn't overwrite the file while running).

> ⚠️ The app's model menu is OpenAI-limited (hardcoded) — do NOT use it to switch;
> say "switch to X" in the chat instead (or edit `config.toml` manually with the app
> fully closed).

---

## Manual setup (if you prefer to do it yourself)

Create `~/.codex/config.toml`:

```toml
# ── How to switch models ────────────────────────────────────
#   1. Say "switch to X" in the app/CLI (SKILL + bridge).
#      New chats use the new model immediately — no restart.
#   2. Or uncomment exactly ONE "model =" line below.
#   3. Per run (CLI):  codex exec -m <model> "your prompt"
# ────────────────────────────────────────────────────────────
# MODEL — uncomment exactly ONE line (default = deepseek-v4-flash).
# Full 19-model list: https://aiorouter.ca/docs/model-catalog
model = "deepseek-v4-flash"      # default
# model = "deepseek-v4-pro"
# model = "qwen3.7-max"
# model = "glm-5.2"
# model = "grok-4.5"

model_provider = "aiorouter"

[model_providers.aiorouter]
name = "AIOrouter"
base_url = "https://api.aiorouter.ca/v1"
wire_api = "responses"
env_key = "AIOROUTER_API_KEY"
env_key_instructions = "Get your key at https://dashboard.aiorouter.ca/keys"
```

Set your key (never paste it into `config.toml`):

```bash
# macOS / Linux
export AIOROUTER_API_KEY=ak-your-key

# Windows PowerShell
$env:AIOROUTER_API_KEY = "ak-your-key"
```

Verify:

```bash
codex "Hello, are you connected to AIOrouter?"
codex exec -m deepseek-v4-flash "2+2=?"
```

Expected: normal reply; Codex startup output shows `provider: aiorouter` and your
model.

---

## Verify your setup (30 seconds)

Paste these prompts in a chat to prove the PII Shield is active:

1. [verify/name-placeholder-prompt.md](../verify/name-placeholder-prompt.md) — fake
   identity "Jason Wang": the LLM must say it sees a placeholder, never your real name.
2. [verify/api-key-redact-prompt.md](../verify/api-key-redact-prompt.md) — fake key:
   the LLM must refuse to echo it.

---

## Troubleshooting

| Symptom | Cause / Fix |
|:---|:---|
| App shows your ChatGPT name instead of "AIOrouter" | A background app overwrote `auth.json`. Fully quit (tray icon) → re-run the installer. |
| `401` / `invalid_api_key` | Key not set or revoked. Re-run `codex login --with-api-key`, or set `AIOROUTER_API_KEY`. |
| "Missing environment variable: AIOROUTER_API_KEY" | Key not picked up. Re-run `codex login --with-api-key`, fully restart, retry. |
| Error mentions `api.openai.com` | `base_url` is wrong — requests are going to OpenAI. Fix `base_url = "https://api.aiorouter.ca/v1"`. |
| App menu switching broke `model` in config | The app's menu overwrote `model` with an OpenAI ID. Quit the app → restore `model = "deepseek-v4-flash"` → relaunch. Don't use the app menu; say "switch to X". |

---

## Deep-dive reference

- [docs/mcp-integration.md](../docs/mcp-integration.md) — advanced MCP tools (10 tools)
  for Claude Code / Codex CLI users (separate optional package)
- Canonical 19-model list: [docs/model-catalog-link.md](../docs/model-catalog-link.md)
- [docs/privacy-policy.md](../docs/privacy-policy.md) — data handling