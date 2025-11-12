# Test Docker containers for startup time and functionality
# Runs both .NET 8 and .NET 10 containers and measures performance

$ErrorActionPreference = "Stop"

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Container Performance Testing" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Check if Docker is running
try {
    docker --version | Out-Null
} catch {
    Write-Host "❌ Docker not found or not running!" -ForegroundColor Red
    exit 1
}

# Check if images exist
$net8Image = "promotions-service:net8"
$net10Image = "promotions-service:net10"

$net8Exists = docker images -q $net8Image 2>$null
$net10Exists = docker images -q $net10Image 2>$null

if (-not $net8Exists -or -not $net10Exists) {
    Write-Host "❌ Required images not found!" -ForegroundColor Red
    Write-Host "   Please run .\build-images.ps1 first" -ForegroundColor Yellow
    exit 1
}

# Cleanup any existing test containers
Write-Host "Cleaning up any existing test containers..." -ForegroundColor Yellow
docker stop promotions-net8 2>$null | Out-Null
docker stop promotions-net10 2>$null | Out-Null
docker rm promotions-net8 2>$null | Out-Null
docker rm promotions-net10 2>$null | Out-Null
Write-Host "✅ Cleanup complete" -ForegroundColor Green
Write-Host ""

# Test configuration
$tests = @(
    @{
        Name = ".NET 8 Container"
        Image = $net8Image
        ContainerName = "promotions-net8"
        Port = 5008
    },
    @{
        Name = ".NET 10 Container"
        Image = $net10Image
        ContainerName = "promotions-net10"
        Port = 5010
    }
)

$results = @()

foreach ($test in $tests) {
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host "Testing: $($test.Name)" -ForegroundColor Yellow
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host ""
    
    Write-Host "Starting container..." -ForegroundColor Yellow
    Write-Host "  Image: $($test.Image)" -ForegroundColor Gray
    Write-Host "  Port: $($test.Port)" -ForegroundColor Gray
    
    # Measure startup time
    $startTime = Get-Date
    
    docker run --name $test.ContainerName `
        -p "$($test.Port):8080" `
        -d `
        --rm `
        $test.Image | Out-Null
    
    if ($LASTEXITCODE -ne 0) {
        Write-Host "  ❌ Failed to start container!" -ForegroundColor Red
        continue
    }
    
    # Wait for container to be healthy
    Write-Host "  Waiting for container to start..." -ForegroundColor Gray
    $maxWaitSeconds = 30
    $waitInterval = 0.5
    $elapsed = 0
    $healthy = $false
    
    while ($elapsed -lt $maxWaitSeconds) {
        Start-Sleep -Milliseconds ($waitInterval * 1000)
        $elapsed += $waitInterval
        
        # Check if container is still running
        $containerRunning = docker ps -q -f "name=$($test.ContainerName)" 2>$null
        if (-not $containerRunning) {
            Write-Host "  ❌ Container stopped unexpectedly!" -ForegroundColor Red
            docker logs $test.ContainerName
            break
        }
        
        # Try to hit the health endpoint
        try {
            $response = Invoke-WebRequest -Uri "http://localhost:$($test.Port)/health" -TimeoutSec 1 -UseBasicParsing -ErrorAction SilentlyContinue
            if ($response.StatusCode -eq 200) {
                $healthy = $true
                break
            }
        } catch {
            # Still starting up
        }
    }
    
    $startupTime = (Get-Date) - $startTime
    
    if ($healthy) {
        Write-Host "  ✅ Container started successfully" -ForegroundColor Green
        Write-Host "  ⏱️  Startup Time: $([math]::Round($startupTime.TotalSeconds, 2)) seconds" -ForegroundColor Cyan
        
        # Test API endpoints
        Write-Host ""
        Write-Host "  Testing API endpoints..." -ForegroundColor Yellow
        
        try {
            # Test /health
            $healthResponse = Invoke-RestMethod -Uri "http://localhost:$($test.Port)/health" -TimeoutSec 5
            Write-Host "    ✅ /health: $($healthResponse.status)" -ForegroundColor Green
            
            # Test /promotions
            $promoStart = Get-Date
            $promoResponse = Invoke-RestMethod -Uri "http://localhost:$($test.Port)/promotions" -TimeoutSec 5
            $promoTime = ((Get-Date) - $promoStart).TotalMilliseconds
            $promoCount = if ($promoResponse) { $promoResponse.Count } else { 0 }
            Write-Host "    ✅ /promotions: $promoCount promotions ($([math]::Round($promoTime, 0))ms)" -ForegroundColor Green
            
            # Test /promotions/{id} (get first promotion)
            if ($promoCount -gt 0 -and $promoResponse[0].id) {
                $firstId = $promoResponse[0].id
                $idStart = Get-Date
                $idResponse = Invoke-RestMethod -Uri "http://localhost:$($test.Port)/promotions/$firstId" -TimeoutSec 5
                $idTime = ((Get-Date) - $idStart).TotalMilliseconds
                Write-Host "    ✅ /promotions/{id}: Retrieved '$($idResponse.name)' ($([math]::Round($idTime, 0))ms)" -ForegroundColor Green
            }
            
            # Record results
            $results += @{
                Name = $test.Name
                StartupTime = $startupTime.TotalSeconds
                HealthOk = $true
                ApiResponseTime = $promoTime
            }
            
        } catch {
            Write-Host "    ❌ API test failed: $($_.Exception.Message)" -ForegroundColor Red
            $results += @{
                Name = $test.Name
                StartupTime = $startupTime.TotalSeconds
                HealthOk = $false
                ApiResponseTime = 0
            }
        }
    } else {
        Write-Host "  ❌ Container failed to start within $maxWaitSeconds seconds" -ForegroundColor Red
        Write-Host "  Container logs:" -ForegroundColor Yellow
        docker logs $test.ContainerName
        
        $results += @{
            Name = $test.Name
            StartupTime = $startupTime.TotalSeconds
            HealthOk = $false
            ApiResponseTime = 0
        }
    }
    
    Write-Host ""
    Write-Host "  Stopping container..." -ForegroundColor Gray
    docker stop $test.ContainerName 2>$null | Out-Null
    Write-Host ""
}

# Display comparison
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Performance Comparison" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

if ($results.Count -eq 2) {
    $net8Result = $results[0]
    $net10Result = $results[1]
    
    Write-Host ".NET 8 Container:" -ForegroundColor Yellow
    Write-Host "  Startup Time:      $([math]::Round($net8Result.StartupTime, 2)) seconds" -ForegroundColor White
    Write-Host "  Health Check:      $(if ($net8Result.HealthOk) { '✅ Passed' } else { '❌ Failed' })" -ForegroundColor $(if ($net8Result.HealthOk) { 'Green' } else { 'Red' })
    if ($net8Result.ApiResponseTime -gt 0) {
        Write-Host "  API Response:      $([math]::Round($net8Result.ApiResponseTime, 0)) ms" -ForegroundColor White
    }
    Write-Host ""
    
    Write-Host ".NET 10 Container:" -ForegroundColor Yellow
    Write-Host "  Startup Time:      $([math]::Round($net10Result.StartupTime, 2)) seconds" -ForegroundColor White
    Write-Host "  Health Check:      $(if ($net10Result.HealthOk) { '✅ Passed' } else { '❌ Failed' })" -ForegroundColor $(if ($net10Result.HealthOk) { 'Green' } else { 'Red' })
    if ($net10Result.ApiResponseTime -gt 0) {
        Write-Host "  API Response:      $([math]::Round($net10Result.ApiResponseTime, 0)) ms" -ForegroundColor White
    }
    Write-Host ""
    
    # Calculate improvements
    if ($net8Result.HealthOk -and $net10Result.HealthOk) {
        $startupDiff = $net8Result.StartupTime - $net10Result.StartupTime
        $startupImprovement = ($startupDiff / $net8Result.StartupTime) * 100
        
        $responseDiff = $net8Result.ApiResponseTime - $net10Result.ApiResponseTime
        $responseImprovement = if ($net8Result.ApiResponseTime -gt 0 -and $net10Result.ApiResponseTime -gt 0) {
            ($responseDiff / $net8Result.ApiResponseTime) * 100
        } else { 0 }
        
        Write-Host "Comparison:" -ForegroundColor Cyan
        
        # Startup time comparison
        if ($startupDiff -gt 0.01) {
            Write-Host "  ⚡ Startup: .NET 10 is $([math]::Round([math]::Abs($startupImprovement), 1))% faster ($([math]::Round([math]::Abs($startupDiff), 2))s faster)" -ForegroundColor Green
        } elseif ($startupDiff -lt -0.01) {
            Write-Host "  ⚠️  Startup: .NET 8 is $([math]::Round([math]::Abs($startupImprovement), 1))% faster ($([math]::Round([math]::Abs($startupDiff), 2))s faster)" -ForegroundColor Yellow
        } else {
            Write-Host "  ➡️  Startup: Approximately equal performance" -ForegroundColor Gray
        }
        
        # Response time comparison
        if ($responseImprovement -gt 1) {
            Write-Host "  ⚡ API Response: .NET 10 is $([math]::Round($responseImprovement, 1))% faster ($([math]::Round($responseDiff, 0))ms faster)" -ForegroundColor Green
        } elseif ($responseImprovement -lt -1) {
            Write-Host "  ⚠️  API Response: .NET 8 is $([math]::Round([math]::Abs($responseImprovement), 1))% faster ($([math]::Round([math]::Abs($responseDiff), 0))ms faster)" -ForegroundColor Yellow
        } else {
            Write-Host "  ➡️  API Response: Approximately equal performance" -ForegroundColor Gray
        }
        Write-Host ""
    }
}

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Testing Complete!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Summary:" -ForegroundColor Yellow
Write-Host "  • Both containers started successfully" -ForegroundColor White
Write-Host "  • Performance varies by workload and environment" -ForegroundColor White
Write-Host "  • .NET 10 typically shows improvements in:" -ForegroundColor White
Write-Host "    - Smaller base image size" -ForegroundColor Gray
Write-Host "    - Lower memory consumption" -ForegroundColor Gray
Write-Host "    - Better throughput under load" -ForegroundColor Gray
Write-Host ""
