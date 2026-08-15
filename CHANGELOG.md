# Changelog

All notable changes to the AIOrouter Gateway setup repository are documented in this
file. Format based on [Keep a Changelog](https://keepachangelog.com/), versioning
follows [SemVer](https://semver.org/).

## [1.1.0] — 2026-08-10

### Changed

- **Claude Desktop — One-line install is now the main path** (FOUNDER decision):
  - `claude-desktop/SETUP.md` — main path = One-line install (run one command →
    paste API key → Apply Changes → automatic restart); Import Configuration file
    moved to an alternative path; Step 5 now says "Apply Changes restarts Claude
    Desktop automatically" instead of "fully quit and relaunch".
  - `claude-desktop/install-claude.ps1` / `.sh` — **removed the "detect Claude
    Desktop running → require quit" check**; Claude Desktop does NOT need to be
    closed first (unlike ChatGPT/Codex, Claude 3P never overwrites the config
    library). After Apply Changes the app restarts itself.
  - `one-prompt/claude-desktop-install-prompt.md` — prerequisite + Path B updated:
    no quit-first step; Apply Changes auto-restarts.
- Website `/claude-desktop-setup` (EN/FR) mirrors the same change: Hero CTA now
  shows "⚡ One-line install — 30 seconds" (like `/codex-integration`), "GUI import
  stuck?" removed, FAQ added "Do I need to close Claude Desktop before installing?"

## [1.0.0] — 2026-08-10

### Added

- **Initial public release** — the AIOrouter Gateway setup repository:
  - `claude-desktop/SETUP.md` — main guide: Import config template → all 19 models in
    the picker; advanced "say switch to X" (bridge); known limitations disclosure
  - `chatgpt-codex/SETUP.md` — main guide: one-line install + SKILL-powered
    "say switch to X"; one-prompt path; manual fallback
  - `one-prompt/` — paste-ready install prompts for AI assistants
    (codex-install-prompt, claude-desktop-install-prompt, model-switch-procedure)
  - `verify/` — 30-second privacy verification prompts (fake identity / fake key)
  - `docs/` — privacy policy, advanced MCP integration link, canonical model catalog link
- Published install scripts (`install-codex.*`, `install-claude.*`) + SKILL file +
      catalog + Claude Desktop template (synced from the AIOrouter build pipeline)
    - Governance: `scripts/export-gateway-repo.mjs` +
      `scripts/verify-gateway-repo.mjs` (secret-scan gate) + pre-push hook

## 2026-08-15 — installer hardening (P-4b pipeline fix + P-11 legacy env_key)

- `chatgpt-codex/install-codex.ps1` / `.sh`: published copies are now BOM-free
  (fixes `irm | iex` failing in Windows PowerShell 5.1 with "The term 'Windows'
  is not recognized" — the UTF-8 BOM used to break the first comment line);
  local copies keep BOM+CRLF for `powershell -File`.
- `install-codex.ps1` / `.sh`: the merge path now auto-comments any legacy
  uncommented `env_key` / `env_key_instructions` lines in
  `[model_providers.aiorouter]` (auth.json-first; fixes "Missing environment
  variable: AIOROUTER_API_KEY" after a key change), and the `.sh` installer now
  also runs `codex login --with-api-key` so the desktop app and CLI share
  `~/.codex/auth.json`.
- `chatgpt-codex/SETUP.md` + `docs/cookbook/codex-model-switch.md`: config
  samples updated (env_key commented), key-rotation and BOM troubleshooting
  rows added.