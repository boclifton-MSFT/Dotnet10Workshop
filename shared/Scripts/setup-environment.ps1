# One-Time Workshop Environment Setup
# This script helps participants set up their development environment

param(
    [switch]$SkipSDKCheck,
    [switch]$Force
)

$ErrorActionPreference = "Stop"

Write-Host "🚀 .NET 8 → 10 Performance Lab Workshop Setup" -ForegroundColor Cyan
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
Write-Host ""

# Check if already set up
$setupMarker = Join-Path $PSScriptRoot "../../.workshop-setup-complete"
if ((Test-Path $setupMarker) -and -not $Force) {
    Write-Host "✅ Workshop environment already set up!" -ForegroundColor Green
    Write-Host ""
    Write-Host "To re-run setup, use: .\setup-environment.ps1 -Force" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Next steps:" -ForegroundColor Cyan
    Write-Host "  cd modules\module0-warmup" -ForegroundColor White
    exit 0
}

# Step 1: Verify prerequisites
Write-Host "Step 1: Verifying prerequisites..." -ForegroundColor Cyan
if (-not $SkipSDKCheck) {
    & "$PSScriptRoot\check-prerequisites.ps1"
    if ($LASTEXITCODE -ne 0) {
        Write-Host ""
        Write-Host "❌ Prerequisites check failed. Please install missing items." -ForegroundColor Red
        exit 1
    }
}
Write-Host "✅ Prerequisites verified" -ForegroundColor Green
Write-Host ""

# Step 2: Check execution policy
Write-Host "Step 2: Checking PowerShell execution policy..." -ForegroundColor Cyan
$policy = Get-ExecutionPolicy -Scope CurrentUser
if ($policy -eq "Restricted" -or $policy -eq "Undefined") {
    Write-Host "⚠️  Current execution policy: $policy" -ForegroundColor Yellow
    Write-Host "   Workshop scripts require RemoteSigned policy." -ForegroundColor Yellow
    Write-Host ""
    $response = Read-Host "Set execution policy to RemoteSigned for CurrentUser? (y/n)"
    if ($response -eq 'y' -or $response -eq 'Y') {
        try {
            Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser -Force
            Write-Host "✅ Execution policy updated" -ForegroundColor Green
        }
        catch {
            Write-Host "❌ Failed to set execution policy. You may need to run as Administrator." -ForegroundColor Red
            exit 1
        }
    }
    else {
        Write-Host "⚠️  Skipping execution policy update. Some scripts may not run." -ForegroundColor Yellow
    }
}
else {
    Write-Host "✅ Execution policy is $policy" -ForegroundColor Green
}
Write-Host ""

# Step 3: Verify folder structure
Write-Host "Step 3: Verifying folder structure..." -ForegroundColor Cyan
$repoRoot = Split-Path (Split-Path $PSScriptRoot -Parent) -Parent
$requiredFolders = @(
    "modules",
    "shared\Scripts",
    "artifacts",
    "docs"
)

foreach ($folder in $requiredFolders) {
    $path = Join-Path $repoRoot $folder
    if (-not (Test-Path $path)) {
        Write-Host "   Creating $folder..." -ForegroundColor Yellow
        New-Item -ItemType Directory -Path $path -Force | Out-Null
    }
}
Write-Host "✅ Folder structure verified" -ForegroundColor Green
Write-Host ""

# Step 4: Mark setup complete
Write-Host "Step 4: Marking setup complete..." -ForegroundColor Cyan
@"
Workshop environment setup completed on: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')

Ready to start the workshop!
"@ | Out-File -FilePath $setupMarker -Encoding UTF8
Write-Host "✅ Setup complete!" -ForegroundColor Green
Write-Host ""

# Final instructions
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
Write-Host "🎉 You're all set!" -ForegroundColor Green
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Cyan
Write-Host "  1. cd modules\module0-warmup" -ForegroundColor White
Write-Host "  2. Read the README.md to understand the workshop goals" -ForegroundColor White
Write-Host "  3. Follow the modules sequentially (0 → 1 → 2 → ... → 6)" -ForegroundColor White
Write-Host ""
Write-Host "Workshop structure:" -ForegroundColor Cyan
Write-Host "  Module 0: Context (5 min)" -ForegroundColor White
Write-Host "  Module 1: Runtime Performance (20 min)" -ForegroundColor White
Write-Host "  Module 2: ASP.NET Core (25 min)" -ForegroundColor White
Write-Host "  Module 3: C# 14 Features (30 min)" -ForegroundColor White
Write-Host "  Module 4: EF Core (15 min)" -ForegroundColor White
Write-Host "  Module 5: Containers (10 min)" -ForegroundColor White
Write-Host "  Module 6: Migration Planning (5 min)" -ForegroundColor White
Write-Host ""
Write-Host "Total time: 110 minutes + 10 minute buffer = 2 hours" -ForegroundColor Cyan
Write-Host ""
