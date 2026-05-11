# DeepSeek TUI Launcher - pick your setup and go
# Works from ANY folder. Just run: powershell -File "path\to\launch.ps1"
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$currentDir = Get-Location

Write-Host ""
Write-Host "  ========================================" -ForegroundColor Cyan
Write-Host "       DeepSeek TUI Launcher"               -ForegroundColor Cyan
Write-Host "  ========================================" -ForegroundColor Cyan
Write-Host "  Workspace: $currentDir"                   -ForegroundColor DarkGray
Write-Host ""

Write-Host "  Pick a mode:" -ForegroundColor Yellow
Write-Host "    1. Plan   - Read-only, explore only (Tab to cycle in TUI)"
Write-Host "    2. Agent  - Interactive, asks before running"
Write-Host "    3. YOLO   - Auto-approve everything (use Docker)"
Write-Host ""
$modeChoice = Read-Host "  Enter 1, 2, or 3"

if ($modeChoice -eq "3") {
    $modeArg = "--yolo"
} else {
    $modeArg = ""
}

Write-Host ""
Write-Host "  Pick runtime:" -ForegroundColor Yellow
Write-Host "    N. Native  - Instant, no Docker needed"
Write-Host "    D. Docker  - Sandboxed, safe for YOLO"
Write-Host ""
$runtimeChoice = Read-Host "  Enter N or D"

if ($runtimeChoice -eq "D" -or $runtimeChoice -eq "d") {
    $useDocker = $true
} else {
    $useDocker = $false
}

Write-Host ""
Write-Host "  Pick a model:" -ForegroundColor Yellow
Write-Host "    A. Auto   - Let DeepSeek choose per turn"
Write-Host "    P. Pro    - deepseek-v4-pro (best quality)"
Write-Host "    F. Flash  - deepseek-v4-flash (fast & cheap)"
Write-Host ""
$modelChoice = Read-Host "  Enter A, P, or F"

if ($modelChoice -eq "P" -or $modelChoice -eq "p") {
    $modelName = "deepseek-v4-pro"
} elseif ($modelChoice -eq "F" -or $modelChoice -eq "f") {
    $modelName = "deepseek-v4-flash"
} else {
    $modelName = "auto"
}

Write-Host ""
Write-Host "  ========================================" -ForegroundColor Green
Write-Host "  Launching DeepSeek TUI"                    -ForegroundColor Green
if ($modeChoice -eq "1") {
    Write-Host "    Mode:    Agent (press Tab for Plan)"     -ForegroundColor White
} elseif ($modeChoice -eq "3") {
    Write-Host "    Mode:    YOLO"                           -ForegroundColor White
} else {
    Write-Host "    Mode:    Agent"                          -ForegroundColor White
}
Write-Host "    Model:   --model $modelName"                 -ForegroundColor White
if ($useDocker) {
    Write-Host "    Runtime: Docker (sandboxed)"           -ForegroundColor White
} else {
    Write-Host "    Runtime: Native"                       -ForegroundColor White
}
Write-Host "  ========================================" -ForegroundColor Green
Write-Host ""

$cliArgs = @('--model', $modelName)
if ($modeArg) { $cliArgs += $modeArg }

$deepseekExe = "$env:APPDATA\npm\node_modules\deepseek-tui\bin\downloads\deepseek.exe"
$deepseekAlt = "$env:APPDATA\npm\deepseek.cmd"
$deepseekCmd = "deepseek"

if (Test-Path $deepseekExe) {
    $deepseekCmd = $deepseekExe
} elseif (Test-Path $deepseekAlt) {
    $deepseekCmd = $deepseekAlt
}

$envFile = "$scriptDir\.env"
if (-not (Test-Path $envFile)) {
    $envFile = "$currentDir\.env"
}

if ($useDocker) {
    docker run --rm -it `
        --env-file "$envFile" `
        -v "$env:USERPROFILE\.deepseek:/home/deepseek/.deepseek" `
        -v "${currentDir}:/workspace" `
        -w /workspace `
        ghcr.io/hmbown/deepseek-tui:latest `
        deepseek $cliArgs
} else {
    & $deepseekCmd $cliArgs
}
