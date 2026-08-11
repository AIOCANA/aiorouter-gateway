---
name: aiorouter-model-switch
description: Switch the active AIOrouter model in Codex when the user says "switch to <model>" / "change to <model>" / "use <model>". Use when the user asks to change models in the ChatGPT desktop app or Codex CLI.
---

# AIOrouter model switch

When the user asks to "switch to / change to / use <model>":
1. Read ~/.codex/config.toml
2. Confirm model_provider = "aiorouter"; if not, tell the user you cannot proceed
3. Determine if <model> is supported:
   a. Check the commented "model =" list in ~/.codex/config.toml
   b. If not there, fetch https://aiorouter.ca/docs/model-catalog (canonical list)
   c. If the network is blocked, tell the user you could not verify the catalog and list the local models you know about
4. If <model> is not supported → refuse, list available models, ask the user to re-specify. Do NOT edit config.toml.
5. Edit config.toml (back it up first as config.toml.bak):
   - Change the currently uncommented model = "..." line to the target model
   - Keep exactly ONE uncommented "model =" line; leave all others commented
   - If the target model line does not exist yet, add it (commented) first, then uncomment it — this keeps the local list up to date
   - Do NOT change model_provider / base_url / env_key or anything else
   - Do NOT add any new keys (no model_reasoning_effort, no notify, etc.)
6. Re-read config.toml to verify: exactly one uncommented "model =" line and model_provider is still "aiorouter", and NO extra keys were added, then say: "Switched to <model> — new chats use it immediately (no restart needed)."