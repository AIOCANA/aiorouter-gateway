# AIOrouter one-line secure installer for Claude Desktop (Windows PowerShell)
# Remote URL:  https://aiorouter.ca/setup/install-claude.ps1
# Usage:       irm https://aiorouter.ca/setup/install-claude.ps1 | iex
#               (or download → review → run:  powershell -File install-claude.ps1)
#
# What this script does:
#   1. Downloads the AIOrouter Claude Desktop Configuration file
#      (https://api.aiorouter.ca/claude-desktop-template.json — the SAME file
#      the GUI "Import Configuration file" would fetch) and writes it into the
#      Claude Desktop 3P config library (%LOCALAPPDATA%\Claude-3p\configLibrary)
#      with a uuid file name — NO manual file editing, no JSON knowledge needed.
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
#   -FixedName   use a fixed file name (aiorouter.json) instead of a uuid
#   -NoMeta      skip writing/merging _meta.json
#
# Security:
#   - The API key is NEVER written by this script — you paste it in the GUI.
#   - No further remote execution beyond the initial template fetch.
#   - Review policy: you may run irm ... | iex directly, OR download the file,
#     inspect it, and run `powershell -File install-claude.ps1`.
#   - Full guide: https://aiorouter.ca/claude-desktop-setup

param(
  [switch]$FixedName,
  [switch]$NoMeta
)
$ErrorActionPreference = "Stop"

Write-Host "==============================================" -ForegroundColor Cyan
Write-Host "  AIOrouter x Claude Desktop — one-line setup" -ForegroundColor Cyan
Write-Host "==============================================" -ForegroundColor Cyan
Write-Host "This places the AIOrouter Configuration file into Claude Desktop's" -ForegroundColor White
Write-Host "config library automatically (same file the GUI import would fetch)." -ForegroundColor White
Write-Host "You never edit a JSON file — you only paste your API key in the UI." -ForegroundColor White
Write-Host "Claude Desktop does NOT need to be closed — the script works even" -ForegroundColor White
Write-Host "while the app is running (Apply Changes restarts it automatically)." -ForegroundColor White

# 1. Resolve the 3P config library dir (mirrors the Claude Desktop runtime path).
#    CLAUDE_USER_DATA_DIR overrides the whole userData root when set.
if ($env:CLAUDE_USER_DATA_DIR -and $env:CLAUDE_USER_DATA_DIR.Trim()) {
    $libraryDir = Join-Path $env:CLAUDE_USER_DATA_DIR.Trim() "configLibrary"
} elseif ($env:LOCALAPPDATA -and $env:LOCALAPPDATA.Trim()) {
    $libraryDir = Join-Path (Join-Path $env:LOCALAPPDATA.Trim() "Claude-3p") "configLibrary"
} else {
    Write-Host "`n❌ Could not resolve the Claude Desktop config directory (LOCALAPPDATA missing)." -ForegroundColor Red
    Write-Host "   Use the GUI path instead: Settings → Interface Configuration → Configure" -ForegroundColor Yellow
    Write-Host "   Third-Party Inference… → Import Configuration file → paste the URL." -ForegroundColor Yellow
    exit 1
}

# 2. Download the official AIOrouter Configuration template (same URL the GUI
#    "Import Configuration file" would fetch — no drift between the two paths).
$templateUrl = "https://api.aiorouter.ca/claude-desktop-template.json"
Write-Host "`n⬇️  Downloading the AIOrouter Configuration file..." -ForegroundColor Cyan
try {
    $template = (Invoke-WebRequest -Uri $templateUrl -UseBasicParsing -ErrorAction Stop).Content
} catch {
    Write-Host "`n❌ Could not download the Configuration file ($templateUrl)." -ForegroundColor Red
    Write-Host "   Check your internet connection, then use the GUI path instead:" -ForegroundColor Yellow
    Write-Host "   Settings → Interface Configuration → Configure Third-Party Inference…" -ForegroundColor Yellow
    Write-Host "   → Import Configuration file → paste: $templateUrl" -ForegroundColor Yellow
    exit 1
}
try {
    $null = $template | ConvertFrom-Json
} catch {
    Write-Host "`n❌ Downloaded template is not valid JSON — aborting (nothing written)." -ForegroundColor Red
    exit 1
}

# 3. Back up any existing AIOrouter profile (principle C: backup before write).
$id = if ($FixedName) { "aiorouter" } else { [guid]::NewGuid().ToString() }
$profilePath = Join-Path $libraryDir "$id.json"
if (Test-Path $profilePath) {
    $backup = "$profilePath.bak.$(Get-Date -Format 'yyyyMMddHHmmss')"
    Copy-Item $profilePath $backup
    Write-Host "📦 Backed up existing profile → $backup"
}

# 4. Write the profile (UTF-8, no BOM — the same encoding the bridge uses).
New-Item -ItemType Directory -Path $libraryDir -Force | Out-Null
[System.IO.File]::WriteAllText($profilePath, $template, (New-Object System.Text.UTF8Encoding($false)))
Write-Host "✅ AIOrouter Configuration written → $profilePath"

# 5. Write/merge _meta.json (unless -NoMeta). Keeps entries from other
#    profiles intact; appliedId always points at this profile.
if (-not $NoMeta) {
    $metaPath = Join-Path $libraryDir "_meta.json"
    $meta = $null
    if (Test-Path $metaPath) {
        try { $meta = Get-Content -Path $metaPath -Raw | ConvertFrom-Json } catch { $meta = $null }
    }
    if ($null -eq $meta -or $null -eq $meta.entries) {
        $meta = [ordered]@{ appliedId = $id; entries = @() }
    }
    $entries = @($meta.entries)
    $existing = $entries | Where-Object { $_.id -eq $id }
    if ($null -eq $existing) {
        $entries += [ordered]@{ id = $id; name = "AIOrouter" }
    }
    $metaOut = [ordered]@{
        appliedId = $id
        entries   = $entries
    }
    $metaJson = $metaOut | ConvertTo-Json -Depth 6
    [System.IO.File]::WriteAllText($metaPath, $metaJson, (New-Object System.Text.UTF8Encoding($false)))
    Write-Host "✅ _meta.json updated (other profiles preserved)"
}

# 6. Next steps — the scripted part is done; the key is always entered in the GUI.
Write-Host "`n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
Write-Host "✅ Done — the AIOrouter Configuration file is installed." -ForegroundColor Green
Write-Host "   The API key is intentionally NOT written by this script — you paste" -ForegroundColor White
Write-Host "   it in the UI (never stored in plaintext by us)." -ForegroundColor White
Write-Host "`nNext steps (1-2 minutes):" -ForegroundColor Cyan
Write-Host "  1. Open Claude Desktop (or keep it open — no need to close it first)." -ForegroundColor White
Write-Host "  2. If a banner appears: 'Your provider setup needs a fix' → click" -ForegroundColor White
Write-Host "     Open Setup — the 'AIOrouter' profile is already loaded (no Import" -ForegroundColor White
Write-Host "     needed). No banner? Settings → Interface Configuration →" -ForegroundColor White
Write-Host "     Configure Third-Party Inference…" -ForegroundColor White
Write-Host "  3. Paste your AIOrouter API key (dashboard.aiorouter.ca → API Keys)" -ForegroundColor White
Write-Host "     into the Gateway API key field · auth scheme x-api-key." -ForegroundColor White
Write-Host "  4. Test Connection → green ✓, then click Apply Changes — Claude" -ForegroundColor White
Write-Host "     Desktop restarts automatically — your model picker now lists all" -ForegroundColor White
Write-Host "     19 AIOrouter models 🎉" -ForegroundColor White
Write-Host "  5. Open a NEW chat and paste the 'Phase 2' continuation prompt from" -ForegroundColor White
Write-Host "     https://aiorouter.ca/claude-desktop-setup (§ Phase 2) to finish" -ForegroundColor White
Write-Host "     verification (the 'wow' test + protection walkthrough)." -ForegroundColor White
Write-Host "Full guide: https://aiorouter.ca/claude-desktop-setup" -ForegroundColor Green
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━`n" -ForegroundColor Cyan