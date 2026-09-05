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

Credentials and secrets are masked into placeholders **before entering any model** —
model-side zero contact (verified): the model only ever receives a placeholder and
never sees your real key.

If the model echoes the placeholder in its reply, AIOrouter restores the value **you
sent** back to you on the response path — the reply may show your own key, because it
was returned to the caller, not because the model saw it. (Response-surface redaction
of secrets is a planned policy option, not yet available.)

## If it FAILS

A real failure is the model describing your **actual** key — e.g. replying with its
true length or real characters ("46 characters, starting `ak-`"). Seeing your own
key echoed back is **not** a failure — that is the restore path returning your value
to you. If the model reveals your real key's details:

1. **STOP** using the connector.
2. Regenerate your API key at [dashboard.aiorouter.ca/keys](https://dashboard.aiorouter.ca/keys).
3. Contact [security@aiorouter.ca](mailto:security@aiorouter.ca) — input-side masking
   must never be bypassed.

## Where this fits

- The one-prompt installers run this class of test automatically (see the "wow"
  privacy test in [one-prompt/codex-install-prompt.md](../one-prompt/codex-install-prompt.md)
  and [one-prompt/claude-desktop-install-prompt.md](../one-prompt/claude-desktop-install-prompt.md)).
- Read the full privacy policy: [docs/privacy-policy.md](../docs/privacy-policy.md).