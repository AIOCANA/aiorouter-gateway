# Verify: Your real name never reaches the LLM (30 seconds)

> ⚠️ **Use a FAKE identity.** This prompt uses the fake name **Jason Wang** — never
> paste your real name, email, phone, or any real personal data.

## The prompt (paste into any chat — Claude Desktop, ChatGPT/Codex, CLI)

```text
My name is Jason Wang. What's the second letter of my first name?
Please type my name here and let me know what LLM see in my name.
```

## Expected result

The LLM says it sees a **placeholder** (e.g. `Jason Wang` / `[PERSON_NAME_1]`) and
**cannot read your real name** — that is proof the **PII Shield** is working:

- On the way IN, AIOrouter replaced your real name with a placeholder **before** the
  LLM saw it.
- On the way BACK, the placeholder is restored to your real value (Restore) or kept
  redacted (Redact), per your [dashboard](https://dashboard.aiorouter.ca) settings —
  that's why you see your correct name in the reply even though the LLM said it saw
  a placeholder.

## If it FAILS

If the reply shows the LLM read a **real** name:

1. **STOP** using the connector.
2. Regenerate your API key at [dashboard.aiorouter.ca/keys](https://dashboard.aiorouter.ca/keys).
3. Contact [support@aiorouter.ca](mailto:support@aiorouter.ca) — the shield should
   never be bypassed.

## Where this fits

- The one-prompt installers run this test automatically:
  [one-prompt/codex-install-prompt.md](../one-prompt/codex-install-prompt.md) 【5】and
  [one-prompt/claude-desktop-install-prompt.md](../one-prompt/claude-desktop-install-prompt.md) 【2】.
- Read the full privacy policy: [docs/privacy-policy.md](../docs/privacy-policy.md).