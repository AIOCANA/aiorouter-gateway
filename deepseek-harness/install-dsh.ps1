# AIOrouter one-line secure installer for DeepSeek Harness (Windows PowerShell)
# Remote URL:  https://www.aiorouter.ca/setup/install-dsh.ps1
# Usage:       irm https://www.aiorouter.ca/setup/install-dsh.ps1 | iex
#              (review first: download the file, then powershell -File install-dsh.ps1)
#              verify later: & ([scriptblock]::Create((irm https://www.aiorouter.ca/setup/install-dsh.ps1))) -Verify
#
# What it does (AIOrouter Gateway route - no plugin; the retired
# @aiorouter/dsh-aiorouter-mas package is NOT installed):
#   1. checks Node.js >= 22 (Harness requirement);
#   2. checks DeepSeek Harness (dsh) and offers to install it when missing
#      (npm i -g @deepseek-ai/dsh);
#   3. prompts for your AIOrouter API key (masked input) and stores it as the user
#      environment variable AIOROUTER_API_KEY (R12: the value is never echoed and is
#      never written into settings.yaml);
#   4. writes the AIOrouter provider route into %USERPROFILE%\.dsh\settings.yaml
#      (or $env:DSH_HOME\settings.yaml when set):
#      llm-pi-ai.providers.aiorouter -> api: openai-completions, baseURL, apiKeyEnv, models;
#   5. verifies the key live against GET /v1/models AND checks that the harness route is
#      complete (api + at least one model), i.e. the part that silently failed before.
#   -Verify    only re-run the live key check + route check
#   -Uninstall remove the provider block (and forget the env var)
param([switch]$Verify, [switch]$Uninstall)
$ErrorActionPreference = 'Stop'
$SetupUrl = 'https://www.aiorouter.ca/setup/aiorouter-gateway-setup.mjs'
$Tmp = Join-Path $env:TEMP 'aiorouter-gateway-setup.mjs'
$SettingsArgs = @()
if ($env:DSH_HOME) { $SettingsArgs = @('--settings', (Join-Path $env:DSH_HOME 'settings.yaml')) }

Write-Host "`n=== AIOrouter Gateway setup (DeepSeek Harness) ===" -ForegroundColor Cyan

if (-not (Get-Command node -ErrorAction SilentlyContinue)) {
  Write-Host "Node.js not found. The Harness needs Node.js 22+ - install it from https://nodejs.org then re-run." -ForegroundColor Red
  exit 1
}
$nodeMajor = [int](((node -v) -replace '^v','' -split '\.')[0])
if ($nodeMajor -lt 22) { Write-Host "Node $(node -v) is too old - install Node 22+ (https://nodejs.org)." -ForegroundColor Red; exit 1 }

if ($Uninstall) {
  Invoke-WebRequest -UseBasicParsing $SetupUrl -OutFile $Tmp
  node $Tmp --uninstall @SettingsArgs
  [Environment]::SetEnvironmentVariable('AIOROUTER_API_KEY', $null, 'User')
  Remove-Item Env:AIOROUTER_API_KEY -ErrorAction SilentlyContinue
  Write-Host "`nUninstalled: provider block removed, AIOROUTER_API_KEY forgotten. Restart your Harness." -ForegroundColor Green
  exit 0
}

if ($Verify) {
  Invoke-WebRequest -UseBasicParsing $SetupUrl -OutFile $Tmp
  node $Tmp --verify-only @SettingsArgs
  $verifyExit = $LASTEXITCODE
  node $Tmp --check-route @SettingsArgs
  $routeExit = $LASTEXITCODE
  if ($verifyExit -ne 0 -or $routeExit -ne 0) { exit 1 }
  exit 0
}

# --- 0. DeepSeek Harness presence (the route is useless without the harness) ---
if (-not (Get-Command dsh -ErrorAction SilentlyContinue)) {
  Write-Host "`nDeepSeek Harness (dsh) was not found on PATH." -ForegroundColor Yellow
  Write-Host "Install it with:  npm i -g @deepseek-ai/dsh" -ForegroundColor Yellow
  $answer = Read-Host "Install it now? [y/N]"
  if ($answer -match '^[Yy]') {
    npm i -g @deepseek-ai/dsh
    if ($LASTEXITCODE -ne 0) { Write-Host "npm install failed - install Node.js 22+ and retry." -ForegroundColor Red; exit 1 }
    Write-Host "dsh installed." -ForegroundColor Green
  } else {
    Write-Host "Aborted. Install dsh first, then re-run this script." -ForegroundColor Red
    exit 1
  }
}

# --- 1. collect the key (masked) and store it as a user env var (R12: never echoed) ---
$existing = [Environment]::GetEnvironmentVariable('AIOROUTER_API_KEY','User')
if ($existing) {
  Write-Host "An AIOROUTER_API_KEY is already stored. Press Enter to keep it, or paste a new key." -ForegroundColor Yellow
} else {
  Write-Host "`nCreate a key at https://dashboard.aiorouter.ca (Keys) and paste it below." -ForegroundColor Yellow
}
$secure = Read-Host -AsSecureString "AIOrouter API key (input hidden; Enter = keep existing)"
if ($secure.Length -gt 0) {
  $bstr = [Runtime.InteropServices.Marshal]::SecureStringToBSTR($secure)
  try { $key = [Runtime.InteropServices.Marshal]::PtrToStringBSTR($bstr) } finally { [Runtime.InteropServices.Marshal]::ZeroFreeBSTR($bstr) }
  if ($key -notmatch '^ak-') { Write-Host "Warning: keys normally start with 'ak-' - continuing anyway." -ForegroundColor Yellow }
  [Environment]::SetEnvironmentVariable('AIOROUTER_API_KEY', $key, 'User')
  $env:AIOROUTER_API_KEY = $key
  Write-Host "Stored AIOROUTER_API_KEY as a user environment variable." -ForegroundColor Green
} elseif ($existing) {
  $env:AIOROUTER_API_KEY = $existing
  Write-Host "Keeping the existing key." -ForegroundColor Green
} else {
  Write-Host "No key entered - aborting without changes." -ForegroundColor Red; exit 1
}

# --- 2. patch settings.yaml, verify the key, then check the route DSH will load ---
Invoke-WebRequest -UseBasicParsing $SetupUrl -OutFile $Tmp
node $Tmp @SettingsArgs
if ($LASTEXITCODE -ne 0) { Write-Host "Setup reported a problem - see the output above." -ForegroundColor Red; exit $LASTEXITCODE }

node $Tmp --check-route @SettingsArgs
if ($LASTEXITCODE -ne 0) {
  Write-Host "The route block is incomplete - see the reason above. Do not restart yet." -ForegroundColor Red
  exit 1
}

Write-Host "`nDone. Restart your Harness (start-dsh.bat / dsh --profile web) so it re-reads settings.yaml." -ForegroundColor Cyan
Write-Host "Then: Settings -> Models should list the AIOrouter route with your catalog." -ForegroundColor Cyan
Write-Host "If it is missing: Settings -> Models -> Add model provider -> Custom model API;" -ForegroundColor Cyan
Write-Host "protocol openai-completions, base URL https://api.aiorouter.ca/v1." -ForegroundColor Cyan
Write-Host "Docs: https://www.aiorouter.ca/deepseek-harness-setup`n" -ForegroundColor Cyan
