#!/usr/bin/env bash
# ── AIOrouter × Codex — One-line secure installer (macOS / Linux) ────────────
# Remote URL:  https://aiorouter.ca/setup/install-codex.sh
# Usage:       curl -fsSL https://aiorouter.ca/setup/install-codex.sh | bash
#               (or download → review → run:  bash install-codex.sh)
#
# What this script does:
#   1. Verifies Codex CLI is installed.
#   2. Backs up ~/.codex/config.toml AND ~/.codex/auth.json (if present).
#   3. Creates/merges ~/.codex/config.toml with the `aiorouter` model provider
#      (wire_api = "responses"). Never overwrites other providers.
#   4. Prompts for your AIOrouter API key (hidden input) and appends
#      AIOROUTER_API_KEY to ~/.zshrc / ~/.bashrc. No plaintext key on disk.
#   5. Prints a "Phase 2" continuation prompt — paste it into a NEW chat after
#      restarting Codex to finish verification (restart wipes the session).
#
# Security:
#   - The API key is never echoed and never written to config.toml.
#   - Review policy: you may run curl | bash directly, OR download the file,
#     inspect it, and run `bash install-codex.sh`.
#   - Full guide: https://aiorouter.ca/codex-integration

set -euo pipefail

echo "=============================================="
echo "  AIOrouter x Codex — one-line setup"
echo "=============================================="
echo "You will sign in with a FREE ChatGPT account once to install Codex."
echo "After that you switch to your AIOrouter API key — all model usage is"
echo "billed by AIOrouter, not OpenAI."

# 1. Check Codex CLI
if ! command -v codex >/dev/null 2>&1; then
  echo "❌ Codex CLI not found on PATH."
  echo "   Install Codex first: https://github.com/openai/codex"
  exit 1
fi
echo "✅ Codex CLI detected: $(codex --version | head -1)"

# 2. Config directory + backups (config.toml AND auth.json)
CONFIG_DIR="${HOME}/.codex"
CONFIG_PATH="${CONFIG_DIR}/config.toml"
AUTH_PATH="${CONFIG_DIR}/auth.json"
mkdir -p "${CONFIG_DIR}"

if [ -f "${CONFIG_PATH}" ]; then
  BACKUP="${CONFIG_PATH}.bak.$(date +%Y%m%d%H%M%S)"
  cp "${CONFIG_PATH}" "${BACKUP}"
  echo "📦 Backed up existing config → ${BACKUP}"
fi
if [ -f "${AUTH_PATH}" ]; then
  AUTH_BACKUP="${AUTH_PATH}.bak.$(date +%Y%m%d%H%M%S)"
  cp "${AUTH_PATH}" "${AUTH_BACKUP}"
  echo "📦 Backed up existing login → ${AUTH_BACKUP}"
  echo "   Your previous chat sessions are NOT deleted — Codex groups session"
  echo "   history by login method. After switching to the AIOrouter key,"
  echo "   ChatGPT-subscription sessions are hidden (not lost); they come back"
  echo "   if you log in with ChatGPT again."
fi

# 3. Write / merge the aiorouter provider block
AIOROUTER_BLOCK=$(cat <<'AIOBLOCK_EOF'

# AIOrouter (auto-configured — https://aiorouter.ca/codex-integration)
[model_providers.aiorouter]
name = "AIOrouter"
base_url = "https://api.aiorouter.ca/v1"
wire_api = "responses"
# Key comes from ~/.codex/auth.json (set by `codex login --with-api-key` below;
# shared by the desktop app and CLI). env_key is intentionally commented out —
# with it active, Codex errors "Missing environment variable: AIOROUTER_API_KEY"
# whenever the app/terminal process did not inherit the variable.
# env_key = "AIOROUTER_API_KEY"
# env_key_instructions = "Get your key at https://dashboard.aiorouter.ca/keys"
AIOBLOCK_EOF
)

MODEL_LIST_BLOCK=$(cat <<'MODELBLOCK_EOF'
# ── AIOrouter × Codex — configuration ──────────────────────────────
# How to switch models:
#   1. Say "switch to X" in the app/CLI (SKILL + bridge — installed by this
#      script). New chats use the new model immediately — no restart needed.
#   2. Or uncomment exactly ONE "model =" line below (keep all others commented).
#   3. Per run (CLI):  codex exec -m <model> "your prompt"
#   4. Desktop App: the app's model menu is OpenAI-limited (hardcoded) — do
#      NOT use it to switch; say "switch to X" in the chat instead (SKILL).
# Full guide: https://aiorouter.ca/codex-integration#setup
# ────────────────────────────────────────────────────────────────────
# MODEL — uncomment exactly ONE line (default = deepseek-v4-flash).
# Full 19-model list: https://aiorouter.ca/docs/model-catalog
# (or run: node scripts/aiorouter-codex-bridge.mjs --list-models)
  model = "deepseek-v4-flash"      # default
  # model = "deepseek-v4-pro"
  # model = "qwen3.8-max"
  # model = "qwen3.8-flash"
  # model = "qwen3.7-max"
  # model = "qwen3.7-plus"
  # model = "glm-5.2"
  # model = "glm-5.1"
  # model = "kimi-k3"
  # model = "kimi-k2.7-code"
  # model = "kimi-k2.6"
  # model = "grok-4.6"
  # model = "claude-opus-5"
  # model = "claude-sonnet-5"
  # model = "claude-haiku-4.5"
  # model = "claude-fable-5"
  # model = "gemini-2.5-pro"
  # model = "gemini-2.5-flash"

model_provider = "aiorouter"
MODELBLOCK_EOF
)

if [ ! -f "${CONFIG_PATH}" ]; then
  {
    echo "${MODEL_LIST_BLOCK}"
    echo "${AIOROUTER_BLOCK}"
  } > "${CONFIG_PATH}"
  echo "✅ Created ~/.codex/config.toml (aiorouter provider, default: deepseek-v4-flash)"
elif ! grep -q "model_providers\\.aiorouter" "${CONFIG_PATH}"; then
  echo "${AIOROUTER_BLOCK}" >> "${CONFIG_PATH}"
  echo "✅ Merged aiorouter provider into ~/.codex/config.toml"
else
    # P-11 (2026-08-15): neutralize a legacy UNCOMMENTED env_key pair left by
    # older installers — Codex then demands the env var and errors "Missing
    # environment variable" even when auth.json has the key. The sed range
    # scopes the edit to the aiorouter table only, so other providers are
    # never touched.
    if grep -qE '^[[:space:]]*env_key([[:space:]]*=|_instructions[[:space:]]*=)' "${CONFIG_PATH}" 2>/dev/null; then
      sed -i.bak -E '/\[model_providers\.aiorouter\]/,/^\[/ s/^([[:space:]]*)(env_key|env_key_instructions)([[:space:]]*=)/\1# \2\3/' "${CONFIG_PATH}" 2>/dev/null || true
      echo "ℹ️  Legacy env_key/env_key_instructions in [model_providers.aiorouter] commented out — key now comes only from ~/.codex/auth.json"
    fi
    echo "ℹ️  ~/.codex/config.toml already contains aiorouter — skipped (no changes)"
  fi

# 4. Prompt for API key (hidden) and append to shell rc
echo
echo "Enter your AIOrouter API key (ak-...). It is stored in ~/.codex/auth.json"
  echo "(shared by app and CLI) plus your shell profile as a fallback — never in config.toml."
read -r -s -p "API key: " KEY
echo
if [ -z "${KEY:-}" ]; then
  echo "❌ No key entered — aborting without changes."
  exit 1
fi
case "${KEY}" in
  ak-*) ;;
  *) echo "⚠️  Key does not start with 'ak-' — verify it came from dashboard.aiorouter.ca/keys" ;;
esac

if [ -n "${ZSH_VERSION:-}" ] || [ -f "${HOME}/.zshrc" ]; then
  RC="${HOME}/.zshrc"
elif [ -f "${HOME}/.bashrc" ]; then
  RC="${HOME}/.bashrc"
else
  RC="${HOME}/.profile"
fi

if grep -q "AIOROUTER_API_KEY" "${RC}" 2>/dev/null; then
    echo "ℹ️  AIOROUTER_API_KEY already set in ${RC} — updating value."
    sed -i.bak "/AIOROUTER_API_KEY=/d" "${RC}" 2>/dev/null || true
  fi
  echo "export AIOROUTER_API_KEY=\"${KEY}\"" >> "${RC}"
  echo "✅ AIOROUTER_API_KEY added to ${RC}"

  # auth.json-first (P-5): store the key where BOTH the desktop app and the CLI
  # read it (same as the Windows installer). The rc export above stays as a
  # shell fallback only — the app does NOT read shell profiles.
  if command -v codex >/dev/null 2>&1; then
    if printf '%s' "${KEY}" | codex login --with-api-key >/dev/null 2>&1; then
      echo "✅ Key stored in ~/.codex/auth.json (shared by the app and CLI)."
    else
      echo "⚠️  codex login did not report success — retry with: codex login --with-api-key"
    fi
  fi
  KEY=""  # clear from memory

# 5. Next steps + Phase 2 continuation prompt
echo
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Next steps (open a NEW terminal / new chat):"
echo "  1. Restart the ChatGPT/Codex app once (incl. tray icon) so it loads"
echo "     the new config — a normal Phase 1 step. Switching models later does"
echo "     NOT require quitting the app: just say \"switch to X\" in the chat (SKILL)."
echo "  2. The bottom-left name should show 'AIOrouter'."
echo "  3. ⚠️ Restart wipes this session — open a NEW chat and paste the"
echo "     'Phase 2' block below to finish verification."
echo "Full guide: https://aiorouter.ca/codex-integration"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo
echo "─────────────────────────────────────────────────────────────"
echo "▶ PHASE 2 — paste into a NEW chat after restart:"
echo "─────────────────────────────────────────────────────────────"
echo 'I just restarted Codex after setting up AIOrouter (API key, config.toml,'
echo 'AGENTS.md). Please finish verifying and enable my setup:'
echo ''
echo '【5】Verify the connection — the "wow" test:'
echo '- Desktop app: I should see my account name at the bottom-left showing'
echo '  "AIOrouter" (not a ChatGPT/OpenAI account). Ask me to confirm that.'
echo '- Then ask me to paste this verification PROMPT in the main chat:'
echo '    My name is Jason Wang. What'"'"'s the second letter of my first name?'
echo '    Please type my name here and let me know what LLM see in my name.'
echo '  Expected: the LLM says it sees a placeholder (e.g. "Jason Wang") and'
echo '  cannot read my real name — that is proof the PII Shield is working.'
echo '- If the reply shows the LLM read a real name, STOP and tell me the'
echo '  shield is not active.'
echo '- (CLI users only) In a fresh terminal: codex exec -m deepseek-v4-flash "2+2=?"'
echo '  → expect "4" and output showing provider: aiorouter.'
echo '- Only say "setup complete" after the verification succeeds.'
echo ''
echo '【6】Explain how AIOrouter protects me — a short, friendly technical'
echo 'summary: AIOrouter replaces my personal/private values with placeholders'
echo 'BEFORE they reach the LLM, then restores them on the way back (Restore)'
echo 'or keeps them redacted (Redact) per my Dashboard settings — that'"'"'s why I'
echo 'see my correct name even though the LLM said it saw a placeholder.'
echo 'Security secrets (passwords, API keys) default to Redact so the AI can'
echo 'never write my real password into any file.'
echo ''
echo '【7】(Optional) A note about your plan:'
echo '- If on the free trial (25,000 tokens / 7 days, deepseek-v4-flash only):'
echo '  unlock all 19 models at dashboard.aiorouter.ca → Billing → Choose a'
echo '  Top-Up pack (from $10 CAD).'
echo '- Secure Stripe checkout (Visa/MC/Amex, CAD) — we never store your full card number.'
echo '- Your key keeps working — no re-setup, and it works with many BYOK tools.'

# 6. Install the AIOrouter model-switch skill (so you can just SAY "switch to X")
echo
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Installing the AIOrouter model-switch skill..."
SKILL_DIR="${CONFIG_DIR}/skills/aiorouter-model-switch"
SKILL_PATH="${SKILL_DIR}/SKILL.md"
if [ -f "${SKILL_PATH}" ]; then
  echo "ℹ️  Skill already installed — nothing to do."
else
  mkdir -p "${SKILL_DIR}"
  if curl -fsSL "https://aiorouter.ca/setup/aiorouter-model-switch.skill.md" -o "${SKILL_PATH}.tmp" 2>/dev/null; then
    mv "${SKILL_PATH}.tmp" "${SKILL_PATH}"
    echo "✅ Model-switch skill installed. After the restart above, just say"
    echo "   \"switch to X\" in the app/CLI — new chats use the model immediately."
  else
    rm -f "${SKILL_PATH}.tmp"
    # Fallback: append the AGENTS.md switch procedure (same steps, AI-driven)
    AGENTS_PATH="${CONFIG_DIR}/AGENTS.md"
    cat >> "${AGENTS_PATH}" <<'EOM'

## AIOrouter model switch procedure
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
EOM
    echo "⚠️  Could not download the skill — appended the AGENTS.md fallback"
    echo "   procedure instead (AI will follow it when you say \"switch to X\")."
  fi
fi
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
