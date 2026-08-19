# DeepSeek Harness (dsh) Setup — run 19 AI models with one API key and the AIOrouter Shield plugin

> **Doc type:** Cookbook — user-facing setup guide
> **Version:** v1.0.0 | **Date:** 2026-08-18
> **Author:** AIRO (deepseek-v4-flash)

Use **DeepSeek Harness (dsh)** — a local, model-agnostic AI coding harness — with
your **AIOrouter API key** (`ak-...`) to reach 19 models (DeepSeek, Qwen, GLM,
Kimi, Grok, Claude and Gemini) through one OpenAI-compatible endpoint, with the
**AIOrouter Shield plugin** (`@aiorouter/dsh-shield`) handling privacy policy,
PII restoration markers, account status and model-catalog auto-sync.

```
dsh (local harness) ── OpenAI-compatible ──► https://api.aiorouter.ca/v1
    └─ @aiorouter/dsh-shield plugin     └─ PII Shield → AI Firewall → billing → router
                                         └─ DeepSeek / Qwen / GLM / Kimi / Grok …
```

---

## 1. How it works

dsh is a profile-based harness: you boot a *profile* (a layer stack of plugin
bundles + your overrides) and every plugin you add joins that profile. The
**AIOrouter Shield plugin** adds:

1. **The `aiorouter` provider route** — an `openai-completions` provider pointed at
   `https://api.aiorouter.ca/v1`, with the GW-2 privacy-policy header
   (`x-aiorouter-privacy-policy`: `restore-all` / `redact-secrets` / `redact-all`)
   and the GW-1 restoration-marker header (`x-aiorouter-restoration-markers`:
   `plain` / `markdown`). Every request through AIOrouter is protected by the
   PII Shield and AI Firewall **before** routing to the model provider.
2. **A settings section** — *Settings → AIOrouter Shield* in the dsh Web UI
   (policy preset, advanced per-type JSON overrides, marker style). Changes are
   written into the provider headers on every commit.
3. **The `aiorouter_shield_status` tool** — account card (balance, effective
   policy, Shield state, dashboard link) and the per-session protection mapping
   table (type × count × disposition). Metadata only — protected values are
   never rendered.
4. **Model-catalog auto-sync** — at boot (and then every 6 hours by default)
   the plugin fetches `GET /v1/models` from the gateway and *appends* any new
   catalog ids to your aiorouter route's model list. User-maintained models are
   never removed or overwritten (append-only union-merge).
5. **Update availability check** — boot + daily check of the npm registry for
   a newer `@aiorouter/dsh-shield` release; the status tool shows
   `📦 Update available: X → Y` with the one-command update.

---

## 2. Prerequisites

- **Node.js ≥ 20** and **npm** installed on your machine.
- **AIOrouter account + API key** (`ak-...`) from
  <https://dashboard.aiorouter.ca/keys> — new accounts get a one-time free trial
  (25,000 tokens / 7 days, `deepseek-v4-flash` only). Subscriptions (from
  $19/month) unlock all 19 models; your same key keeps working after upgrade.

---

## 3. Setup (2 minutes)

### 3.1 Install the harness

```bash
npm i -g dsh
dsh --version     # v0.1.0-rc.6 or newer
```

### 3.2 Boot a profile and add the plugin

Boot the Web profile once (this creates `~/.dsh/profiles/web/`):

```bash
dsh --profile web
```

In another terminal (or after the Web UI is up), add the plugin:

```bash
dsh plugin --profile web add @aiorouter/dsh-shield
```

The plugin resolves to a `dsh.bundle` (its `cordis.patch.yml`), so the
profile reconcile step activates it automatically — no restart file edits.

> 💡 **Profile naming.** The Web UI profile is `web`. Any other profile works
> the same: `dsh plugin --profile <name> add @aiorouter/dsh-shield`.

### 3.3 Set your API key

Open the dsh Web UI (*http://127.0.0.1:3080* by default) → **Settings → Models**,
and set **`AIOROUTER_API_KEY`** to your `ak-...` key. The key is resolved
through the credentials seam at call time — it is never written to the plugin's
files or sent anywhere except the AIOrouter gateway.

The onboarding pointer in the Web UI confirms when the key is detected; the
`aiorouter_shield_status` tool needs it to show your account card.

---

## 4. Switch models

The aiorouter route lists all gateway catalog ids (auto-synced — see §5). In the
dsh UI pick any model per conversation; in headless/CLI mode select with the
provider+model args, e.g.:

```bash
dsh --profile web "explain the PII Shield pipeline in 3 bullet points"
```

With the default agent model `deepseek-v4-flash` you can use the free trial
immediately after getting your key.

---

## 5. Model-catalog auto-sync

- **Cadence:** every `modelRefreshMinutes` (default **360** = 6 h), plus once at
  boot. Set `0` in *Settings → AIOrouter Shield* for boot-only sync.
- **Behavior:** union-merge — new gateway catalog ids are **appended** to your
  route's model list; your custom models and display names are preserved.
- **Failure:** silent. A failed fetch never crashes dsh or the plugin.

---

## 6. Updating the plugin

The dsh plugin manager has no silent auto-update; updates are one command
(pnpm forwarder — the new bundle is re-activated automatically by reconcile):

```bash
dsh plugin --profile web update @aiorouter/dsh-shield
```

When a newer version exists, `aiorouter_shield_status` prints the
`📦 Update available: X → Y` line with this command — no need to poll npm.

---

## 7. Verify

| Check | Command / UI | Expected |
|:---|:---|:---|
| Plugin active | Web UI → Settings → AIOrouter Shield | section visible; policy preset shown |
| Route exists | `~/.dsh/settings.yaml` → `llm-pi-ai.providers.aiorouter` | baseURL `https://api.aiorouter.ca/v1`, headers present |
| Account card | call `aiorouter_shield_status` | balance, policy, Shield state |
| Model sync | run the status tool / inspect the model picker | new gateway ids appear within 6 h (or after boot) |
| Update check | call `aiorouter_shield_status` | `📦 Update available` line (or none when current) |

---

## 8. Security & privacy posture

- **Zero-disk keys:** `AIOROUTER_API_KEY` lives in the credentials seam, resolved
  per call — the plugin writes no files and stores no keys.
- **Zero-PII tool output:** the status tool renders counts, type labels,
  dispositions and policy names only — never protected values.
- **Header values are gateway-validated:** preset names the gateway accepts, or
  JSON it validates. Structurally invalid JSON falls back to the preset; a
  mistyped per-type name is a loud HTTP 400, never a silent privacy change.
- This package is **public** (MIT) — it ships no personal identity, no contract
  pricing, and no server-side privacy-taxonomy internals.
