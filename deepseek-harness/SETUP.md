# DeepSeek Harness (`dsh`) + AIOrouter Gateway

> **Result:** one-line install → `dsh` runs on the AIOrouter Gateway with your own
> API key. No plugin. No local proxy. Just a provider route in
> `$DSH_HOME/settings.yaml` (default `~/.dsh/settings.yaml`).

DeepSeek Harness reads providers from the `llm-pi-ai` block of its settings file.
A provider that is not in dsh's built-in catalogue **must** declare `api` (the wire
protocol) and at least one model, or dsh refuses to start the route with
`NO_ADAPTER: no adapter registered for provider "aiorouter"`.

This repository ships the same installer the website serves:
<https://aiorouter.ca/deepseek-harness-setup>

---

## Requirements

- **Node.js ≥ 22**
- **DeepSeek Harness** (`dsh`) — the installer checks and offers
  `npm install -g @deepseek-ai/dsh` if it is missing
- An **AIOrouter API key** (`ak-...`) from <https://dashboard.aiorouter.ca/keys>
  — new accounts get a one-time free trial; Top-Up credits unlock the rest of
  the catalogue

---

## One-line install (recommended)

**Windows (PowerShell):**

```powershell
irm https://aiorouter.ca/setup/install-dsh.ps1 | iex
```

**macOS / Linux:**

```bash
curl -fsSL https://aiorouter.ca/setup/install-dsh.sh | bash
```

The installer:

1. checks Node.js ≥ 22 and that `dsh` is on `PATH` (offers the npm install if not);
2. writes the `aiorouter` provider block into `$DSH_HOME/settings.yaml`
   (`DSH_HOME` defaults to `~/.dsh`), preserving your other settings;
3. asks for the API key with masked input and stores it in the
   `AIOROUTER_API_KEY` environment variable (never in `settings.yaml`);
4. runs `--check-route` and tells you whether the route is registered.

Re-running it is safe: the block is updated in place, not duplicated.

---

## Already have `dsh` installed?

Paste this prompt into a dsh session (it will ask for your key separately — never
paste the key into the chat):

```text
Configure AIOrouter in my dsh settings ($DSH_HOME/settings.yaml, default ~/.dsh/settings.yaml).

Use exactly this provider block, preserving every other setting:

llm-pi-ai:
  providers:
    aiorouter:
      api: openai-completions
      baseURL: https://api.aiorouter.ca/v1
      apiKeyEnv: AIOROUTER_API_KEY
      headers: {}
      models:
        - id: deepseek-flash

Then:
1. Download https://aiorouter.ca/setup/aiorouter-gateway-setup.mjs to a local file
   (curl, Invoke-WebRequest, or your browser), then run:
   node aiorouter-gateway-setup.mjs --no-sync
2. Run: node aiorouter-gateway-setup.mjs --check-route
3. If the route is OK, run the same command with --sync-models to add every model on my plan.
4. Never ask me to paste my API key into this chat; tell me to set AIOROUTER_API_KEY in my shell instead.
```

If you prefer a terminal, the same three commands are:

```bash
curl -fsSL https://aiorouter.ca/setup/aiorouter-gateway-setup.mjs -o aiorouter-gateway-setup.mjs
node aiorouter-gateway-setup.mjs --no-sync
node aiorouter-gateway-setup.mjs --check-route
node aiorouter-gateway-setup.mjs --sync-models   # optional: pull the full catalogue
```

---

## Manual setup (2 minutes)

Edit `$DSH_HOME/settings.yaml` (default `~/.dsh/settings.yaml`):

```yaml
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

Then set the key in the environment dsh runs in:

```powershell
# Windows (current session; use System Properties → Environment Variables to persist)
$env:AIOROUTER_API_KEY = "ak-your-key"
```

```bash
# macOS / Linux (add to ~/.zshrc or ~/.bashrc to persist)
export AIOROUTER_API_KEY="ak-your-key"
```

> The key is referenced by name (`apiKeyEnv`), never written into the YAML.

Restart `dsh` and check that the provider appears in the model picker.

---

## Verify

```bash
node aiorouter-gateway-setup.mjs --check-route
```

Expected: `ROUTE OK` (the provider is registered and has at least one model).

Then send a message in dsh. If you see:

| Error | Meaning | Fix |
|:---|:---|:---|
| `NO_ADAPTER: no adapter registered for provider "aiorouter"` | the block is missing `api` and/or `models` | re-run the installer; the block above is the exact shape dsh 0.2.x expects |
| `AUTH: ... invalid` | the route works, the key does not | check `AIOROUTER_API_KEY` and that the key is active on the dashboard |
| provider missing from the picker | settings file not loaded | confirm `DSH_HOME` points at the directory containing `settings.yaml`, then restart dsh |

---

## Switching models

The installer seeds one starter model (`deepseek-flash`). To add every model on
your plan:

```bash
node aiorouter-gateway-setup.mjs --sync-models
```

This is additive and keeps a backup of `settings.yaml`. It never writes a key.

Full catalogue: <https://aiorouter.ca/docs/model-catalog>

---

## Links

- Live setup guide: <https://aiorouter.ca/deepseek-harness-setup>
- Full cookbook: <https://aiorouter.ca/docs/cookbook/deepseek-harness-setup>
- Model catalogue: <https://aiorouter.ca/docs/model-catalog>
- Privacy policy: <https://aiorouter.ca/privacy-policy>
