#!/usr/bin/env bash
# ── AIOrouter × Claude Desktop — One-line secure installer (macOS) ──────────
# Remote URL:  https://aiorouter.ca/setup/install-claude.sh
# Usage:       curl -fsSL https://aiorouter.ca/setup/install-claude.sh | bash
#               (or download → review → run:  bash install-claude.sh)
#
# What this script does:
#   1. Downloads the AIOrouter Claude Desktop Configuration file
#      (https://api.aiorouter.ca/claude-desktop-template.json — the SAME file
#      the GUI "Import Configuration file" would fetch) and writes it into
#      ~/Library/Application Support/Claude-3p/configLibrary with a uuid file
#      name — NO manual file editing, no JSON knowledge needed.
#   2. Backs up any existing AIOrouter profile first (never destroys data).
#   3. Prints the remaining GUI steps: open (or keep open) Claude Desktop, then
#      in Configure Third-Party Inference the "AIOrouter" profile is already
#      loaded — paste your API key, Test Connection → green, Apply Changes →
#      Claude Desktop restarts automatically.
#
#   ⚠️ Claude Desktop does NOT need to be closed first — the script works even
#      while the app is running (unlike the ChatGPT/Codex installer, Claude 3P
#      never overwrites the config library). After Apply Changes the app
#      restarts itself.
#
# Phase 0 verification switches (T-32..T-34 — see plan §5.5b):
#   --fixed-name   use a fixed file name (aiorouter.json) instead of a uuid
#   --no-meta      skip writing/merging _meta.json
#
# Security:
#   - The API key is NEVER written by this script — you paste it in the GUI.
#   - No further remote execution beyond the initial template fetch.
#   - Review policy: you may run curl | bash directly, OR download the file,
#     inspect it, and run `bash install-claude.sh`.
#   - Full guide: https://aiorouter.ca/claude-desktop-setup

set -euo pipefail

FIXED_NAME=0
NO_META=0
for arg in "$@"; do
  case "$arg" in
    --fixed-name) FIXED_NAME=1 ;;
    --no-meta) NO_META=1 ;;
    *) echo "Unknown option: $arg (supported: --fixed-name --no-meta)" >&2; exit 2 ;;
  esac
done

echo "=============================================="
echo "  AIOrouter x Claude Desktop — one-line setup"
echo "=============================================="
echo "This places the AIOrouter Configuration file into Claude Desktop's"
echo "config library automatically (same file the GUI import would fetch)."
echo "You never edit a JSON file — you only paste your API key in the UI."
echo "Claude Desktop does NOT need to be closed — the script works even"
echo "while the app is running (Apply Changes restarts it automatically)."

# 1. Resolve the 3P config library dir (mirrors the Claude Desktop runtime path).
LIBRARY_DIR="${HOME}/Library/Application Support/Claude-3p/configLibrary"

# 2. Download the official AIOrouter Configuration template (same URL the GUI
#    "Import Configuration file" would fetch — no drift between the two paths).
TEMPLATE_URL="https://api.aiorouter.ca/claude-desktop-template.json"
echo ""
echo "⬇️  Downloading the AIOrouter Configuration file..."
if ! TEMPLATE="$(curl -fsSL "${TEMPLATE_URL}" 2>/dev/null)"; then
  echo "❌ Could not download the Configuration file (${TEMPLATE_URL})."
  echo "   Check your internet connection, then use the GUI path instead:"
  echo "   Settings → Interface Configuration → Configure Third-Party Inference…"
  echo "   → Import Configuration file → paste: ${TEMPLATE_URL}"
  exit 1
fi
if ! printf '%s' "$TEMPLATE" | python3 -c 'import json,sys; json.load(sys.stdin)' 2>/dev/null; then
  echo "❌ Downloaded template is not valid JSON — aborting (nothing written)."
  exit 1
fi

# 3. Back up any existing AIOrouter profile (principle C: backup before write).
if [ "$FIXED_NAME" = "1" ]; then
  ID="aiorouter"
else
  ID="$(uuidgen)"
fi
mkdir -p "${LIBRARY_DIR}"
PROFILE_PATH="${LIBRARY_DIR}/${ID}.json"
if [ -f "${PROFILE_PATH}" ]; then
  BACKUP="${PROFILE_PATH}.bak.$(date +%Y%m%d%H%M%S)"
  cp "${PROFILE_PATH}" "${BACKUP}"
  echo "📦 Backed up existing profile → ${BACKUP}"
fi

# 4. Write the profile (UTF-8, no BOM — the same encoding the bridge uses).
printf '%s' "$TEMPLATE" > "${PROFILE_PATH}"
echo "✅ AIOrouter Configuration written → ${PROFILE_PATH}"

# 5. Write/merge _meta.json (unless --no-meta). Keeps entries from other
#    profiles intact; appliedId always points at this profile.
if [ "$NO_META" = "0" ]; then
  META_PATH="${LIBRARY_DIR}/_meta.json"
  if [ -f "${META_PATH}" ] && command -v python3 >/dev/null 2>&1; then
    python3 - "$META_PATH" "$ID" <<'PYEOF'
import json, sys
meta_path, pid = sys.argv[1], sys.argv[2]
try:
    with open(meta_path, "r", encoding="utf-8") as f:
        meta = json.load(f)
    if not isinstance(meta, dict) or not isinstance(meta.get("entries"), list):
        meta = {"appliedId": pid, "entries": []}
except Exception:
    meta = {"appliedId": pid, "entries": []}
if not any(e.get("id") == pid for e in meta["entries"]):
    meta["entries"].append({"id": pid, "name": "AIOrouter"})
meta["appliedId"] = pid
with open(meta_path, "w", encoding="utf-8") as f:
    json.dump(meta, f, indent=2, ensure_ascii=False)
    f.write("\n")
PYEOF
  elif [ -f "${META_PATH}" ]; then
    echo "⚠️  _meta.json exists but python3 is missing — left untouched (other"
    echo "   profiles preserved; T-33 may need python3 for merge verification)."
  else
    printf '{\n  "appliedId": "%s",\n  "entries": [\n    {\n      "id": "%s",\n      "name": "AIOrouter"\n    }\n  ]\n}\n' "$ID" "$ID" > "${META_PATH}"
  fi
  echo "✅ _meta.json updated (other profiles preserved)"
fi

# 6. Next steps — the scripted part is done; the key is always entered in the GUI.
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ Done — the AIOrouter Configuration file is installed."
echo "   The API key is intentionally NOT written by this script — you paste"
echo "   it in the UI (never stored in plaintext by us)."
echo ""
echo "Next steps (1-2 minutes):"
echo "  1. Open Claude Desktop (or keep it open — no need to close it first)."
echo "  2. If a banner appears: 'Your provider setup needs a fix' → click"
echo "     Open Setup — the 'AIOrouter' profile is already loaded (no Import"
echo "     needed). No banner? Settings → Interface Configuration →"
echo "     Configure Third-Party Inference…"
echo "  3. Paste your AIOrouter API key (dashboard.aiorouter.ca → API Keys)"
echo "     into the Gateway API key field · auth scheme x-api-key."
echo "  4. Test Connection → green ✓, then click Apply Changes — Claude"
echo "     Desktop restarts automatically — your model picker now lists all"
echo "     19 AIOrouter models 🎉"
echo "  5. Open a NEW chat and paste the 'Phase 2' continuation prompt from"
echo "     https://aiorouter.ca/claude-desktop-setup (§ Phase 2) to finish"
echo "     verification (the 'wow' test + protection walkthrough)."
echo "Full guide: https://aiorouter.ca/claude-desktop-setup"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"