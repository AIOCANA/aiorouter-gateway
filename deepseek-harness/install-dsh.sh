#!/usr/bin/env bash
# ── AIOrouter × DeepSeek Harness — One-line secure installer (macOS / Linux) ──
# Remote URL:  https://aiorouter.ca/setup/install-dsh.sh
# Usage:       curl -fsSL https://aiorouter.ca/setup/install-dsh.sh | bash
#               (or download → review → run:  bash install-dsh.sh)
#
# What this script does:
#   1. Verifies Node.js (>= 20); installs the dsh CLI if missing.
#   2. Adds the @aiorouter/dsh-shield plugin to the dsh profile (default: web;
#      override with $DSH_PROFILE).
#   3. Prompts for your AIOrouter API key (hidden input) and appends
#      AIOROUTER_API_KEY to ~/.zshrc / ~/.bashrc. No plaintext key on disk
#      beyond the standard shell-profile export.
#   4. Prints next steps (boot, verify).
#
# Security:
#   - The API key is never echoed and never written to the dsh config files.
#   - Review policy: you may run curl | bash directly, OR download the file,
#     inspect it, and run bash install-dsh.sh .
#   - Full guide: https://aiorouter.ca/deepseek-harness-setup

set -euo pipefail

PROFILE_NAME="${DSH_PROFILE:-web}"

echo "=============================================="
echo "  AIOrouter x DeepSeek Harness - one-line setup"
echo "=============================================="

# 1. Check Node.js + npm
if ! command -v node >/dev/null 2>&1; then
  echo "Node.js not found on PATH - install Node.js >= 20 first: https://nodejs.org"
  exit 1
fi
echo "✅ Node.js detected: $(node --version)"

# 2. Install dsh CLI if missing
if ! command -v dsh >/dev/null 2>&1; then
  echo "Installing dsh globally (npm i -g dsh)..."
  npm i -g dsh
fi
echo "✅ dsh detected: $(dsh --version | head -1)"

# 3. Add the plugin to the profile (initializes the profile on first use)
echo "Adding @aiorouter/dsh-shield to profile: ${PROFILE_NAME}"
dsh plugin --profile "${PROFILE_NAME}" add @aiorouter/dsh-shield
echo "✅ Plugin added."

# 4. Prompt for API key (hidden) and append to shell rc
echo
echo "Enter your AIOrouter API key (ak-...). It is added as AIOROUTER_API_KEY"
echo "to your shell profile - never written to dsh config files."
read -r -s -p "API key: " KEY
echo
if [ -z "${KEY:-}" ]; then
  echo "No key entered - aborting without changes."
  exit 1
fi
case "${KEY}" in
  ak-*) ;;
  *) echo "Warning: key does not start with ak- - verify it came from dashboard.aiorouter.ca/keys" ;;
esac

if [ -n "${ZSH_VERSION:-}" ] || [ -f "${HOME}/.zshrc" ]; then
  RC="${HOME}/.zshrc"
elif [ -f "${HOME}/.bashrc" ]; then
  RC="${HOME}/.bashrc"
else
  RC="${HOME}/.profile"
fi

if grep -q "AIOROUTER_API_KEY" "${RC}" 2>/dev/null; then
  sed -i.bak "/AIOROUTER_API_KEY=/d" "${RC}" 2>/dev/null || true
fi
echo "export AIOROUTER_API_KEY=\"${KEY}\"" >> "${RC}"
KEY=""  # clear from memory
echo "✅ AIOROUTER_API_KEY added to ${RC}"

# 5. Next steps
echo
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Next steps:"
echo "  1. Open a NEW terminal (so the env var is visible) and run:"
echo "       dsh --profile ${PROFILE_NAME}"
echo "  2. In the Web UI (http://127.0.0.1:3080) -> Settings -> Models, confirm"
echo "     AIOROUTER_API_KEY is set, and pick a model (default: deepseek-v4-flash -"
echo "     free trial eligible)."
echo "  3. Call aiorouter_shield_status to see your account card + Shield state."
echo "Full guide: https://aiorouter.ca/deepseek-harness-setup"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
exit 0
