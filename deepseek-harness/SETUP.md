# DeepSeek Harness (dsh) Setup — 19 AI models with one AIOrouter key

> **Applies to:** DeepSeek Harness (`dsh`) the local profile-based AI coding harness
> **Result:** one-line install → `dsh` runs on 19 AI models (DeepSeek, Qwen, GLM, Kimi,
> Grok, Claude, Gemini) with one AIOrouter key — PII Shield and AI Firewall applied
> before every route, model catalog auto-syncs from the gateway.

---

## Before you start (Prerequisites)

1. **Register + get an API key** at [dashboard.aiorouter.ca](https://dashboard.aiorouter.ca)
   — new accounts get a free 7-day trial (`deepseek-v4-flash` only). AIOrouter is a
   **paid service — no free tier** beyond the trial; keys are issued after activation.
2. **Node.js >= 20** installed (`node --version`). `dsh` is installed via npm.
3. Optional: **`dsh` Web UI** runs locally at `http://localhost:3080` (the profile used
   by the Web UI is `web` — any profile name works the same).

---

## Option 0 — One-line install (fastest, recommended)

Run this in a terminal (PowerShell on Windows, Terminal on macOS/Linux):

- **Windows (PowerShell):**
  ```powershell
  irm https://aiorouter.ca/setup/install-dsh.ps1 | iex
  ```
- **macOS / Linux (Terminal):**
  ```bash
  curl -fsSL https://aiorouter.ca/setup/install-dsh.sh | bash
  ```

The installer:
1. Checks Node.js >= 20 and installs `dsh` globally if missing (`npm i -g dsh`).
2. Adds the **`@aiorouter/dsh-shield` plugin** to the profile
   (`dsh plugin --profile <name> add @aiorouter/dsh-shield` — default profile `web`).
3. Prompts for your AIOrouter API key with **masked input** and sets it as the
   `AIOROUTER_API_KEY` environment variable (User scope on Windows / shell profile on
   macOS/Linux). **The key is never echoed and never written in plaintext.**

Scripts are also in this repo for review:
[install-dsh.ps1](install-dsh.ps1) / [install-dsh.sh](install-dsh.sh).

---

## Option 1 — Manual setup (3 steps)

1. **Install the harness:**
   ```bash
   npm i -g dsh
   ```
2. **Add the plugin to the profile:**
   ```bash
   dsh plugin --profile web add @aiorouter/dsh-shield
   ```
   (The Web UI profile is `web`; use any other profile the same way.)
3. **Set your key:** open the configuration — in the `dsh` Web UI go to
   **Settings → Models** and set `AIOROUTER_API_KEY = ak-your-key`, or export it in
   your shell profile:
   ```bash
   export AIOROUTER_API_KEY=ak-your-key
   ```

---

## Changing models

`dsh` profiles can switch models at any time (19 models, gateway-synced). The full
model list with pricing: https://aiorouter.ca/docs/model-catalog

The **`aiorouter_shield_status` tool** is available in any session: it shows your
account card (balance, privacy policy, Shield state) and a per-session protection
summary — metadata only, never your data.

---

## What the plugin adds

| Feature | How it works |
|:---|:---|
| 🛡️ Privacy policy header (GW-2) | `restore-all` / `redact-secrets` (default) / `redact-all` — settable in Settings → AIOrouter Shield |
| ♻️ Restoration markers (GW-1) | `plain` (default, clean values) / `markdown` — restored PII values never leak into transcripts |
| 📊 `aiorouter_shield_status` | Account card + per-session protection summary — metadata only |
| 🔄 Model-catalog auto-sync | New gateway models appear automatically (union-merge, every 6 h by default; 0 = at boot) |
| 📦 Update check | Shows "📦 Update available: X → Y" + the `dsh plugin --profile web update @aiorouter/dsh-shield` command |

---

## Verify your setup (30 seconds)

Start a session and paste:

> `My name is Jason Wang. What is the second letter of my first name?`

Expected: the LLM says it sees a placeholder and **cannot read your real name** —
proof the PII Shield is active and your sensitive data never leaves the gateway
unprotected.

---

## Troubleshooting

| Symptom | Cause / Fix |
|:---|:---|
| `dsh` command not found after install | Restart the terminal so the npm global bin is on `PATH` (Windows: new PowerShell window). |
| `Plugin @aiorouter/dsh-shield not found` | The package may not be installed yet — run `dsh plugin --profile web add @aiorouter/dsh-shield` again. |
| `401` / `invalid_api_key` / `Key revoked` | The API key was rotated/revoked on the dashboard. Set the new key in Settings → Models (or re-run the installer). |
| "Missing environment variable: AIOROUTER_API_KEY" | The shell did not inherit the env var. Windows: sign out/in (User-scope vars) or set it in Settings → Models instead. macOS/Linux: re-source your shell profile. |
| Error mentions `api.deepseek.com` | Requests are going to DeepSeek direct — the profile must point at AIOrouter (`https://api.aiorouter.ca/v1`). Switch the model/provider in Settings → Models. |

---

## Deep-dive reference

- Full setup + plugin details: [docs/cookbook/deepseek-harness-setup.md](../docs/cookbook/deepseek-harness-setup.md)
- Canonical 19-model list: [docs/model-catalog-link.md](../docs/model-catalog-link.md)
- [docs/privacy-policy.md](../docs/privacy-policy.md) — data handling
