# Measure memory usage under load for all 4 variants
# Requires: bombardier or wrk for load generation

$ErrorActionPreference = "Stop"

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Memory Usage Measurement (Under Load)" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
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

# Define test configurations
$variants = @(
    @{
        Name = ".NET 8 FX"
        Executable = "..\..\artifacts\pub8-fx\PricingService.exe"
        Port = 5000
    },
    @{
        Name = ".NET 8 AOT"
        Executable = "..\..\artifacts\pub8-aot\PricingService.exe"
        Port = 5001
    },
    @{
        Name = ".NET 10 FX"
        Executable = "..\..\artifacts\pub10-fx\PricingService.exe"
        Port = 5002
    },
    @{
        Name = ".NET 10 AOT"
        Executable = "..\..\artifacts\pub10-aot\PricingService.exe"
        Port = 5003
    }
)

$results = @{}

foreach ($variant in $variants) {
    Write-Host "Testing: $($variant.Name)" -ForegroundColor Yellow
    
    if (-not (Test-Path $variant.Executable)) {
        Write-Host "  ⚠️  Executable not found: $($variant.Executable)" -ForegroundColor Red
        continue
    }
    
    # Set environment variable for port
    $env:ASPNETCORE_URLS = "http://localhost:$($variant.Port)"
    
    # Start process
    $process = Start-Process -FilePath $variant.Executable `
        -WindowStyle Hidden `
        -PassThru
    
    # Wait for service to be ready
    Start-Sleep -Seconds 3
    
    Write-Host "  Warming up (100 requests)..." -ForegroundColor Gray
    # Warmup requests
    $warmupUrl = "http://localhost:$($variant.Port)/health"
    for ($i = 0; $i -lt 100; $i++) {
        try {
            Invoke-WebRequest -Uri $warmupUrl -Method GET -UseBasicParsing -ErrorAction SilentlyContinue | Out-Null
        }
        catch {
            # Ignore warmup errors
        }
    }
    
    Write-Host "  Applying load (500 req/sec for 30 seconds)..." -ForegroundColor Gray
    
    # Apply load in background
    $targetUrl = "http://localhost:$($variant.Port)/api/pricing/calculate"
    $loadJob = Start-Job -ScriptBlock {
        param($tool, $url)
        
        if ($tool -eq "bombardier") {
            & bombardier -c 10 -d 30s -r 500 -m POST `
                -H "Content-Type: application/json" `
                -b '{"sku":"WIDGET-001","quantity":5,"customerId":"CUST-001"}' `
                $url
        }
        else {
            # wrk fallback (requires Lua script for POST)
            & wrk -c 10 -d 30s -t 2 --latency $url
        }
    } -ArgumentList $loadTool, $targetUrl
    
    # Sample memory usage during load
    Start-Sleep -Seconds 5 # Allow load to ramp up
    
    $memorySamples = @()
    for ($i = 0; $i -lt 20; $i++) {
        Start-Sleep -Milliseconds 1000
        try {
            $proc = Get-Process -Id $process.Id -ErrorAction SilentlyContinue
            if ($proc) {
                $memoryMB = $proc.WorkingSet64 / 1MB
                $memorySamples += $memoryMB
            }
        }
        catch {
            # Process may have crashed
        }
    }
    
    # Wait for load test to complete
    Wait-Job $loadJob | Out-Null
    Remove-Job $loadJob -Force
    
    # Calculate peak memory
    if ($memorySamples.Count -gt 0) {
        $peakMemory = ($memorySamples | Measure-Object -Maximum).Maximum
        $avgMemory = ($memorySamples | Measure-Object -Average).Average
        $results[$variant.Name] = $peakMemory
        
        Write-Host "  Peak Memory: $([math]::Round($peakMemory, 1)) MB" -ForegroundColor Cyan
        Write-Host "  Avg Memory:  $([math]::Round($avgMemory, 1)) MB" -ForegroundColor Gray
    }
    else {
        Write-Host "  ❌ Could not sample memory" -ForegroundColor Red
    }
    
    # Graceful shutdown
    Stop-Process -Id $process.Id -Force -ErrorAction SilentlyContinue
    Start-Sleep -Seconds 1
    
    Write-Host ""
}

# Display summary
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Memory Usage Summary" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

foreach ($key in $results.Keys | Sort-Object) {
    $value = $results[$key]
    Write-Host "$key : $([math]::Round($value, 1)) MB (peak working set)" -ForegroundColor White
}

Write-Host ""

# Calculate improvements
if ($results.ContainsKey(".NET 8 FX") -and $results.ContainsKey(".NET 10 AOT")) {
    $baseline = $results[".NET 8 FX"]
    $best = $results[".NET 10 AOT"]
    $improvement = (($baseline - $best) / $baseline) * 100
    Write-Host "🏆 .NET 10 AOT uses $([math]::Round($improvement, 0))% less memory than .NET 8 FX" -ForegroundColor Green
}

Write-Host ""
Write-Host "Results saved to: results\memory-results.txt" -ForegroundColor Gray

# Save results to file
$resultsDir = "results"
if (-not (Test-Path $resultsDir)) {
    New-Item -ItemType Directory -Path $resultsDir | Out-Null
}

$output = @"
Memory Usage Measurement Results (Under Load)
Generated: $(Get-Date -Format "yyyy-MM-dd HH:mm:ss")
Load Tool: $loadTool

"@

foreach ($key in $results.Keys | Sort-Object) {
    $value = $results[$key]
    $output += "$key : $([math]::Round($value, 1)) MB (peak working set)`n"
}

$output | Out-File -FilePath "$resultsDir\memory-results.txt" -Encoding UTF8
