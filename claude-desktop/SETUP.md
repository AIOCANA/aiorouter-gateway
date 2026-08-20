# Claude Desktop Setup — All 19 Models in Your Picker

> **Applies to:** Claude Desktop (Third-Party Inference) + AIOrouter
> **Result:** Import one config file → **all 19 AIOrouter models appear in your model
> picker** (DeepSeek, Qwen, GLM, Kimi, Grok, Claude, Gemini…). Switch anytime —
> even by saying "switch to X" (advanced).

---

## Before you start (Prerequisites)

1. **Register + get an API key** at [dashboard.aiorouter.ca](https://dashboard.aiorouter.ca)
   — new accounts get a free 7-day trial (`deepseek-v4-flash` only). Claude models need
   Top-Up credits. AIOrouter is a **paid service — no free tier** beyond the trial.
2. Install **Claude Desktop** (with Third-Party Inference support). Windows data path
   example: `%LOCALAPPDATA%\Claude-3p\`.

---

## Main path — One-line install (30 seconds, no terminal skills needed)

> 🆕 **Fastest path.** Run one command — the installer downloads the AIOrouter
> Configuration file and installs it into Claude Desktop's config library for
> you. You edit **no files** — you only paste your API key in the UI.
> **Claude Desktop does NOT need to be closed first** — the script works even
> while the app is open (unlike the ChatGPT/Codex installer, Claude 3P never
> overwrites the config library).

### Step 1 — Get your API key

Generate a key at [dashboard.aiorouter.ca/keys](https://dashboard.aiorouter.ca/keys).
You'll use it as the **Gateway API key** in Step 3.

### Step 2 — Run the one-line installer

- **Windows (PowerShell):** `irm https://aiorouter.ca/setup/install-claude.ps1 | iex`
  (or download [install-claude.ps1](install-claude.ps1))
- **macOS (Terminal):** `curl -fsSL https://aiorouter.ca/setup/install-claude.sh | bash`
  (or download [install-claude.sh](install-claude.sh))

The script downloads the same Configuration file the GUI import would fetch and
writes it to Claude Desktop's config library (backing up any existing profile
first). Your API key is **never** written by the script — you paste it in the UI.

### Step 3 — Paste your key and Apply Changes

1. **Open Claude Desktop** (or keep it open — no need to close it first).
2. If a banner appears: **"Your provider setup needs a fix"** → click
   **Open Setup** — the "AIOrouter" profile is already loaded (no Import needed).
   No banner? **Settings → Interface Configuration → Configure Third-Party
   Inference…**
3. Paste your **AIOrouter API key** into the **Gateway API key** field · auth
   scheme **`x-api-key`**.
4. **Test Connection** → must be **green** ✅, then click **Apply Changes** —
   **Claude Desktop restarts automatically.**

### Step 4 — Done: 19 models in your picker

After the automatic restart, the model picker shows **all 19 AIOrouter models**
(e.g. `deepseek-v4-pro`, `qwen3.7-max`, `glm-5.2`, `kimi-k3`, `grok-4.5`) — pick
any model and chat.

> ⚠️ **Trial note (honest disclosure):** the picker shows all models, but during the
> free trial **usage is locked to `deepseek-v4-flash`**. Add one-time Top-Up credits
> (from $10 CAD, Stripe-secured) to unlock every model — your key keeps working, no
> re-setup. Claude models specifically require a positive Top-Up balance.

### Step 5 — Paste the Phase 2 continuation prompt (END of Phase 1)

Claude Desktop has restarted automatically — this is the end of Phase 1 (setup).
**Open a NEW chat and paste the
[Phase 2 continuation prompt](../one-prompt/claude-desktop-install-prompt.md)** —
the AI completes the "wow" privacy test, explains Restore/Redact, and walks you
through Top-Up + model switching.

---

## Alternative path — Import Configuration file (GUI)

Prefer the GUI? Import the Configuration file manually — same result, no terminal:

1. Claude Desktop → **Settings** → **Interface Configuration** →
   **Configure Third-Party Inference…** → **Import Configuration file**.
2. Paste the template URL (or download and select the file):

   ```
   https://api.aiorouter.ca/claude-desktop-template.json
   ```

   > No file editing is ever required — pasting the URL is enough. A copy of the
   > same template is in this repo: [claude-desktop-template.json](claude-desktop-template.json).
3. Fill in the **Gateway API key**: `ak-...` (your real key — never a placeholder),
   auth scheme **`x-api-key`** → **Test Connection** → must be **green** ✅.
4. Click **Apply Changes** — **Claude Desktop restarts automatically** — END of
   Phase 1. After restart, open a NEW chat and paste the
   [Phase 2 continuation prompt](../one-prompt/claude-desktop-install-prompt.md).

---

## Switching models

1. **In the model picker (recommended, no tools needed):** every AIOrouter model is
   listed — just pick one and chat.
2. **In a chat (advanced, requires Node.js):** say **"switch to X"** (e.g. *"switch to
   deepseek-v4-pro"*) and the AI runs the AIOrouter bridge for you — it backs up before
   writing and only touches the model selection (`isFamilyDefault`), preserving your
   API key and other profile settings.
   - Bridge CLI (advanced): `--apply`, `--switch-model <slug>`, `--refresh-models`,
     `--status`. Requires Node.js.
   - After switching, **new chats use the new model immediately** — no restart needed
     for the switch itself (a full Desktop restart is only required once, after setup).

### Known limitations (honest disclosure)

These are upstream Claude Desktop / platform limitations — documented so you're not
surprised:

| Limitation | Detail |
|:---|:---|
| Cross-session pick may not persist | Across Desktop sessions, the last model pick may not persist (official Desktop behavior). The bridge's `--switch-model` reduces this by setting the family default. |
| 1M context is binary | Context length is `200k` or `1M` — no middle value. |
| Background utility calls use the low-cost model | Internal background side-calls use `deepseek-v4-flash` (cost optimization). |

---

## Verify your setup (30 seconds)

Paste these prompts in a chat to prove the PII Shield is active:

1. [verify/name-placeholder-prompt.md](../verify/name-placeholder-prompt.md) — fake
   identity "Jason Wang": the LLM must say it sees a placeholder, never your real name.
2. [verify/api-key-redact-prompt.md](../verify/api-key-redact-prompt.md) — fake key:
   the LLM must refuse to echo it.

If you're on a fresh setup, the
[one-prompt/claude-desktop-install-prompt.md](../one-prompt/claude-desktop-install-prompt.md)
runs the full verification for you.

---

## Deep-dive reference

- [docs/mcp-integration.md](../docs/mcp-integration.md) — advanced MCP tools (10 tools)
  for Claude Code / Codex CLI users (separate optional package)
- Canonical 19-model list: [docs/model-catalog-link.md](../docs/model-catalog-link.md)
- [docs/privacy-policy.md](../docs/privacy-policy.md) — data handling