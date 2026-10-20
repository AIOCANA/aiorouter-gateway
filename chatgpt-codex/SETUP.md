# ChatGPT / Codex Setup — AIOrouter Gateway

> **Applies to:** ChatGPT desktop app (Codex), Codex CLI
> **Result:** one-line install → the same AIOrouter key works in the desktop app
> and the CLI. No plugin. No local proxy. The route lives in
> `~/.codex/config.toml`, the key in `~/.codex/auth.json`.

The installer writes an OpenAI-compatible provider (`wire_api = "responses"`),
stores the key through `codex login --with-api-key`, and installs the
“switch to X” skill. Say **“switch to X”** in a chat to change models — the app's
own model menu is OpenAI-only and must not be used.

Live guide: <https://aiorouter.ca/codex-integration>

---

## Before you start

1. **Get an API key** at <https://dashboard.aiorouter.ca/keys>. New accounts get
   a one-time free trial (`deepseek-flash` only); Top-Up credits unlock the rest
   of the models on your plan.
2. Install the **ChatGPT desktop app** (Windows/macOS) **or** the **Codex CLI**
   (`codex --version`; v0.146+ recommended).
3. ⚠️ **Quit the ChatGPT/Codex app completely** — including the tray icon. A
   background app can overwrite `~/.codex/auth.json` right after the installer
   writes your key. If unsure, reboot and do not start the app first.

---

## One-line install (recommended)

**Windows (PowerShell):**

```powershell
irm https://aiorouter.ca/setup/install-codex.ps1 | iex
```

**macOS / Linux:**

```bash
curl -fsSL https://aiorouter.ca/setup/install-codex.sh | bash
```

The installer:

1. backs up `~/.codex/config.toml` and `~/.codex/auth.json` (if present);
2. creates/merges the `aiorouter` provider — never overwrites other providers;
3. seeds `~/.codex/aiorouter-catalog.json` and wires it through
   `model_catalog_json` (Codex refuses to load a config whose catalog file is
   missing); the first “switch to X” refreshes it from `GET /v1/models`;
4. asks for the key with masked input and pipes it to
   `codex login --with-api-key` — the key is never written into `config.toml`;
5. prints a short verification prompt for a new chat.

Review the scripts before running them:
[install-codex.ps1](install-codex.ps1) · [install-codex.sh](install-codex.sh)

---

## Manual setup (2 minutes)

Edit `~/.codex/config.toml`. The top-level `model` / `model_provider` lines must
sit **before the first `[table]`**:

```toml
# ── Model switching ─────────────────────────────────────────
#   Say "switch to X" in the app/CLI (skill + bridge).
#   Or uncomment exactly ONE "model =" line below.
# ────────────────────────────────────────────────────────────
model = "deepseek-flash"          # default
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
  # Key lives in ~/.codex/auth.json (set by `codex login --with-api-key`),
  # not in this file. Legacy env_key lines must stay commented out.
```

Store the key (never paste it into `config.toml`):

```bash
codex login --with-api-key     # reads the key from stdin → ~/.codex/auth.json
```

Windows PowerShell equivalent (the installer does this, masked):

```powershell
Read-Host "API key" -AsSecureString | codex login --with-api-key
```

Then make the key available to the CLI process (optional for the desktop app):

```bash
export AIOROUTER_API_KEY="ak-your-key"
```

```powershell
$env:AIOROUTER_API_KEY = "ak-your-key"
```

Verify:

```bash
codex "Hello, are you connected to AIOrouter?"
codex exec -m deepseek-flash "2+2=?"
```

Expected: a normal reply, with `provider: aiorouter` in the startup output.

---

## Verify your setup (30 seconds)

1. [verify/name-placeholder-prompt.md](../verify/name-placeholder-prompt.md) —
   fake identity “Jason Wang”: the model must see a placeholder, not your name.
2. [verify/api-key-redact-prompt.md](../verify/api-key-redact-prompt.md) —
   a fake key must never reach the model; only the masked placeholder.

---

## Troubleshooting

| Symptom | Cause / Fix |
|:---|:---|
| App shows your ChatGPT name, not AIOrouter | A background app overwrote `auth.json`. Quit it fully (tray icon) and re-run the installer. |
| `401` / `invalid_api_key` / `Key revoked` | Key rotated or revoked. Re-run the installer with the new key, then fully quit and relaunch the app. |
| `Missing environment variable: AIOROUTER_API_KEY` | An old uncommented `env_key` line is still in `config.toml`. Re-run the installer (it comments legacy lines) or comment them manually, then `codex login --with-api-key`. |
| Error mentions `api.openai.com` | `base_url` is wrong or the provider block is after a `[table]`. Fix both. |
| App menu changed `model` to an OpenAI id | The app menu is OpenAI-only. Quit the app, restore `model = "deepseek-flash"`, and use “switch to X” instead. |
| `irm ... \| iex` fails with “The term 'Windows' is not recognized” | An old BOM-prefixed copy. Re-download from the URL above; the current file is BOM-free and served as UTF-8. |

---

## Retired paths

The `codex-aiorouter-mas` plugin and the `aiorouter-codex` CLI were retired on
**2026-09-28**. Do not install them for a new setup — the Gateway route above
replaces both. Historical commands remain documented at
<https://aiorouter.ca/codex-integration> for reference only.

---

## Links

- Live setup: <https://aiorouter.ca/codex-integration>
- Full cookbook: <https://aiorouter.ca/docs/cookbook/codex-integration>
- Model catalogue: <https://aiorouter.ca/docs/model-catalog>
- Privacy policy: <https://aiorouter.ca/privacy-policy>
