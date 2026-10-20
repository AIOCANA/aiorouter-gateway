#!/usr/bin/env bash
# ── AIOrouter Gateway setup for DeepSeek Harness — macOS / Linux (one line) ──
#   curl -fsSL https://www.aiorouter.ca/setup/install-dsh.sh | bash
#
# What it does (no plugin — the retired @aiorouter/dsh-aiorouter-mas is NOT used):
#   1. checks Node >= 22 (Harness requirement);
#   2. checks DeepSeek Harness (dsh) and offers `npm i -g @deepseek-ai/dsh` when missing;
#   3. prompts for your AIOrouter API key (masked, read from /dev/tty so a piped
#      `curl | bash` still works) and persists it as a shell profile export
#      (marker block AIOROUTER_GATEWAY_BEGIN/END; R12: value never echoed);
#   4. writes the AIOrouter provider route into ~/.dsh/settings.yaml
#      (or $DSH_HOME/settings.yaml):
#      api: openai-completions + baseURL + apiKeyEnv + models (mandatory for a route
#      outside the pi-ai built-in catalog);
#   5. verifies the key live against GET /v1/models AND checks the route block
#      (api + at least one model) — the part that silently failed before.
#   --verify     only re-run the live verification + route check
#   --uninstall  remove the provider block and the profile marker block
set -euo pipefail
SETUP_URL="https://www.aiorouter.ca/setup/aiorouter-gateway-setup.mjs"
TMP="${TMPDIR:-/tmp}/aiorouter-gateway-setup.mjs"
PROFILE_FILE="${HOME}/.zshrc"
case "${SHELL:-}" in *bash*) PROFILE_FILE="${HOME}/.bashrc" ;; esac
SETTINGS_ARGS=()
if [ -n "${DSH_HOME:-}" ]; then SETTINGS_ARGS=(--settings "${DSH_HOME}/settings.yaml"); fi

echo ""
echo "=== AIOrouter Gateway setup (DeepSeek Harness) ==="

command -v node >/dev/null 2>&1 || { echo "Node.js not found. The Harness needs Node.js 22+ — install from https://nodejs.org"; exit 1; }
NODE_MAJOR="$(node -v | sed 's/^v//' | cut -d. -f1)"
[ "$NODE_MAJOR" -ge 22 ] || { echo "Node $(node -v) is too old — install Node 22+ (https://nodejs.org)"; exit 1; }

fetch_setup() {
  if command -v curl >/dev/null 2>&1; then curl -fsSL "$SETUP_URL" -o "$TMP"
  else wget -qO "$TMP" "$SETUP_URL"; fi
}

# Remove the managed marker block WITHOUT leaving a key-bearing .bak next to the rc file.
strip_profile_block() {
  [ -f "$PROFILE_FILE" ] || return 0
  local tmp_rc
  tmp_rc="$(mktemp)"
  sed '/# AIOROUTER_GATEWAY_BEGIN/,/# AIOROUTER_GATEWAY_END/d' "$PROFILE_FILE" > "$tmp_rc"
  cat "$tmp_rc" > "$PROFILE_FILE"
  rm -f "$tmp_rc"
}

if [ "${1:-}" = "--uninstall" ]; then
  fetch_setup; node "$TMP" --uninstall ${SETTINGS_ARGS[@]+"${SETTINGS_ARGS[@]}"}
  strip_profile_block
  echo ""
  echo "Uninstalled: provider block removed, AIOROUTER_API_KEY export removed from $PROFILE_FILE."
  echo "Open a new terminal (or: source $PROFILE_FILE) and restart your Harness."
  exit 0
fi

if [ "${1:-}" = "--verify" ]; then
  fetch_setup
  node "$TMP" --verify-only ${SETTINGS_ARGS[@]+"${SETTINGS_ARGS[@]}"}
  node "$TMP" --check-route ${SETTINGS_ARGS[@]+"${SETTINGS_ARGS[@]}"}
  exit $?
fi

# --- DeepSeek Harness presence (the route is useless without the harness) ---
if ! command -v dsh >/dev/null 2>&1; then
  echo ""
  echo "DeepSeek Harness (dsh) was not found on PATH."
  echo "Install it with:  npm i -g @deepseek-ai/dsh"
  printf 'Install it now? [y/N] ' > /dev/tty
  read -r ans < /dev/tty
  case "$ans" in
    [yY]*) npm i -g @deepseek-ai/dsh || { echo "npm install failed — install Node.js 22+ and retry."; exit 1; }; echo "dsh installed." ;;
    *) echo "Aborted. Install dsh first, then re-run this script."; exit 1 ;;
  esac
fi

echo ""
echo "Create a key at https://dashboard.aiorouter.ca (Keys) and paste it below."
printf 'AIOrouter API key (input hidden): ' > /dev/tty
read -rs KEY < /dev/tty; echo "" > /dev/tty
[ -n "${KEY:-}" ] || { echo "No key entered — aborting without changes."; exit 1; }
case "$KEY" in ak-*) ;; *) echo "Warning: keys normally start with 'ak-' — continuing anyway." ;; esac

# persist (marker block keeps re-runs idempotent); 0600 on the file if we create it
touch "$PROFILE_FILE"; chmod 600 "$PROFILE_FILE" 2>/dev/null || true
strip_profile_block
{
  echo "# AIOROUTER_GATEWAY_BEGIN (managed by install-dsh.sh — safe to delete as a block)"
  echo "export AIOROUTER_API_KEY='${KEY}'"
  echo "# AIOROUTER_GATEWAY_END"
} >> "$PROFILE_FILE"
export AIOROUTER_API_KEY="$KEY"
echo "Stored AIOROUTER_API_KEY in $PROFILE_FILE (marker block)."

fetch_setup
node "$TMP" ${SETTINGS_ARGS[@]+"${SETTINGS_ARGS[@]}"}
node "$TMP" --check-route ${SETTINGS_ARGS[@]+"${SETTINGS_ARGS[@]}"}

echo ""
echo "Done. Open a new terminal (so the export applies) and restart your Harness:"
echo "  dsh --profile web"
echo "Then Settings -> Models should list the AIOrouter route with your catalog."
echo "If it is missing: Settings -> Models -> Add model provider -> Custom model API;"
echo "protocol openai-completions, base URL https://api.aiorouter.ca/v1."
echo "Docs: https://www.aiorouter.ca/deepseek-harness-setup"
echo ""
