# DeepSeek TUI Launcher - pick your setup and go
$projectDir = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $projectDir

Write-Host ""
Write-Host "  ========================================" -ForegroundColor Cyan
Write-Host "       DeepSeek TUI Launcher"               -ForegroundColor Cyan
Write-Host "  ========================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "  Pick a mode:" -ForegroundColor Yellow
Write-Host "    1. Plan   - Read-only, explore only"
Write-Host "    2. Agent  - Interactive, asks before running"
Write-Host "    3. YOLO   - Auto-approve everything (use Docker)"
Write-Host ""
$modeChoice = Read-Host "  Enter 1, 2, or 3"

if ($modeChoice -eq "1") {
    $modeArg = "--plan"
} elseif ($modeChoice -eq "3") {
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
    $modelArg = "--model deepseek-v4-pro"
} elseif ($modelChoice -eq "F" -or $modelChoice -eq "f") {
    $modelArg = "--model deepseek-v4-flash"
} else {
    $modelArg = "--model auto"
}

Write-Host ""
Write-Host "  ========================================" -ForegroundColor Green
Write-Host "  Launching DeepSeek TUI"                    -ForegroundColor Green
Write-Host "    Mode:    $modeArg"                        -ForegroundColor White
Write-Host "    Model:   $modelArg"                       -ForegroundColor White
if ($useDocker) {
    Write-Host "    Runtime: Docker (sandboxed)"           -ForegroundColor White
} else {
    Write-Host "    Runtime: Native"                       -ForegroundColor White
}
Write-Host "  ========================================" -ForegroundColor Green
Write-Host ""

if ($useDocker) {
    docker run --rm -it `
        --env-file "$projectDir\.env" `
        -v "$env:USERPROFILE\.deepseek:/home/deepseek/.deepseek" `
        -v "${projectDir}:/workspace" `
        -w /workspace `
        ghcr.io/hmbown/deepseek-tui:latest `
        deepseek $modelArg $modeArg
} else {
    & deepseek $modelArg $modeArg
}
