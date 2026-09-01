# AIOrouter one-line secure installer for Codex (Windows PowerShell)
# Remote URL:  https://aiorouter.ca/setup/install-codex.ps1
# Usage:       irm https://aiorouter.ca/setup/install-codex.ps1 | iex
#               (or download → review → run:  powershell -File install-codex.ps1)
#
# What this script does:
#   1. Verifies Codex CLI is installed.
#   2. Backs up ~/.codex/config.toml AND ~/.codex/auth.json (if present).
#   3. Creates/merges ~/.codex/config.toml with the `aiorouter` model provider
#      (wire_api = "responses"). Never overwrites other providers.
#   4. Prompts for your AIOrouter API key with masked input (no echo), then
#      pipes it to `codex login --with-api-key` (stored in ~/.codex/auth.json —
#      shared by the desktop app and CLI). No plaintext key on disk.
#   5. Prints a "Phase 2" continuation prompt — paste it into a NEW chat after
#      restarting Codex to finish verification (restart wipes the session).
#
# Security:
#   - The API key is NEVER written into config.toml, never echoed to stdout.
#   - This script performs no further remote execution beyond the initial fetch.
#   - Review policy: you may run irm ... | iex directly, OR download the file,
#     inspect it, and run `powershell -File install-codex.ps1`.
#   - Full guide: https://aiorouter.ca/codex-integration

$ErrorActionPreference = "Stop"

Write-Host "==============================================" -ForegroundColor Cyan
Write-Host "  AIOrouter x Codex — one-line setup" -ForegroundColor Cyan
Write-Host "==============================================" -ForegroundColor Cyan
Write-Host "You will sign in with a FREE ChatGPT account once to install Codex." -ForegroundColor Yellow
Write-Host "After that you switch to your AIOrouter API key — all model usage is" -ForegroundColor Yellow
Write-Host "billed by AIOrouter, not OpenAI." -ForegroundColor Yellow

# 0. Warn if ChatGPT/Codex is still running in the BACKGROUND (window closed but
#    tray icon active). A running app process can overwrite ~/.codex/auth.json
#    (OAuth token refresh) right after `codex login` writes the AIOrouter key,
#    which silently breaks the setup (app shows your ChatGPT name instead of
#    AIOrouter). Many users don't know the app keeps running in the tray.
$bgProcs = Get-Process -ErrorAction SilentlyContinue | Where-Object { $_.ProcessName -match "^(ChatGPT|Codex|OpenAI)" }
if ($bgProcs) {
    Write-Host "`n⚠️  ChatGPT/Codex appears to be running in the background:" -ForegroundColor Yellow
    $bgProcs | Select-Object -ExpandProperty ProcessName -Unique | ForEach-Object { Write-Host "   - $_" -ForegroundColor Yellow }
    Write-Host "   A running app can overwrite auth.json AFTER this script writes your" -ForegroundColor Yellow
    Write-Host "   AIOrouter key, making the app show your ChatGPT name instead of AIOrouter." -ForegroundColor Yellow
    Write-Host "   Recommended: quit it fully (tray icon → right-click → Quit), ideally" -ForegroundColor Yellow
    Write-Host "   after a reboot with the app NOT started yet." -ForegroundColor Yellow
    Write-Host "   Continue anyway? (y/N)" -ForegroundColor Yellow
    $ans = Read-Host
    if ($ans -notmatch "^y") {
        Write-Host "Aborted — quit ChatGPT/Codex fully (including the tray icon), then re-run." -ForegroundColor Cyan
        exit 0
    }
}

# 1. Check Codex CLI
if (-not (Get-Command codex -ErrorAction SilentlyContinue)) {
    Write-Host "`n❌ Codex CLI not found on PATH." -ForegroundColor Red
    Write-Host "   Install Codex first: https://github.com/openai/codex" -ForegroundColor Yellow
    exit 1
}
Write-Host "`n✅ Codex CLI detected: $((codex --version) 2>&1 | Select-Object -First 1)"

# 2. Config directory + backups (config.toml AND auth.json)
$configDir = Join-Path $env:USERPROFILE ".codex"
$configPath = Join-Path $configDir "config.toml"
$authPath = Join-Path $configDir "auth.json"
if (-not (Test-Path $configDir)) { New-Item -ItemType Directory -Path $configDir -Force | Out-Null }

if (Test-Path $configPath) {
    $backup = "$configPath.bak.$(Get-Date -Format 'yyyyMMddHHmmss')"
    Copy-Item $configPath $backup
    Write-Host "`n📦 Backed up existing config → $backup"
}
if (Test-Path $authPath) {
    $authBackup = "$authPath.bak.$(Get-Date -Format 'yyyyMMddHHmmss')"
    Copy-Item $authPath $authBackup
    Write-Host "📦 Backed up existing login → $authBackup"
    Write-Host "   Your previous chat sessions are NOT deleted — Codex groups"
    Write-Host "   session history by login method. After switching to the AIOrouter"
    Write-Host "   key, ChatGPT-subscription sessions are hidden (not lost); they"
    Write-Host "   come back if you log in with ChatGPT again." -ForegroundColor Yellow
}

# 3. Write / merge the aiorouter provider block
$aiorouterBlock = @'
  
  # AIOrouter (auto-configured — https://aiorouter.ca/codex-integration)
  [model_providers.aiorouter]
  name = "AIOrouter"
  base_url = "https://api.aiorouter.ca/v1"
  wire_api = "responses"
  # Key comes from ~/.codex/auth.json (set by codex login --with-api-key below).
  # env_key is intentionally commented out: the desktop app's "Finish Windows
  # Setup" onboarding fails when a provider requires an environment variable it
  # cannot see (apps launched from the Start menu don't inherit new User env
  # vars until the next Windows sign-in). auth.json works everywhere.
  # env_key = "AIOROUTER_API_KEY"
  # env_key_instructions = "Get your key at https://dashboard.aiorouter.ca/keys"
'@

$modelListBlock = @'
  # ── AIOrouter × Codex — configuration ──────────────────────────────
  # How to switch models:
  #   1. Say "switch to X" in the app/CLI (SKILL + bridge — installed by this
  #      script). New chats use the new model immediately — no restart needed.
  #   2. Or uncomment exactly ONE "model =" line below (keep all others commented).
  #   3. Per run (CLI):  codex exec -m <model> "your prompt"
  #   4. Desktop App: the app's model menu is OpenAI-limited (hardcoded) — do
  #      NOT use it to switch; say "switch to X" in the chat instead (SKILL).
  # Full guide: https://aiorouter.ca/codex-integration
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
'@

# Ensure the model catalog file exists. config.toml references it via
# model_catalog_json; if the file is missing, codex fails to LOAD config
# ("Error loading configuration: The system cannot find the file specified.
#  (os error 2)") and `codex login` aborts. Codex also requires the catalog
# to contain AT LEAST ONE model ("must contain at least one model"), so we
# install a minimal catalog with the default model (deepseek-v4-flash);
# the bridge refreshes it on the first model switch (§12.3 lazy refresh).
# Also rebuild if it carries a UTF-8 BOM (older installer wrote one via
# Set-Content; serde_json rejects it: "expected value at line 1 column 1").
$catalogLocalPath = Join-Path $configDir "aiorouter-catalog.json"
$catalogHasBom = $false
if (Test-Path $catalogLocalPath) {
    $catalogBytes = [System.IO.File]::ReadAllBytes($catalogLocalPath)
    $catalogHasBom = ($catalogBytes.Length -ge 3 -and $catalogBytes[0] -eq 0xEF -and $catalogBytes[1] -eq 0xBB -and $catalogBytes[2] -eq 0xBF)
}
if ((-not (Test-Path $catalogLocalPath)) -or $catalogHasBom) {
    try {
        # Preferred: download the minimal valid catalog (1 model). Downloaded
        # bytes have no BOM, so serde_json parses it fine.
        Invoke-WebRequest -Uri "https://aiorouter.ca/setup/aiorouter-catalog.min.json" -OutFile $catalogLocalPath -UseBasicParsing -ErrorAction Stop
        Write-Host "Downloaded ~/.codex/aiorouter-catalog.json (1 model: deepseek-v4-flash - bridge refreshes on first switch)" -ForegroundColor Yellow
    }
    catch {
        # Fallback: embedded minimal catalog (same schema, BOM-less write).
        $minimalCatalog = '{"schema_version":1,"generated_at":"' + (Get-Date).ToUniversalTime().ToString("o") + '","models":[{"id":"deepseek-v4-flash","name":"DeepSeek V4 Flash","context_length":1000000,"max_completion_tokens":384000}]}'
        [System.IO.File]::WriteAllText($catalogLocalPath, $minimalCatalog, (New-Object System.Text.UTF8Encoding($false)))
        Write-Host "Created embedded minimal ~/.codex/aiorouter-catalog.json (download unavailable)" -ForegroundColor Yellow
    }
}

if (-not (Test-Path $configPath)) {
    @"
$modelListBlock

model_catalog_json = "$($configDir.Replace('\','\\'))\\aiorouter-catalog.json"

$aiorouterBlock
"@ | Set-Content -Path $configPath -Encoding utf8
    Write-Host "✅ Created ~/.codex/config.toml (aiorouter provider, default: deepseek-v4-flash)"
}
else {
    $existing = Get-Content $configPath -Raw
    $existingChanged = $false

    # P-11 (2026-08-15): a legacy UNCOMMENTED env_key / env_key_instructions
    # pair (written by older installer versions) makes Codex demand the
    # AIOROUTER_API_KEY env var and show "Missing environment variable:
    # AIOROUTER_API_KEY" when the app's process did not inherit it (launched
    # before the env var was set / Windows Explorer caches env) — even though
    # the key IS in ~/.codex/auth.json. Neutralize it on every merge so the
    # auth.json-first design (P-5/P-6) is the single source of truth;
    # env_key stays available only as a commented CLI fallback.
    $aiorouterHeader = $existing.IndexOf("[model_providers.aiorouter]")
    if ($aiorouterHeader -ge 0) {
        $nextTable = $existing.IndexOf("`n[", $aiorouterHeader + 1)
        $blockEnd = if ($nextTable -ge 0) { $nextTable } else { $existing.Length }
        $head = $existing.Substring(0, $aiorouterHeader)
        $block = $existing.Substring($aiorouterHeader, $blockEnd - $aiorouterHeader)
        $tail = $existing.Substring($blockEnd)
        $newBlock = $block -replace '(?m)^([ \t]*)(env_key|env_key_instructions)([ \t]*=)', '$1# $2$3'
        if ($newBlock -ne $block) {
            $existing = $head + $newBlock + $tail
            $existingChanged = $true
            Write-Host "ℹ️  Legacy env_key/env_key_instructions in [model_providers.aiorouter] commented out —" -ForegroundColor Yellow
            Write-Host "   the key is read ONLY from ~/.codex/auth.json (set by codex login below)." -ForegroundColor Yellow
        }
    }

    # TOML rule: a bare key AFTER any [table] belongs to that table. model /
    # model_provider / model_catalog_json must sit BEFORE the first [table]
    # (top level), otherwise Codex ignores them and falls back to OpenAI.
    if ($existing.StartsWith("[")) { $firstTable = 0 } else { $firstTable = $existing.IndexOf("`n[") }
    $headerEnd = if ($firstTable -ge 0) { $firstTable } else { $existing.Length }
    $hasTopLevelModelProvider = $existing.Substring(0, $headerEnd) -match "(?m)^model_provider\s*="
    $catalogLine = "model_catalog_json = `"$($configDir.Replace('\','\\'))\\aiorouter-catalog.json`""
    if ($existing -match "model_providers\.aiorouter") {
        if (-not $hasTopLevelModelProvider) {
            $modelTop = $modelListBlock + "`r`n" + $catalogLine + "`r`n"
            $existing = $existing.Insert($headerEnd, $modelTop)
            $existingChanged = $true
            Write-Host "ℹ️  aiorouter present — added top-level model list to ~/.codex/config.toml"
        }
        if ($existingChanged) {
            Set-Content -Path $configPath -Value $existing -Encoding utf8
        } else {
            Write-Host "ℹ️  ~/.codex/config.toml already contains aiorouter — skipped (no changes)"
        }
    }
    else {
        Add-Content -Path $configPath -Value $aiorouterBlock -Encoding utf8
        if (-not $hasTopLevelModelProvider) {
            $existing = [IO.File]::ReadAllText($configPath)
            if ($existing.StartsWith("[")) { $firstTable2 = 0 } else { $firstTable2 = $existing.IndexOf("`n[") }
            $headerEnd2 = if ($firstTable2 -ge 0) { $firstTable2 } else { $existing.Length }
            $modelTop = $modelListBlock + "`r`n" + $catalogLine + "`r`n"
            $existing = $existing.Insert($headerEnd2, $modelTop)
            Set-Content -Path $configPath -Value $existing -Encoding utf8
            Write-Host "✅ Merged aiorouter provider + top-level model list into ~/.codex/config.toml"
        } else {
            Write-Host "✅ Merged aiorouter provider into ~/.codex/config.toml (existing model line kept)"
        }
    }
}

# 4. Prompt for API key (masked) and pipe to codex login --with-api-key
Write-Host "`nEnter your AIOrouter API key (ak-...). It will be piped to" -ForegroundColor Cyan
Write-Host "codex login --with-api-key (stored in ~/.codex/auth.json — shared by the" -ForegroundColor Cyan
Write-Host "desktop app and CLI). Never paste the key into a chat window." -ForegroundColor Cyan
$secure = Read-Host "API key" -AsSecureString
if (-not $secure -or $secure.Length -eq 0) {
    Write-Host "❌ No key entered — aborting without changes." -ForegroundColor Red
    exit 1
}
$bstr = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($secure)
try {
    $plain = [System.Runtime.InteropServices.Marshal]::PtrToStringBSTR($bstr)
} finally {
    [System.Runtime.InteropServices.Marshal]::ZeroFreeBSTR($bstr)
}
if ($plain -notmatch "^ak-") {
    Write-Host "⚠️  Key does not start with 'ak-' — verify it came from dashboard.aiorouter.ca/keys" -ForegroundColor Yellow
}

Write-Host "`nRunning codex login --with-api-key (piping the key)..."
# PS 5.1 turns native-command stderr into a terminating error while
# ErrorActionPreference=Stop (codex prints progress to stderr). Lower it just
# for the login call so those normal lines don't abort the script.
$loginEAP = $ErrorActionPreference
$ErrorActionPreference = "Continue"
try {
    $loginOut = $plain | codex login --with-api-key 2>&1
} finally {
    $ErrorActionPreference = $loginEAP
}
$loginOut | ForEach-Object { Write-Host "  $_" }
$loginText = $loginOut -join " "
if ($LASTEXITCODE -eq 0 -or $loginText -match "Successfully logged in") {
    Write-Host "✅ codex login succeeded — key stored in ~/.codex/auth.json (app + CLI)." -ForegroundColor Green
} else {
    Write-Host "⚠️  codex login did not report success (exit $LASTEXITCODE)." -ForegroundColor Yellow
    Write-Host "   Re-run this script, or use the manual steps on https://aiorouter.ca/codex-integration" -ForegroundColor Yellow
}
$plain = $null  # clear from memory

  # Set the User-level environment variable so the provider's env_key works in
  # any newly launched terminal / app — no manual env setup needed. The value is
  # only ever in this process's memory, never echoed to the console or history.
  [Environment]::SetEnvironmentVariable("AIOROUTER_API_KEY", (Get-Content -Path (Join-Path $configDir "auth.json") -Raw | ConvertFrom-Json).OPENAI_API_KEY, "User")
  Write-Host "✅ User environment variable AIOROUTER_API_KEY set (new terminals/apps pick it up)." -ForegroundColor Green

# 5. Next steps + Phase 2 continuation prompt
Write-Host "`n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
Write-Host "Next steps:" -ForegroundColor Cyan
Write-Host "  1. Restart the ChatGPT/Codex desktop app once (including the tray" -ForegroundColor White
  Write-Host "     icon) so it loads the new config — a normal Phase 1 step. Switching" -ForegroundColor White
  Write-Host "     models later does NOT require quitting the app: just say" -ForegroundColor White
  Write-Host "     `"switch to X`" in the chat (SKILL + bridge)." -ForegroundColor White
Write-Host "  2. Relaunch — the bottom-left name should show 'AIOrouter'." -ForegroundColor White
Write-Host "  3. ⚠️ Restart wipes this session — open a NEW chat and paste the" -ForegroundColor Yellow
Write-Host "     'Phase 2' block below to finish verification." -ForegroundColor Yellow
Write-Host "Full guide: https://aiorouter.ca/codex-integration" -ForegroundColor Green
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━`n" -ForegroundColor Cyan

Write-Host "─────────────────────────────────────────────────────────────" -ForegroundColor Cyan
Write-Host "▶ PHASE 2 — paste into a NEW chat after restart:" -ForegroundColor Cyan
Write-Host "─────────────────────────────────────────────────────────────" -ForegroundColor Cyan
Write-Host 'I just restarted Codex after setting up AIOrouter (API key, config.toml,' -ForegroundColor White
Write-Host 'AGENTS.md). Please finish verifying and enable my setup:' -ForegroundColor White
Write-Host '' -ForegroundColor White
Write-Host '【5】Verify the connection — the "wow" test:' -ForegroundColor White
Write-Host '- Desktop app: I should see my account name at the bottom-left showing' -ForegroundColor White
Write-Host '  "AIOrouter" (not a ChatGPT/OpenAI account). Ask me to confirm that.' -ForegroundColor White
Write-Host '- Then ask me to paste this verification PROMPT in the main chat:' -ForegroundColor White
Write-Host '    My name is Jason Wang. What''s the second letter of my first name?' -ForegroundColor White
Write-Host '    Please type my name here and let me know what LLM see in my name.' -ForegroundColor White
Write-Host '  Expected: the LLM says it sees a placeholder (e.g. "Jason Wang") and' -ForegroundColor White
Write-Host '  cannot read my real name — that is proof the PII Shield is working.' -ForegroundColor White
Write-Host '- If the reply shows the LLM read a real name, STOP and tell me the' -ForegroundColor White
Write-Host '  shield is not active.' -ForegroundColor White
Write-Host '- (CLI users only) In a fresh terminal: codex exec -m deepseek-v4-flash "2+2=?"' -ForegroundColor White
Write-Host '  → expect "4" and output showing provider: aiorouter.' -ForegroundColor White
Write-Host '- Only say "setup complete" after the verification succeeds.' -ForegroundColor White
Write-Host '' -ForegroundColor White
Write-Host '【6】Explain how AIOrouter protects me — a short, friendly technical' -ForegroundColor White
Write-Host 'summary: AIOrouter replaces my personal/private values with placeholders' -ForegroundColor White
Write-Host 'BEFORE they reach the LLM, then restores them on the way back (Restore)' -ForegroundColor White
Write-Host 'or keeps them redacted (Redact) per my Dashboard settings — that''s why I' -ForegroundColor White
Write-Host 'see my correct name even though the LLM said it saw a placeholder.' -ForegroundColor White
  Write-Host 'Security secrets (passwords, API keys) default to Redact so the AI can' -ForegroundColor White
  Write-Host 'never write my real password into any file.' -ForegroundColor White
  Write-Host '' -ForegroundColor White
  Write-Host '【7】(Optional) A note about your plan:' -ForegroundColor White
Write-Host '- If on the free trial (25,000 tokens / 7 days, deepseek-v4-flash only):' -ForegroundColor White
    Write-Host '  unlock all 19 models at dashboard.aiorouter.ca → Billing → Choose a' -ForegroundColor White
    Write-Host '  Top-Up pack (from $10 CAD).' -ForegroundColor White
  Write-Host '- Secure Stripe checkout (Visa/MC/Amex, CAD) — we never store your full card number.' -ForegroundColor White
  Write-Host '- Your key keeps working — no re-setup, and it works with many BYOK tools.' -ForegroundColor White
  
  # 6. Install the AIOrouter model-switch skill (so you can just SAY "switch to X")
  Write-Host "`n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
  Write-Host "Installing the AIOrouter model-switch skill..." -ForegroundColor Cyan
  $skillDir = Join-Path $configDir "skills\aiorouter-model-switch"
  $skillPath = Join-Path $skillDir "SKILL.md"
  if (Test-Path $skillPath) {
      Write-Host "ℹ️  Skill already installed — nothing to do." -ForegroundColor Yellow
  }
  else {
      New-Item -ItemType Directory -Path $skillDir -Force | Out-Null
      try {
          Invoke-WebRequest -Uri "https://aiorouter.ca/setup/aiorouter-model-switch.skill.md" -OutFile $skillPath -UseBasicParsing -ErrorAction Stop
          Write-Host "✅ Model-switch skill installed. After the restart above, just say" -ForegroundColor Green
          Write-Host "   `"switch to X`" in the app/CLI — new chats use the model immediately." -ForegroundColor Green
      }
catch {
            # Fallback: append the AGENTS.md switch procedure (same steps, AI-driven)
            $agentsPath = Join-Path $configDir "AGENTS.md"
            $agentsFallback = @(
                ''
                '## AIOrouter model switch procedure'
                'When the user asks to "switch to / change to / use <model>":'
                '1. Read ~/.codex/config.toml'
                '2. Confirm model_provider = "aiorouter"; if not, tell the user you cannot proceed'
                '3. Determine if <model> is supported:'
                '   a. Check the commented "model =" list in ~/.codex/config.toml'
                '   b. If not there, fetch https://aiorouter.ca/docs/model-catalog (canonical list)'
                '   c. If the network is blocked, tell the user you could not verify the catalog and list the local models you know about'
                '4. If <model> is not supported → refuse, list available models, ask the user to re-specify. Do NOT edit config.toml.'
                '5. Edit config.toml (back it up first as config.toml.bak):'
                '   - Change the currently uncommented model = "..." line to the target model'
                '   - Keep exactly ONE uncommented "model =" line; leave all others commented'
                '   - If the target model line does not exist yet, add it (commented) first, then uncomment it — this keeps the local list up to date'
                '   - Do NOT change model_provider / base_url / env_key or anything else'
                '   - Do NOT add any new keys (no model_reasoning_effort, no notify, etc.)'
                '6. Re-read config.toml to verify: exactly one uncommented "model =" line and model_provider is still "aiorouter", and NO extra keys were added, then say: "Switched to <model> — new chats use it immediately (no restart needed)."'
            )
            Add-Content -Path $agentsPath -Value $agentsFallback -Encoding UTF8
          Write-Host "⚠️  Could not download the skill — appended the AGENTS.md fallback" -ForegroundColor Yellow
          Write-Host "   procedure instead (AI will follow it when you say `"switch to X`")." -ForegroundColor Yellow
      }
  }
  Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━`n" -ForegroundColor Cyan
