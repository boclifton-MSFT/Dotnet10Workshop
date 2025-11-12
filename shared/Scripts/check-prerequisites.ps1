# Prerequisites Checker for .NET 8 → 10 Performance Lab Workshop
# This script verifies that the participant's environment is ready

param(
    [switch]$Json,
    [switch]$Verbose
)

$ErrorActionPreference = "Stop"
$results = @{
    Prerequisites = @()
    Warnings      = @()
    Errors        = @()
}

function Test-DotNetSDK {
    param([string]$Version)
    
    try {
        $sdks = & dotnet --list-sdks 2>$null
        $found = $sdks | Where-Object { $_ -like "$Version*" }
        return $found.Count -gt 0
    }
    catch {
        return $false
    }
}

function Test-CommandExists {
    param([string]$Command)
    
    try {
        $null = Get-Command $Command -ErrorAction Stop
        return $true
    }
    catch {
        return $false
    }
}

Write-Host "🔍 Checking workshop prerequisites..." -ForegroundColor Cyan
Write-Host ""

# Check PowerShell version
$psVersion = $PSVersionTable.PSVersion
if ($psVersion.Major -ge 5) {
    $results.Prerequisites += @{
        Name     = "PowerShell"
        Status   = "✅ PASS"
        Version  = "$($psVersion.Major).$($psVersion.Minor)"
        Required = "5.1+"
    }
    Write-Host "✅ PowerShell $($psVersion.Major).$($psVersion.Minor) found" -ForegroundColor Green
}
else {
    $results.Errors += "PowerShell 5.1+ required, found $($psVersion.Major).$($psVersion.Minor)"
    Write-Host "❌ PowerShell $($psVersion.Major).$($psVersion.Minor) - Need 5.1+" -ForegroundColor Red
}

# Check .NET 8 SDK
if (Test-DotNetSDK "8.0") {
    $sdk8 = (& dotnet --list-sdks | Where-Object { $_ -like "8.0*" } | Select-Object -First 1) -split ' ' | Select-Object -First 1
    $results.Prerequisites += @{
        Name     = ".NET 8 SDK"
        Status   = "✅ PASS"
        Version  = $sdk8
        Required = "8.0.x"
    }
    Write-Host "✅ .NET 8 SDK found: $sdk8" -ForegroundColor Green
}
else {
    $results.Errors += ".NET 8 SDK not found"
    Write-Host "❌ .NET 8 SDK not found" -ForegroundColor Red
    Write-Host "   Download from: https://dotnet.microsoft.com/download/dotnet/8.0" -ForegroundColor Yellow
}

# Check .NET 10 SDK (hypothetical for workshop)
if (Test-DotNetSDK "10.0") {
    $sdk10 = (& dotnet --list-sdks | Where-Object { $_ -like "10.0*" } | Select-Object -First 1) -split ' ' | Select-Object -First 1
    $results.Prerequisites += @{
        Name     = ".NET 10 SDK"
        Status   = "✅ PASS"
        Version  = $sdk10
        Required = "10.0.x"
    }
    Write-Host "✅ .NET 10 SDK found: $sdk10" -ForegroundColor Green
}
else {
    $results.Warnings += ".NET 10 SDK not found (hypothetical for workshop demo)"
    Write-Host "⚠️  .NET 10 SDK not found" -ForegroundColor Yellow
    Write-Host "   Note: For workshop purposes, we'll use .NET 9 as .NET 10 placeholder" -ForegroundColor Yellow
}

# Check Git
if (Test-CommandExists "git") {
    $gitVersion = (& git --version) -replace 'git version ', ''
    $results.Prerequisites += @{
        Name     = "Git"
        Status   = "✅ PASS"
        Version  = $gitVersion
        Required = "2.x+"
    }
    Write-Host "✅ Git found: $gitVersion" -ForegroundColor Green
}
else {
    $results.Warnings += "Git not found (recommended for version control)"
    Write-Host "⚠️  Git not found (recommended)" -ForegroundColor Yellow
}

# Check Docker (optional)
if (Test-CommandExists "docker") {
    try {
        $dockerVersion = (& docker --version) -replace 'Docker version ', '' -replace ',.*', ''
        $results.Prerequisites += @{
            Name     = "Docker"
            Status   = "✅ PASS"
            Version  = $dockerVersion
            Required = "20.x+ (optional)"
        }
        Write-Host "✅ Docker found: $dockerVersion (Module 5 available)" -ForegroundColor Green
    }
    catch {
        $results.Warnings += "Docker installed but not running"
        Write-Host "⚠️  Docker installed but not running (Module 5 will be skipped)" -ForegroundColor Yellow
    }
}
else {
    $results.Warnings += "Docker not found (Module 5 will be skipped)"
    Write-Host "⚠️  Docker not found (Module 5 will be skipped)" -ForegroundColor Yellow
}

# Check load testing tools (optional)
$loadTestTool = $null
if (Test-CommandExists "bombardier") {
    $loadTestTool = "bombardier"
    $results.Prerequisites += @{
        Name     = "Load Testing Tool"
        Status   = "✅ PASS"
        Version  = "bombardier"
        Required = "optional"
    }
    Write-Host "✅ bombardier found (Module 2 load testing available)" -ForegroundColor Green
}
elseif (Test-CommandExists "wrk") {
    $loadTestTool = "wrk"
    $results.Prerequisites += @{
        Name     = "Load Testing Tool"
        Status   = "✅ PASS"
        Version  = "wrk"
        Required = "optional"
    }
    Write-Host "✅ wrk found (Module 2 load testing available)" -ForegroundColor Green
}
else {
    $results.Warnings += "No load testing tool found (Module 2 will use pre-provided results)"
    Write-Host "⚠️  No load testing tool found (Module 2 will use pre-provided results)" -ForegroundColor Yellow
    Write-Host "   Install bombardier: https://github.com/codesenberg/bombardier/releases" -ForegroundColor Yellow
}

# Summary
Write-Host ""
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
Write-Host "Summary" -ForegroundColor Cyan
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan

$passCount = ($results.Prerequisites | Where-Object { $_.Status -eq "✅ PASS" }).Count
$errorCount = $results.Errors.Count
$warningCount = $results.Warnings.Count

Write-Host "✅ Passed: $passCount" -ForegroundColor Green
if ($errorCount -gt 0) {
    Write-Host "❌ Errors: $errorCount" -ForegroundColor Red
}
if ($warningCount -gt 0) {
    Write-Host "⚠️  Warnings: $warningCount" -ForegroundColor Yellow
}

Write-Host ""

if ($errorCount -eq 0) {
    Write-Host "🎉 You're ready to start the workshop!" -ForegroundColor Green
    Write-Host ""
    Write-Host "Next steps:" -ForegroundColor Cyan
    Write-Host "  1. cd modules\module0-warmup" -ForegroundColor White
    Write-Host "  2. Read the README.md to understand the workshop goals" -ForegroundColor White
}
else {
    Write-Host "⚠️  Please install the missing required prerequisites before starting." -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Required:" -ForegroundColor Cyan
    foreach ($error in $results.Errors) {
        Write-Host "  - $error" -ForegroundColor Red
    }
}

if ($warningCount -gt 0 -and $errorCount -eq 0) {
    Write-Host ""
    Write-Host "Optional items missing (workshop can proceed):" -ForegroundColor Cyan
    foreach ($warning in $results.Warnings) {
        Write-Host '⚠️  ' -NoNewline -ForegroundColor Yellow
        Write-Host "- $warning" -ForegroundColor Yellow    
    }
}

# JSON output if requested
if ($Json) {
    $results | ConvertTo-Json -Depth 10
}

# Exit with appropriate code
if ($errorCount -gt 0) {
    exit 1
}
else {
    exit 0
}
