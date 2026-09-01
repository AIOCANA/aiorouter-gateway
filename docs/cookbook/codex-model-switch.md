# Codex Model Switching with AIOrouter (paste-ready prompt)

> Paste the prompt below into Codex (CLI or desktop app) **once**. The AI will:
> 1. Set up `~/.codex/config.toml` with the AIOrouter provider + full model list
> 2. Add the **"AIOrouter model switch procedure"** to the global `~/.codex/AGENTS.md`
> 3. Guide you through API key setup
>
> Afterwards you only need to say **"switch to <model>"** — the AI updates
> `config.toml` for you. You never hand-edit files.

## The prompt (copy everything below)

```text
Please set up AIOrouter × Codex for me. Do the following in order:

【1】Make sure ~/.codex/config.toml has the full AIOrouter setup:
- If the file does not exist, create it from the template below. If it exists
  but has no aiorouter provider, merge the block in (do NOT delete or modify
  other provider settings; if model_provider is currently NOT "aiorouter",
  tell me that this will override my current provider and wait for my OK).
- Template:
  model = "deepseek-v4-flash"      # default
  # model = "deepseek-v4-pro"
  # model = "qwen3.8-flash"
  # model = "qwen3.7-max"
  # model = "qwen3.7-plus"
  # model = "glm-5.2"
  # model = "glm-5.3"
  # model = "glm-5.3-flash"
  # model = "kimi-k2.7-code"
  # model = "kimi-k2.6"
  # model = "kimi-k3"
  # model = "grok-4.6"
  model_provider = "aiorouter"
[model_providers.aiorouter]
    name = "AIOrouter"
    base_url = "https://api.aiorouter.ca/v1"
    wire_api = "responses"
    # auth.json-first (P-5): env_key is COMMENTED so Codex never demands the
    # env var (apps launched from the Start menu/Finder don't inherit new
    # User env vars) — the key is read from ~/.codex/auth.json instead.
    # env_key = "AIOROUTER_API_KEY"
    # env_key_instructions = "Get your key at https://dashboard.aiorouter.ca/keys"
- Important: model / model_provider must stay at the TOML top level (before
  the [model_providers.*] table).

【2】Add the "AIOrouter model switch procedure" section to ~/.codex/AGENTS.md
(add only; do not delete other content). From now on, when I say "switch to
X", you must: read config.toml → confirm model_provider = "aiorouter" →
verify X is supported (local commented list first, then
https://aiorouter.ca/docs/model-catalog; if the network is blocked and X is
not in the local list, tell me you could not verify) → if unsupported, refuse
and list available models → back up config.toml.bak → change the uncommented
model = line to X (keep exactly one uncommented; add the line if missing) →
re-read to verify → tell me to restart Codex/app.

【3】Guide me through the API key:
- If I have no key: walk me through creating one at
  https://dashboard.aiorouter.ca/keys
- Run `codex login --with-api-key` and have me paste the key (stored in
  ~/.codex/auth.json; shared by app and CLI). No test command needed.
- If I use the desktop app: remind me to fully quit and relaunch, and never
  to use the app's model menu
```

## What gets written to ~/.codex/AGENTS.md (reference)

```markdown
## AIOrouter model switch procedure
When the user asks to "switch to / change to / use <model>":
1. Read ~/.codex/config.toml
2. Confirm model_provider = "aiorouter"; if not, tell the user you cannot proceed
3. Determine if <model> is supported:
   a. Check the commented "model =" list in ~/.codex/config.toml
   b. If not there, fetch https://aiorouter.ca/docs/model-catalog (canonical list)
   c. If the network is blocked, tell the user you could not verify the catalog
      and list the local models you know about
4. If <model> is not supported → refuse, list available models, ask the user
   to re-specify. Do NOT edit config.toml.
5. Edit config.toml (back it up first as config.toml.bak):
   - Change the currently uncommented model = "..." line to the target model
   - Keep exactly ONE uncommented "model =" line; leave all others commented
   - If the target model line does not exist yet, add it (commented) first,
     then uncomment it — this keeps the local list up to date
   - Do NOT change model_provider / base_url / env_key or anything else
6. Re-read config.toml to verify: exactly one uncommented "model =" line and
   model_provider is still "aiorouter", then say: "Switched to <model>.
   Restart Codex / the app for it to take effect."
```

## How the model list stays up to date

- The commented `# model =` lines in `config.toml` are a **local snapshot**
  for quick reference and offline use.
- The **canonical list is `https://aiorouter.ca/docs/model-catalog`** — the AI
  checks it whenever the requested model is not in the local list, so new
  AIOrouter models work even if your config was created before they were added.
- When the AI switches to a model that was missing locally, it adds the line
  to config.toml (commented) — so the local list self-updates over time.

## Safety guarantees

- Switching only happens when `model_provider = "aiorouter"`; other providers
  are never touched without asking.
- Unsupported models are refused and the available list is shown.
- Exactly one uncommented `model =` line is maintained (duplicate TOML keys
  would invalidate the config).
- A `config.toml.bak` backup is created before every edit, and the file is
  re-read to verify after editing.
- The desktop app's model menu is intentionally avoided (it overwrites config
  with unsupported OpenAI IDs).
