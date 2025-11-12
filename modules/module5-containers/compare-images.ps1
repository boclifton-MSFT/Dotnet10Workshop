# Compare Docker image sizes between .NET 8 and .NET 10 versions
# Shows detailed breakdown and calculates improvements

$ErrorActionPreference = "Stop"

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Container Image Size Comparison" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Check if images exist
$net8Image = "promotions-service:net8"
$net10Image = "promotions-service:net10"

Write-Host "Checking for container images..." -ForegroundColor Yellow

$net8Exists = docker images -q $net8Image 2>$null
$net10Exists = docker images -q $net10Image 2>$null

if (-not $net8Exists -or -not $net10Exists) {
    Write-Host "❌ Required images not found!" -ForegroundColor Red
    Write-Host ""
    if (-not $net8Exists) {
        Write-Host "  Missing: $net8Image" -ForegroundColor Gray
    }
    if (-not $net10Exists) {
        Write-Host "  Missing: $net10Image" -ForegroundColor Gray
    }
    Write-Host ""
    Write-Host "Please run .\build-images.ps1 first" -ForegroundColor Yellow
    exit 1
}

Write-Host "✅ Both images found" -ForegroundColor Green
Write-Host ""

# Get image details
$net8Info = docker images $net8Image --format "{{.Size}}" | Select-Object -First 1
$net10Info = docker images $net10Image --format "{{.Size}}" | Select-Object -First 1

# Parse sizes (handle MB/GB formats)
function Parse-Size {
    param($sizeStr)
    
    if ($sizeStr -match '(\d+\.?\d*)\s*([MG]B)') {
        $value = [double]$matches[1]
        $unit = $matches[2]
        
        if ($unit -eq "GB") {
            return $value * 1024
        }
        return $value
    }
    return 0
}

$net8SizeMB = Parse-Size $net8Info
$net10SizeMB = Parse-Size $net10Info

# Calculate improvements
$sizeDiffMB = $net8SizeMB - $net10SizeMB
$percentImprovement = if ($net8SizeMB -gt 0) { ($sizeDiffMB / $net8SizeMB) * 100 } else { 0 }

# Get base image sizes (approximate from README)
$net8BaseMB = 216
$net10BaseMB = 190
$baseImprovementMB = $net8BaseMB - $net10BaseMB

# Calculate app layer sizes
$net8AppMB = $net8SizeMB - $net8BaseMB
$net10AppMB = $net10SizeMB - $net10BaseMB

# Display comparison
Write-Host "=== .NET 8 Container ===" -ForegroundColor Yellow
Write-Host "  Total Size:      $($net8SizeMB) MB" -ForegroundColor White
Write-Host "  Base Image:      ~$net8BaseMB MB (mcr.microsoft.com/dotnet/aspnet:8.0)" -ForegroundColor Gray
Write-Host "  App Layer:       ~$([math]::Round($net8AppMB, 1)) MB (PromotionsAPI + dependencies)" -ForegroundColor Gray
Write-Host ""

Write-Host "=== .NET 10 Container ===" -ForegroundColor Yellow
Write-Host "  Total Size:      $($net10SizeMB) MB" -ForegroundColor White
Write-Host "  Base Image:      ~$net10BaseMB MB (mcr.microsoft.com/dotnet/aspnet:10.0)" -ForegroundColor Gray
Write-Host "  App Layer:       ~$([math]::Round($net10AppMB, 1)) MB (PromotionsAPI + dependencies)" -ForegroundColor Gray
Write-Host ""

Write-Host "=== Improvement ===" -ForegroundColor Green
if ($sizeDiffMB -gt 0) {
    Write-Host "  Size Reduction:  $([math]::Round($sizeDiffMB, 1)) MB (-$([math]::Round($percentImprovement, 1))%)" -ForegroundColor Green
    Write-Host "  Base Image:      -$baseImprovementMB MB" -ForegroundColor Green
    Write-Host "  App Layer:       -$([math]::Round($net8AppMB - $net10AppMB, 1)) MB" -ForegroundColor Green
} elseif ($sizeDiffMB -lt 0) {
    Write-Host "  Size Increase:   $([math]::Abs([math]::Round($sizeDiffMB, 1))) MB (+$([math]::Round([math]::Abs($percentImprovement), 1))%)" -ForegroundColor Red
} else {
    Write-Host "  No size difference" -ForegroundColor Gray
}
Write-Host ""

# Calculate deployment impact at scale
Write-Host "=== Impact at Scale (example) ===" -ForegroundColor Cyan
Write-Host "  Assumptions: 240 stores × 5 pods = 1,200 pods" -ForegroundColor Gray
Write-Host ""

$podsPerDeployment = 1200
$net8TotalGB = ($net8SizeMB * $podsPerDeployment) / 1024
$net10TotalGB = ($net10SizeMB * $podsPerDeployment) / 1024
$bandwidthSavingsGB = $net8TotalGB - $net10TotalGB

Write-Host "  .NET 8 Deployment:   $([math]::Round($net8TotalGB, 1)) GB transferred" -ForegroundColor White
Write-Host "  .NET 10 Deployment:  $([math]::Round($net10TotalGB, 1)) GB transferred" -ForegroundColor White
if ($bandwidthSavingsGB -gt 0) {
    Write-Host "  Bandwidth Saved:     $([math]::Round($bandwidthSavingsGB, 1)) GB per deployment" -ForegroundColor Green
}
Write-Host ""

# Cost analysis (5 deployments per week)
$deploymentsPerWeek = 5
$costPerGB = 0.087  # Azure bandwidth cost
$weeklySavingsGB = $bandwidthSavingsGB * $deploymentsPerWeek
$weeklyCost = $weeklySavingsGB * $costPerGB
$annualCost = $weeklyCost * 52

if ($annualCost -gt 0) {
    Write-Host "=== Annual Cost Savings ===" -ForegroundColor Cyan
    Write-Host "  Deployments/Week:    $deploymentsPerWeek" -ForegroundColor Gray
    Write-Host "  Weekly Bandwidth:    $([math]::Round($weeklySavingsGB, 1)) GB saved" -ForegroundColor White
    Write-Host "  Weekly Cost:         `$$([math]::Round($weeklyCost, 2)) saved" -ForegroundColor Green
    Write-Host "  Annual Cost:         `$$([math]::Round($annualCost, 0)) saved" -ForegroundColor Green
    Write-Host ""
}

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Key Takeaways:" -ForegroundColor Yellow
Write-Host "  ✅ Smaller images = faster pulls" -ForegroundColor Green
Write-Host "  ✅ Faster pulls = quicker deployments" -ForegroundColor Green
Write-Host "  ✅ Quicker deployments = faster scaling" -ForegroundColor Green
if ($annualCost -gt 0) {
    Write-Host "  ✅ Lower bandwidth = cost savings" -ForegroundColor Green
}
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
