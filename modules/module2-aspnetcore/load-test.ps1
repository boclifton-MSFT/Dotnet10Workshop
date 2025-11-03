# Load test for PromotionsAPI comparing .NET 8 and .NET 10
# Requires: bombardier or wrk

param(
    [ValidateSet("NET8", "NET10")]
    [string]$Variant = "NET8",
    
    [int]$Duration = 30,
    [int]$Concurrency = 10,
    [int]$Warmup = 100
)

$ErrorActionPreference = "Stop"

# Determine which variant to test
$port = if ($Variant -eq "NET8") { 5100 } else { 5110 }
$executable = if ($Variant -eq "NET8") { "../../artifacts/prom8-fx/PromotionsAPI.exe" } else { "../../artifacts/prom10-fx/PromotionsAPI.exe" }
$resultsFile = "results/${Variant.ToLower()}-results.json"

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Load Test: $Variant" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Duration: $Duration seconds" -ForegroundColor Gray
Write-Host "Concurrency: $Concurrency connections" -ForegroundColor Gray
Write-Host ""

# Check for load testing tool
$loadTool = $null
if (Get-Command bombardier -ErrorAction SilentlyContinue) {
    $loadTool = "bombardier"
}
elseif (Get-Command wrk -ErrorAction SilentlyContinue) {
    $loadTool = "wrk"
}
else {
    Write-Host "❌ No load testing tool found!" -ForegroundColor Red
    Write-Host "Install bombardier: choco install bombardier" -ForegroundColor Yellow
    Write-Host "Or install wrk: choco install wrk" -ForegroundColor Yellow
    exit 1
}

Write-Host "Using load tool: $loadTool" -ForegroundColor Green
Write-Host ""

# Verify executable exists
if (-not (Test-Path $executable)) {
    Write-Host "❌ Executable not found: $executable" -ForegroundColor Red
    Write-Host "Run .\build-all.ps1 first" -ForegroundColor Yellow
    exit 1
}

# Set environment variable for port
$env:ASPNETCORE_URLS = "http://localhost:$port"
$env:ASPNETCORE_ENVIRONMENT = "Production"

# Start the application
Write-Host "Starting $Variant on port $port..." -ForegroundColor Yellow
$process = Start-Process -FilePath $executable -WindowStyle Hidden -PassThru

# Wait for startup
Start-Sleep -Seconds 3

# Verify service is ready
$healthUrl = "http://localhost:$port/health"
$timeout = 30
$elapsed = 0
$ready = $false

Write-Host "Waiting for service to be ready..." -ForegroundColor Gray
while ($elapsed -lt $timeout) {
    try {
        $response = Invoke-WebRequest -Uri $healthUrl -TimeoutSec 1 -ErrorAction SilentlyContinue
        if ($response.StatusCode -eq 200) {
            $ready = $true
            break
        }
    }
    catch {
        # Service not ready yet
    }
    Start-Sleep -Milliseconds 500
    $elapsed += 0.5
}

if (-not $ready) {
    Write-Host "❌ Service failed to start" -ForegroundColor Red
    Stop-Process -Id $process.Id -Force -ErrorAction SilentlyContinue
    exit 1
}

Write-Host "✅ Service ready" -ForegroundColor Green
Write-Host ""

# Warmup requests to populate cache (especially important for NET10)
Write-Host "Warming up cache with $Warmup requests..." -ForegroundColor Gray
$warmupUrl = "http://localhost:$port/promotions"
for ($i = 0; $i -lt $Warmup; $i++) {
    try {
        Invoke-WebRequest -Uri $warmupUrl -Method GET -UseBasicParsing -ErrorAction SilentlyContinue | Out-Null
    }
    catch {
        # Ignore warmup errors
    }
    if (($i + 1) % 25 -eq 0) {
        Write-Host "  $($i + 1)/$Warmup warmup requests completed" -ForegroundColor Gray
    }
}

Write-Host "✅ Warmup complete" -ForegroundColor Green
Write-Host ""

# Run load test
Write-Host "Applying load for $Duration seconds..." -ForegroundColor Yellow
$testUrl = "http://localhost:$port/promotions"
$startTime = Get-Date

if ($loadTool -eq "bombardier") {
    $output = & bombardier -c $Concurrency -d "${Duration}s" -r 500 -m GET `
        -t 10s --print-interval 5s $testUrl 2>&1 | Tee-Object -Variable bombOutput
    
    # Parse bombardier output
    $lines = $output -join "`n"
    $rpsMatch = $lines | Select-String "Requests/sec.*?(\d+\.?\d*)" -AllMatches
    $latencyMatch = $lines | Select-String "Average Latency.*?(\d+\.?\d*)" -AllMatches
    
    $results = @{
        variant = $Variant
        tool = "bombardier"
        duration = $Duration
        concurrency = $Concurrency
        timestamp = (Get-Date -Format 'yyyy-MM-dd HH:mm:ss')
        raw_output = $lines
    }
}
else {
    # wrk output (simplified parsing)
    $output = & wrk -c $Concurrency -d "${Duration}s" -t 2 --latency $testUrl 2>&1
    
    $lines = $output -join "`n"
    $results = @{
        variant = $Variant
        tool = "wrk"
        duration = $Duration
        concurrency = $Concurrency
        timestamp = (Get-Date -Format 'yyyy-MM-dd HH:mm:ss')
        raw_output = $lines
    }
}

$endTime = Get-Date

# Stop the application
Write-Host ""
Write-Host "Stopping service..." -ForegroundColor Gray
Stop-Process -Id $process.Id -Force -ErrorAction SilentlyContinue
Start-Sleep -Milliseconds 500

# Save results
$resultsDir = "results"
if (-not (Test-Path $resultsDir)) {
    New-Item -ItemType Directory -Path $resultsDir | Out-Null
}

$results | ConvertTo-Json | Out-File -FilePath $resultsFile -Encoding UTF8

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Load Test Complete" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Results saved to: $resultsFile" -ForegroundColor Green
Write-Host ""
Write-Host "Next: Run .\compare-results.ps1 to see comparison" -ForegroundColor Yellow
