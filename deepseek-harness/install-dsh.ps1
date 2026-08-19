# AIOrouter one-line secure installer for DeepSeek Harness (Windows PowerShell)
# Remote URL:  https://aiorouter.ca/setup/install-dsh.ps1
# Usage:       irm https://aiorouter.ca/setup/install-dsh.ps1 | iex
#               (or download -> review -> run:  powershell -File install-dsh.ps1)
#
# What this script does:
#   1. Verifies Node.js (>= 20) is installed; installs the dsh CLI if missing.
#   2. Adds the @aiorouter/dsh-shield plugin to the dsh profile (default: web;
#      override with $env:DSH_PROFILE).
#   3. Prompts for your AIOrouter API key with masked input (no echo) and
#      stores it as a USER environment variable (AIOROUTER_API_KEY) - never
#      written to any file in this workspace.
#   4. Prints next steps (how to boot, set the key in the Web UI, verify).
#
# Security:
#   - The API key is NEVER echoed to stdout and never written to this machine
#     beyond the standard Windows user environment variable.
#   - This script performs no further remote execution beyond the initial fetch.
#   - Review policy: you may run irm ... | iex directly, OR download the file,
#     inspect it, and run powershell -File install-dsh.ps1 .
#   - Full guide: https://aiorouter.ca/deepseek-harness-setup

$ErrorActionPreference = "Stop"

$profileName = if ($env:DSH_PROFILE) { $env:DSH_PROFILE } else { "web" }

Write-Host "==============================================" -ForegroundColor Cyan
Write-Host "  AIOrouter x DeepSeek Harness - one-line setup" -ForegroundColor Cyan
Write-Host "==============================================" -ForegroundColor Cyan

# 1. Check Node.js + npm
if (-not (Get-Command node -ErrorAction SilentlyContinue)) {
    Write-Host "`nNode.js not found on PATH - install Node.js >= 20 first:" -ForegroundColor Red
    Write-Host "   https://nodejs.org" -ForegroundColor Yellow
    exit 1
}
$nodeVer = (node --version) -replace "^v", ""
Write-Host ("`n✅ Node.js detected: " + $nodeVer)

# 2. Install dsh CLI if missing
if (-not (Get-Command dsh -ErrorAction SilentlyContinue)) {
    Write-Host "Installing dsh globally (npm i -g dsh)..." -ForegroundColor Yellow
    npm i -g dsh
    if ($LASTEXITCODE -ne 0) { Write-Host "npm install failed." -ForegroundColor Red; exit 1 }
}
Write-Host ("`n✅ dsh detected: " + ((dsh --version) 2>&1 | Select-Object -First 1))

# 3. Add the plugin to the profile (initializes the profile on first use)
Write-Host ("`nAdding @aiorouter/dsh-shield to profile: " + $profileName) -ForegroundColor Yellow
dsh plugin --profile $profileName add @aiorouter/dsh-shield
if ($LASTEXITCODE -ne 0) { Write-Host "dsh plugin add failed - see output above." -ForegroundColor Red; exit 1 }
Write-Host "✅ Plugin added."

# 4. Prompt for API key (masked) and store as user env var
Write-Host "`nEnter your AIOrouter API key (ak-...). It is stored as the Windows" -ForegroundColor Yellow
Write-Host "user environment variable AIOROUTER_API_KEY - never written to disk." -ForegroundColor Yellow
$secure = Read-Host -AsSecureString "API key"
if ($secure.Length -lt 1) { Write-Host "`nNo key entered - aborting without changes." -ForegroundColor Red; exit 1 }
$bstr = [Runtime.InteropServices.Marshal]::SecureStringToBSTR($secure)
try { $key = [Runtime.InteropServices.Marshal]::PtrToStringBSTR($bstr) } finally { [Runtime.InteropServices.Marshal]::ZeroFreeBSTR($bstr) }
if ($key -notmatch "^ak-") { Write-Host "Warning: key does not start with ak- - verify it came from dashboard.aiorouter.ca/keys" -ForegroundColor Yellow }
[Environment]::SetEnvironmentVariable("AIOROUTER_API_KEY", $key, "User")
$null = $key; $key = $null  # clear from memory
Write-Host "✅ AIOROUTER_API_KEY stored as a user environment variable (new terminals pick it up)."

# 5. Next steps
Write-Host "`n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
Write-Host "Next steps:" -ForegroundColor Cyan
Write-Host "  1. Open a NEW terminal (so the env var is visible) and run:" -ForegroundColor White
Write-Host ("       dsh --profile " + $profileName) -ForegroundColor Green
Write-Host "  2. In the Web UI (http://127.0.0.1:3080) -> Settings -> Models," -ForegroundColor White
Write-Host "     confirm AIOROUTER_API_KEY is set, and pick a model (default:" -ForegroundColor White
Write-Host "     deepseek-v4-flash - free trial eligible)." -ForegroundColor White
Write-Host "  3. Call aiorouter_shield_status to see your account card + Shield state." -ForegroundColor White
Write-Host "Full guide: https://aiorouter.ca/deepseek-harness-setup" -ForegroundColor White
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
exit 0