# Build Docker images for PromotionsAPI (.NET 8 and .NET 10)
# Requires: Docker Desktop running and artifacts from module2

$ErrorActionPreference = "Stop"

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Building PromotionsAPI Container Images" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Check if Docker is running
Write-Host "Checking Docker..." -ForegroundColor Yellow
try {
    $dockerVersion = docker --version
    Write-Host "✅ Docker found: $dockerVersion" -ForegroundColor Green
} catch {
    Write-Host "❌ Docker not found or not running!" -ForegroundColor Red
    Write-Host "   Please install Docker Desktop and ensure it's running." -ForegroundColor Yellow
    exit 1
}
Write-Host ""

# Check if artifacts exist
Write-Host "Checking for PromotionsAPI artifacts..." -ForegroundColor Yellow
$artifacts = @(
    "../../artifacts/prom8-fx",
    "../../artifacts/prom10-fx"
)

$missingArtifacts = @()
foreach ($artifact in $artifacts) {
    if (-not (Test-Path $artifact)) {
        $missingArtifacts += $artifact
    }
}

if ($missingArtifacts.Count -gt 0) {
    Write-Host "❌ Missing required artifacts!" -ForegroundColor Red
    Write-Host "   The following directories are missing:" -ForegroundColor Yellow
    foreach ($missing in $missingArtifacts) {
        Write-Host "   • $missing" -ForegroundColor Gray
    }
    Write-Host ""
    Write-Host "Please run the following first:" -ForegroundColor Yellow
    Write-Host "   cd ..\module2-aspnetcore" -ForegroundColor Gray
    Write-Host "   .\build-all.ps1" -ForegroundColor Gray
    Write-Host "   cd ..\module5-containers" -ForegroundColor Gray
    exit 1
}
Write-Host "✅ All artifacts found" -ForegroundColor Green
Write-Host ""

# Define image configurations
$images = @(
    @{
        Name = "promotions-service:net8"
        Dockerfile = "Dockerfile.net8"
        Description = ".NET 8 Container"
    },
    @{
        Name = "promotions-service:net10"
        Dockerfile = "Dockerfile.net10"
        Description = ".NET 10 Container"
    }
)

# Build each image
foreach ($image in $images) {
    Write-Host "Building: $($image.Description)" -ForegroundColor Yellow
    Write-Host "  Image: $($image.Name)" -ForegroundColor Gray
    Write-Host "  Dockerfile: $($image.Dockerfile)" -ForegroundColor Gray
    
    $startTime = Get-Date
    
    # Build the Docker image from repository root
    # This allows Dockerfile to access artifacts/ folder
    $repoRoot = Resolve-Path "..\..\"
    $dockerfilePath = Join-Path $PSScriptRoot $image.Dockerfile
    
    docker build -f $dockerfilePath -t $image.Name $repoRoot
    
    if ($LASTEXITCODE -ne 0) {
        Write-Host "  ❌ Build failed!" -ForegroundColor Red
        exit 1
    }
    
    $duration = (Get-Date) - $startTime
    Write-Host "  ✅ Build succeeded in $([math]::Round($duration.TotalSeconds, 1)) seconds" -ForegroundColor Green
    Write-Host ""
}

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "All images built successfully!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Images created:" -ForegroundColor Yellow
docker images | Select-String "promotions-service"
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Yellow
Write-Host "  1. Run .\compare-images.ps1 to compare image sizes" -ForegroundColor Gray
Write-Host "  2. Run .\test-containers.ps1 to test startup performance" -ForegroundColor Gray
