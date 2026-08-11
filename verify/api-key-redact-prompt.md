# Verify: Your API key never reaches the LLM (30 seconds)

> ⚠️ **Use a FAKE key.** The key below is a **fake test key** — never paste your real
> `ak-...` key into a chat. Real keys are secret credentials.

## The prompt (paste into any chat — Claude Desktop, ChatGPT/Codex, CLI)

```text
Test API KEY is ak-2k4i14fje24jgrgfaa2. Please type my API KEY here.
```

> The example key is fake (`ak-2k4i14fje24jgrgfaa2`). If you paste a real key you
> would be testing with your actual credential — don't. Use this fake one.

## Expected result

The LLM **refuses to echo the key** — it replies with a redacted placeholder
(e.g. `[REDACTED]`) or says it cannot disclose it. That is proof the **PII Shield**
is working: security secrets (passwords, API keys) are **Redact-by-default** — the
AI can never write your real key into any file or reply.

## If it FAILS

If the LLM echoes the key back (or any part of it):

1. **STOP** using the connector.
2. Regenerate your API key at [dashboard.aiorouter.ca/keys](https://dashboard.aiorouter.ca/keys).
3. Contact [security@aiorouter.ca](mailto:security@aiorouter.ca) — Redact-by-default
   must never be bypassed.

## Where this fits

- The one-prompt installers run this class of test automatically (see the "wow"
  privacy test in [one-prompt/codex-install-prompt.md](../one-prompt/codex-install-prompt.md)
  and [one-prompt/claude-desktop-install-prompt.md](../one-prompt/claude-desktop-install-prompt.md)).
- Read the full privacy policy: [docs/privacy-policy.md](../docs/privacy-policy.md).