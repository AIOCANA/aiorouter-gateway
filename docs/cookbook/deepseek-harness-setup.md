# DeepSeek Harness (dsh) Setup — run every AIOrouter model with one key

> **Doc type:** Cookbook — user-facing setup guide
> **Version:** v1.6.0 | **Date:** 2026-10-19
> **Author:** AIRO
>
> ✅ **Verified with DeepSeek Harness 0.2.1-rc.2 (2026-10-19).** DSH is in preview
> and ships frequently; this page is re-checked against each `latest` build. If
> your build is newer and the route does not appear, see §8.1.

Use **DeepSeek Harness (dsh)** — a local, model-agnostic AI coding harness — with
your **AIOrouter API key** (`ak-...`) through the **AIOrouter Gateway**: one
OpenAI-compatible route that serves every model on your plan, with PII Shield and
AI Firewall protection applied server-side, and no plugin required.


```
dsh (local harness) ── OpenAI-compatible ──► https://api.aiorouter.ca/v1
                                         └─ PII Shield → AI Firewall (detect-only) → billing → router
                                         └─ DeepSeek / Qwen / GLM / Kimi / Grok / Claude / Gemini
```

## 1. Quickstart (30 seconds)

1. Create an API key at **https://dashboard.aiorouter.ca** and copy it.
2. Configure the route with one command (needs Node ≥ 22; the script also offers
   to install dsh when it is missing, asks for your key with masked input, writes
   `api: openai-completions` + the route into `~/.dsh/settings.yaml`, verifies the
   key live against `GET /v1/models`, and checks that the route block dsh will
   load is complete):

   ```powershell
   irm https://aiorouter.ca/setup/install-dsh.ps1 | iex   # Windows PowerShell
   ```

   ```bash
   curl -fsSL https://aiorouter.ca/setup/install-dsh.sh | bash   # macOS / Linux
   ```

   (Prefer to wire it by hand? §4.2 shows the exact block — it is
   `llm-pi-ai.providers.aiorouter`, and it needs `api:` plus at least one
   `models:` id. Note the harness npm package is `@deepseek-ai/dsh`; a bare
   `dsh` on npm is an unrelated package.)
3. Restart the Web profile so the harness re-reads `settings.yaml`:

   ```bash
   dsh --profile web
   ```
4. Open **Settings → Models** — the AIOrouter route is listed. Its menu shows the
   ids synced into the route by the setup command; the harness does not poll the
   gateway, so see §6 when you want to refresh the list.

That is it — **no plugin is involved**. Requests go straight to
`https://api.aiorouter.ca/v1` with your key and are protected by the PII Shield
and AI Firewall before routing; your privacy policy is governed per key in the
Dashboard. The script never writes your key into the repo or into
`settings.yaml`: Windows stores it as a user environment variable, macOS/Linux
as a marked `export` line in your shell profile, which the route resolves via
`apiKeyEnv`.

> **Plugin retired (2026-09-28).** Earlier versions of this page installed the
> `@aiorouter/dsh-aiorouter-mas` plugin. That plugin (and the Codex plugin
> line) is now **deprecated** and is no longer needed for model access — the
> Gateway route above replaces it. Already have it installed? §7 shows the
> removal.

## 2. How it works

dsh is a profile-based harness: you boot a *profile* (a layer stack of plugin
bundles + your overrides). The **AIOrouter Gateway route** gives you:

1. **The `aiorouter` provider route** — an `openai-completions` provider pointed
   at `https://api.aiorouter.ca/v1`. Every request is protected by the PII
   Shield and AI Firewall **before** routing to the model provider: the chat
   path runs the AI Firewall in detect-only mode — it scans and logs injection
   patterns without interrupting your agent's work. Restore/redact behaviour is
   the policy on your **key** (Dashboard → API Keys → Privacy), applied
   server-side for every client — no harness-side configuration to keep in sync.
2. **One key, every model** — the route exposes your account's catalog
   (`GET /v1/models`); the chat model is whatever you pick in the dsh UI, and
   the gateway never overrides that choice.
3. **Nothing extra to install** — no plugin, no local gateway process, no extra
   service: the route is plain configuration in `settings.yaml`.
4. **Status & cost facts** — your Dashboard is the billing source of truth
   (`GET /v1/me/usage` returns the same figures programmatically). The retired
   plugin's in-session `aiorouter_status` / `aiorouter_cost` tools no longer
   exist — model access needs no plugin, and usage lives in the Dashboard.
5. **Your catalog, as-is** — the route serves every model on your AIOrouter plan
   (`GET /v1/models`); the setup command syncs those ids into your route's model
   list, and the chat model is whatever you pick in the dsh UI — the gateway
   never overrides that choice. See §6 for how to keep the list current.

## 3. Prerequisites

- **Node.js ≥ 22** and **npm** installed on your machine (the `web` profile's
  live-patch service needs Node 22+; on Node 20/21 the host quits seconds after
  boot). **pnpm** is required to manage plugins — install with
  `npm i -g pnpm` if you don't have it yet.
- **AIOrouter account + API key** (`ak-...`) from
  <https://dashboard.aiorouter.ca/keys>. New accounts get a one-time free trial
  (see the trial note on the setup page). One-time Top-Up credits unlock every
  model; your same API key keeps working.

## 4. Setup (2 minutes)

### 4.1 Install the harness

```bash
npm i -g @deepseek-ai/dsh
dsh --version
```

> ⚠️ The npm package is scoped: **`@deepseek-ai/dsh`**. A bare `dsh` on npm is
> an unrelated old package and provides no such CLI.

### 4.2 Add the AIOrouter Gateway route

With the harness installed, the route is one configuration block. `api` and at
least one `models:` entry are **mandatory**: `aiorouter` is not in pi-ai's
built-in catalogue, and a route without `api` never registers — dsh then reports
`NO_ADAPTER: no adapter registered for provider "aiorouter"`. The one-line script
from §1 does exactly this (and appends every other model on your account):

```yaml
# ~/.dsh/settings.yaml
llm-pi-ai:
  providers:
    aiorouter:
      api: openai-completions
      baseURL: https://api.aiorouter.ca/v1
      apiKeyEnv: AIOROUTER_API_KEY
      headers: {}
      models:
        - id: deepseek-flash
```

> 💡 The block above is the **minimum that makes the route register** when you
> wire it by hand. Re-run the §1 command (or
> `node aiorouter-gateway-setup.mjs --sync-models`) afterwards to append the
> rest of your account's catalogue.

> ⚠️ **Then restart `dsh --profile web`.** The harness reads `settings.yaml` at
> boot, so a session that was already running will not see the route until the
> next start.

> 💡 **Profile naming.** The examples use the Web profile (`web`); any profile
> works the same — the settings file and the route are profile-independent.

### 4.3 Set your API key

Provide the key through the environment variable the route references
(`apiKeyEnv: AIOROUTER_API_KEY`). The one-line script stores it for you
(Windows: user environment variable; macOS/Linux: a marked `export` line in
your shell profile); by hand:

```powershell
[Environment]::SetEnvironmentVariable('AIOROUTER_API_KEY', 'ak-...', 'User')   # Windows
```
```bash
export AIOROUTER_API_KEY='ak-...'    # macOS / Linux (add to ~/.zshrc to persist)
```

The key is never written into `settings.yaml` and is sent only to
`https://api.aiorouter.ca/v1`. Restart the harness so the variable is visible.

### 4.4 Migrating from the retired plugin

> **The `@aiorouter/dsh-aiorouter-mas` plugin (and `@aiorouter/dsh-shield`
> before it) is deprecated as of 2026-09-28.** Model access needs no plugin —
> the Gateway route above replaces it, and privacy protection is governed on
> your key in the Dashboard either way.

If you installed it earlier, remove it (see §7) and keep using the route.

### 4.5 Already have dsh installed? Paste this prompt

If the harness is already installed and running, skip the terminal walkthrough
and give the prompt below to your dsh agent. It downloads the official
configurator, writes the route in write-only mode, checks it, and — only if
`AIOROUTER_API_KEY` is already set — syncs your full catalogue. It never asks for
the key in chat.

> **Before you paste:** the key must already be in `AIOROUTER_API_KEY` for step 4
> to run. If it is missing, the agent stops after step 2 and tells you how to set
> it. Never paste the key into the conversation.

```text
Configure the AIOrouter Gateway route for this DeepSeek Harness installation.

Rules:
- Never ask me to paste an API key into this chat.
- Do not restart the harness; tell me when I should.
- Stop and report if a step fails.

Steps:
1. Report `dsh --version` and `node -v` (Node must be 22 or newer).
2. Download the official configurator and run it in write-only mode. It backs up
   ~/.dsh/settings.yaml, writes the aiorouter route with api: openai-completions
   and a starter model, and does not need my key.
   Windows (PowerShell):
     Invoke-WebRequest https://www.aiorouter.ca/setup/aiorouter-gateway-setup.mjs -OutFile "$env:TEMP\aiorouter-gateway-setup.mjs"
     node "$env:TEMP\aiorouter-gateway-setup.mjs" --no-sync
   macOS / Linux:
     curl -fsSL https://www.aiorouter.ca/setup/aiorouter-gateway-setup.mjs -o /tmp/aiorouter-gateway-setup.mjs
     node /tmp/aiorouter-gateway-setup.mjs --no-sync
3. Run the route check with the same script and paste its output:
     node the-same-script-path --check-route
4. If AIOROUTER_API_KEY is set in your environment, sync my full model catalogue:
     node the-same-script-path --sync-models
   If it is not set, skip this step and tell me how to set it — do not ask for the value.
5. Tell me to restart `dsh --profile web`, then to open Settings → Models and
   confirm the AIOrouter route is listed.

If DSH_HOME is set, append `--settings "$DSH_HOME/settings.yaml"` to every node
command above.
```

## 5. Switch models

The aiorouter route lists the gateway catalog ids synced into your config (see §6). In the
dsh UI pick any model per conversation; in headless/CLI mode select with the
provider+model args. The default agent model lets you use the free trial
immediately after getting your key.

## 6. Model catalog — keeping your list current

Your model list is whatever your AIOrouter account serves — check it any time:

```bash
curl -H "Authorization: Bearer $AIOROUTER_API_KEY" https://api.aiorouter.ca/v1/models
```

The dsh model menu lists exactly the ids configured for the route; the gateway
does not push into installed clients. We publish new models regularly, and there
are two supported ways to see them in your menu:

- **Re-run the setup command from §1** (safe to repeat any time). It pulls
  `GET /v1/models` and **appends** any new ids to your route's model list —
  additive merge: your custom entries are never removed, and `settings.yaml` is
  backed up before anything is written.
- **Settings → Models → Fetch available models** in the dsh UI — probes the
  route and lets you adopt new ids interactively. (The menu itself is a static
  snapshot of the route's `models:` list; dsh does not poll the gateway in the
  background.)

> **A note on old wording.** Earlier versions of this page described a
> `modelRefreshMinutes` background auto-sync. That was a feature of the retired
> AIOrouter dsh plugin (deprecated 2026-09-28), not of the gateway route. With
> the plugin retired, re-running the setup command is the supported refresh path
> — it needs no plugin and no resident process.

## 7. Removing the retired plugin (legacy)

The `@aiorouter/dsh-aiorouter-mas` plugin (and its absorbed predecessor
`@aiorouter/dsh-shield`) was **deprecated on 2026-09-28**. Model access needs no
plugin — the Gateway route in §4.2 replaces it — and the package is no longer
maintained. If you installed it earlier, remove it so the profile stays minimal:

```bash
dsh plugin --profile web remove @aiorouter/dsh-aiorouter-mas
dsh plugin --profile web remove @aiorouter/dsh-shield      # only if you ever installed it
```

Then restart `dsh --profile web`. Your route and key are unaffected — the route
is plain configuration, not plugin code. If your harness ever reports a plugin
load error, this removal is the fix.

## 8. Verify

| Check | Command / UI | Expected |
|:---|:---|:---|
| Route exists | `~/.dsh/settings.yaml` → `llm-pi-ai.providers.aiorouter` | `api: openai-completions`, baseURL `https://api.aiorouter.ca/v1`, `apiKeyEnv: AIOROUTER_API_KEY`, at least one `models:` id |
| Route is complete | re-run the §1 command | prints `✅ Route check: aiorouter api=openai-completions, models=N` |
| Key resolves | Windows: `$env:AIOROUTER_API_KEY` · macOS/Linux: `echo $AIOROUTER_API_KEY` | starts with `ak-` (never printed anywhere else) |
| Gateway is live | `curl -H "Authorization: Bearer $AIOROUTER_API_KEY" https://api.aiorouter.ca/v1/models` | `200` with your account's model list |
| Models appear | Web UI → Settings → Models | the AIOrouter route is listed with the ids in `models:`; pick any model |
| Protection applies | send any prompt, then Dashboard → API Keys → Privacy | policy in force for the key; Shield/Firewall run before routing |

### 8.1 The route does not appear

1. Re-run the §1 command — it prints the route check. `❌ MISSING_API` means the
   block has no `api:` line; `❌ MISSING_MODELS` means `models:` is empty. Fix
   the block with §4.2 and restart.
2. If the check passes but the route is still missing, restart
   `dsh --profile web`: the file is read only at boot.
3. Still missing on a newer preview build? DSH is evolving quickly; the provider
   schema may have changed since the "Verified with" build above. Run
   `dsh --profile web --dump-config-schema` and compare the `llm-pi-ai` provider
   fields, or use **Settings → Models → Add model provider → Custom model API**
   (protocol `openai-completions`, base URL `https://api.aiorouter.ca/v1`).

## 9. Cost honesty

- Money figures on this page and in the tools are **gateway billing facts**
  only — the authoritative source is your account's usage on the gateway, the
  same one the Dashboard reads. There are no estimates and no currency
  conversions on this side.
- The optional **soft budget** is advisory: it warns you, it never blocks a
  request. Billing stops only where your account policy stops it.

## 10. Related

- Setup overview + free-trial note: [DeepSeek Harness setup page](/deepseek-harness-setup)
- Every model & public price: [Model catalog](/docs/model-catalog)
- Codex / ChatGPT setup: [Codex / Claude setup](/docs/codex-plugin) (Gateway route — the Codex plugin is retired)
- Trust & compliance: [/trust](/trust)
