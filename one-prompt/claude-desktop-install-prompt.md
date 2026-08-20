# Claude Desktop One-Prompt Install (paste this once)

> Importing the config file (Phase 1) only **connects**. After a full restart, open a
> **NEW conversation** in Claude Desktop and paste the **Phase 2 continuation prompt**
> below — the AI finishes the verification (the "wow" privacy test), explains the
> Restore/Redact mechanism, then shows you how to switch models and unlock all
> 19 models with Top-Up credits. 30 seconds, same flow as Codex.
>
> ⚠️ Prerequisite — complete **Phase 1 first**:
> [claude-desktop/SETUP.md](../claude-desktop/SETUP.md) (Run the one-line installer
> — or import the config template → paste your API key → Test Connection green →
> **Apply Changes — Claude Desktop restarts automatically**).

## Phase 2 — continuation prompt (paste into a NEW Claude chat after restart)

```text
I just set up Claude Desktop with AIOrouter (imported the config file and added
my API key). Please finish verifying and enable my setup:

【1】Confirm the setup:
- Settings → Interface Configuration → Test Connection still green.
- My model picker shows many AIOrouter models (DeepSeek, Qwen, GLM, Kimi,
  Grok, Claude…). Ask me to confirm that.

【2】Run the "wow" test — privacy verification:
- Ask me to paste this verification prompt in the main chat:
    My name is Jason Wang. What's the second letter of my first name?
    Please type my name here and let me know what LLM see in my name.
- Expected: the LLM says it sees a placeholder (e.g. "Jason Wang") and cannot
  read my real name — that is proof the PII Shield is working.
- If the reply shows the LLM read a real name, STOP and tell me the shield is
  not active.

【3】Explain how AIOrouter protects me — a short, friendly technical summary
(3-4 sentences, plain language):
1. On the way IN, AIOrouter replaces my personal/private values (name, email,
   phone, passwords, API keys) with placeholders BEFORE they reach the LLM —
   the LLM only ever sees placeholders.
2. On the way BACK, AIOrouter restores the placeholders to my real values
   (Restore) or keeps them redacted (Redact), exactly as I configured in the
   Dashboard — that's why I see my correct name even though the LLM said it
   saw a placeholder.
3. For security secrets (passwords, API keys) the default is Redact — they
   come back as [REDACTED ...] and the AI can never write my real password
   into any file or reply.
4. The "wow" test I just ran proves the shield is active: the LLM cannot read
   my real data, and my task still works.
- Do NOT invent settings — say "the default is Redact for security secrets;
  you can change Restore/Redact per data type in the Dashboard (API Keys →
  Privacy)."

【4】Trial / Top-Up note:
- If I'm on the free trial: the picker shows all models, but usage is locked
  to deepseek-v4-flash (trial model lock). Claude models need Top-Up
  credits. To unlock everything: dashboard.aiorouter.ca → Billing →
  Add Top-Up (one-time packs from $10 CAD, secure Stripe checkout). My key
  keeps working — no re-setup.
- If I already added Top-Up: just confirm I can pick any model.

【5】Model switching teaching:
- Tell me: to switch models, just pick from the model menu (all AIOrouter
  models are listed). No scripts needed.
- (Advanced, only if I ask) I can also say "switch to X" after installing the
  AIOrouter bridge (requires Node.js) — the AI runs the bridge for me.
- End with: "You're fully set up. Your models are one pick away — and your
  real data never reaches the LLM."
```

## Alternative — let an AI prepare the import for you (Path B)

Already have Codex/ChatGPT connected to AIOrouter? Paste this prompt — the AI
prepares the Configuration file and walks you through the import (it cannot click the
GUI for you):

```text
Now help me connect Claude Desktop to AIOrouter. My AIOrouter key is already
in ~/.codex/auth.json.

【1】Prepare the Claude Desktop Configuration file on my machine now (the
    claude-desktop-template.json content — inferenceGatewayBaseUrl
    https://api.aiorouter.ca, inferenceProvider "gateway", the static
    inferenceModels list with ALL AIOrouter models, modelDiscoveryEnabled
    false). Do NOT modify any Claude Desktop setting yet.
【2】Guide me through the import, step by step:
    Claude Desktop → Settings → Interface Configuration → Configure
    Third-Party Inference… → Import Configuration file → select the file
    you prepared. Then I paste my AIOrouter API key (from
    dashboard.aiorouter.ca → API Keys) into the Gateway API key field,
    auth scheme x-api-key, Test Connection → must be green.
    ⚠️ Remind me: my model picker should now list ALL the AIOrouter models
    (DeepSeek, Qwen, GLM, Kimi, Grok, Claude…).
【3】Tell me: after I paste my AIOrouter API key into the Gateway API key
    field (auth scheme x-api-key) and click Apply Changes, Claude Desktop
    restarts automatically — END of Phase 1. After the restart I will open a
    NEW chat and paste the "Phase 2" continuation prompt from the setup
    guide. (No need to close Claude Desktop first — 3P config is never
    overwritten by the app.)
```

## See also

- Full step-by-step (Phase 1): [claude-desktop/SETUP.md](../claude-desktop/SETUP.md)
- 30-second verification prompts: [verify/](../verify/)