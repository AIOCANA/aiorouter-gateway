# AIOrouter Model-Switch Procedure (AGENTS.md fallback spec)

> This is the **deterministic fallback procedure** used when the AI cannot install the
> published SKILL file (`https://aiorouter.ca/setup/aiorouter-model-switch.skill.md`,
> which is also mirrored in this repo at
> [chatgpt-codex/aiorouter-model-switch.skill.md](../chatgpt-codex/aiorouter-model-switch.skill.md)
> — e.g. offline environments). Same behavior as the SKILL, just less deterministic.
>
> It is meant to be appended to `~/.codex/AGENTS.md` (add only; never delete other
> content) by the one-prompt installer. After it is in place, the user can just
> **say "switch to X"** and the AI performs the procedure.

## The procedure — append this exact text to `~/.codex/AGENTS.md`

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
   - Do NOT add any new keys (no model_reasoning_effort, no notify, etc.)
6. Re-read config.toml to verify: exactly one uncommented "model =" line and
   model_provider is still "aiorouter", and NO extra keys were added, then say:
   "Switched to <model> — new chats use it immediately (no restart needed)."
```

## How the model list stays up to date

- The commented `# model =` lines in `config.toml` are a **local snapshot** for
  quick reference and offline use.
- The **canonical list is https://aiorouter.ca/docs/model-catalog** — the AI checks
  it whenever the requested model is not in the local list, so new AIOrouter models
  work even if your config was created before they were added.
- When the AI switches to a model that was missing locally, it adds the line to
  `config.toml` (commented) — so the local list self-updates over time.

## Safety guarantees

- Switching only happens when `model_provider = "aiorouter"`; other providers are
  never touched without asking.
- Unsupported models are refused and the available list is shown.
- Exactly one uncommented `model =` line is maintained (duplicate TOML keys would
  invalidate the config).
- A `config.toml.bak` backup is created before every edit, and the file is re-read
  to verify after editing.
- The desktop app's model menu is intentionally avoided (it overwrites config with
  unsupported OpenAI IDs — the app's menu only shows hardcoded OpenAI models).

## When to use this vs the SKILL

| Path | When |
|:---|:---|
| SKILL (`~/.codex/skills/aiorouter-model-switch/SKILL.md`) | Preferred — deterministic, installed by the one-line installer or one-prompt |
| AGENTS.md procedure (this file) | Fallback — offline, network blocked, or SKILL not installed |