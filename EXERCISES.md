# .NET 10 Workshop - Hands-On Exercises

This document provides extended exercises for each module in the .NET 10 Workshop. Each exercise is designed to let you explore the features demonstrated in the module through practical, hands-on tasks.

---

## Module 0: Warm-Up

**Prerequisites Check**

Before starting the workshop modules, complete these tasks:

### Exercise 0.1: Environment Verification
1. Run the prerequisite check script:
   ```powershell
   .\shared\Scripts\check-prerequisites.ps1
   ```
2. Verify all required tools are installed:
   - .NET 8 SDK
   - .NET 10 SDK
   - Docker Desktop
   - PowerShell 7+
3. If any tools are missing, install them before proceeding

### Exercise 0.2: Project Familiarization
1. Open the solution in VS Code: `Dotnet10Workshop.slnx`
2. Explore the folder structure in `modules/`
3. Review the main README.md to understand workshop objectives
4. Run `dotnet sln list` to see all projects

---

## Module 1: Runtime Performance

**Learning Objective**: Understand and measure the performance differences between .NET 8 and .NET 10 deployment models (Framework-Dependent vs Native AOT).

### Exercise 1.1: Baseline Measurements
1. Navigate to `modules/module1-runtime/`
2. Run the pre-built measurements:
   ```powershell
   .\measure-coldstart.ps1
   .\measure-size.ps1
   .\measure-memory.ps1
   ```
3. Document your results in a new file `results/my-baseline.md`
4. Compare your results with the expected metrics in README.md

**Expected Outcomes**:
- Understand cold-start time differences (800ms → 120ms with AOT)
- See binary size tradeoffs (2MB FX vs 12MB AOT)
- Measure memory usage improvements (80MB → 40MB with AOT)

### Exercise 1.2: Build All Variants
1. Build all four deployment variants:
   ```powershell
   .\build-all.ps1
   ```
2. While building, examine the differences in `01-PricingService.csproj`:
   - Find the `<TargetFramework>` settings
   - Locate the `<PublishAot>` property
   - Review the conditional compilation symbols
3. After build completes, inspect the output folders in `../../artifacts/`
4. Compare file sizes and contents between FX and AOT builds

**Challenge Questions**:
- Why is the AOT binary larger but the container image smaller?
- What files are present in FX builds that are missing from AOT builds?
- How does the startup code differ between the variants?

### Exercise 1.3: Custom Pricing Endpoint
1. Add a new endpoint to `Program.cs` that calculates bulk pricing:
   ```csharp
   app.MapPost("/api/pricing/bulk", (BulkPricingRequest req) =>
   {
       var total = 0m;
       foreach (var item in req.Items)
       {
           var calculator = new PricingCalculator();
           total += calculator.Calculate(item).Total;
       }
       return new BulkPricingResponse { GrandTotal = total };
   });
   ```
2. Define `BulkPricingRequest` and `BulkPricingResponse` classes
3. Rebuild all variants
4. Re-run measurements - did the new endpoint affect performance?

### Exercise 1.4: AOT Compatibility Investigation
1. Try adding a feature that's NOT AOT-compatible (e.g., `System.Reflection.Emit`)
2. Attempt to build the AOT variant - observe the compiler warnings
3. Research why this feature isn't supported in AOT
4. Remove the incompatible code and verify AOT builds again

### Exercise 1.5: Kubernetes Deployment Simulation
1. Create a simple load test script that simulates pod scaling:
   ```powershell
   # Simulate starting 10 pods sequentially
   for ($i = 1; $i -le 10; $i++) {
       $time = Measure-Command {
           Start-Process -FilePath ".\artifacts\pub10-aot\PricingService.exe" -Wait
       }
       Write-Host "Pod $i started in $($time.TotalMilliseconds)ms"
   }
   ```
2. Run this for both .NET 8 and .NET 10 variants
3. Calculate total time to scale 10 pods

**Deliverable**: Create `results/module1-findings.md` with:
- Your measurement results
- Answers to challenge questions
- Analysis of when to use FX vs AOT

---

## Module 2: ASP.NET Core Performance (HTTP Caching & Rate Limiting)

**Learning Objective**: Implement and measure the impact of output caching and rate limiting on API throughput.

### Exercise 2.1: Baseline Load Testing
1. Navigate to `modules/module2-aspnetcore/`
2. Run load tests for both variants:
   ```powershell
   .\load-test.ps1 -Variant NET8 -Duration 30 -Concurrency 10
   .\load-test.ps1 -Variant NET10 -Duration 30 -Concurrency 10
   ```
3. Compare results:
   ```powershell
   .\compare-results.ps1
   ```
4. Document the throughput (RPS) and latency (p95) improvements

### Exercise 2.2: Custom Caching Strategy
1. Open `Program.cs` in the module directory
2. Modify the cache configuration to experiment with different TTL values:
   ```csharp
   .CacheOutput("promotions-cache", TimeSpan.FromSeconds(30))  // Changed from 10s
   ```
3. Rebuild and re-test:
   ```powershell
   .\build-all.ps1
   .\load-test.ps1 -Variant NET10
   ```
4. Try TTL values: 5s, 10s, 30s, 60s
5. Plot cache hit rate vs TTL - what's the sweet spot?

**Expected Learning**:
- Longer TTL = higher cache hit rate but staler data
- Optimal TTL depends on data freshness requirements
- Cache warming improves initial performance

### Exercise 2.3: Advanced Rate Limiting
1. Implement a sliding window rate limiter instead of fixed window:
   ```csharp
   builder.Services.AddRateLimiter(options =>
   {
       options.AddSlidingWindowLimiter("sliding", opt =>
       {
           opt.PermitLimit = 100;
           opt.Window = TimeSpan.FromSeconds(10);
           opt.SegmentsPerWindow = 5;  // Smoother distribution
       });
   });
   ```
2. Apply it to the validate endpoint:
   ```csharp
   app.MapPost("/promotions/validate", ...)
       .RequireRateLimiting("sliding");
   ```
3. Test with bombardier - observe 429 responses when rate limit is exceeded
4. Compare fixed vs sliding window behavior under bursty traffic

### Exercise 2.4: Per-User Rate Limiting
1. Add per-user rate limiting based on a custom header:
   ```csharp
   options.AddPolicy("per-user", context =>
   {
       var userId = context.Request.Headers["X-User-Id"].ToString();
       return RateLimitPartition.GetFixedWindowLimiter(userId, _ => new()
       {
           PermitLimit = 10,
           Window = TimeSpan.FromSeconds(10)
       });
   });
   ```
2. Test with curl using different user IDs:
   ```powershell
   curl -H "X-User-Id: user1" http://localhost:5000/promotions/validate
   curl -H "X-User-Id: user2" http://localhost:5000/promotions/validate
   ```
3. Verify each user gets their own rate limit quota

### Exercise 2.5: Cache Invalidation Strategy
1. Add a cache invalidation endpoint:
   ```csharp
   app.MapPost("/admin/cache/clear", async (IOutputCacheStore cache) =>
   {
       await cache.EvictByTagAsync("promotions", CancellationToken.None);
       return Results.Ok("Cache cleared");
   });
   ```
2. Tag your cached endpoints:
   ```csharp
   .CacheOutput(policy => policy.Tag("promotions"))
   ```
3. Test the workflow:
   - Load test to populate cache
   - Clear cache via admin endpoint
   - Observe cache rebuild on next requests

**Deliverable**: Create `results/module2-findings.md` with:
- Throughput improvements measured
- Optimal cache TTL for different scenarios
- Rate limiting strategy recommendations
- Cache invalidation patterns

---

## Module 3: C# 14 Language Features

**Learning Objective**: Apply modern C# 14 syntax to improve code maintainability and reduce boilerplate.

### Exercise 3.1: Extension Members for Discount Logic
1. Navigate to `modules/module3-csharp14/01-extension-members/`
2. Review the existing tax calculation example
3. Create a new extension for discount calculations:
   ```csharp
   extension(IProduct product)
   {
       public decimal ApplyDiscount(decimal percentage)
           => product.Price * (1 - percentage);
       
       public bool IsOnSale => product.Price < product.OriginalPrice;
   }
   ```
4. Add a similar extension for `IOrder`
5. Test both extensions work correctly
6. Compare with traditional extension method syntax

**Challenge**: Create an extension indexer that accesses product attributes by name

### Exercise 3.2: Field-Backed Properties for Validation
1. Navigate to `02-field-backed-props/`
2. Review the Money validation example
3. Create a `Product` class with validated properties:
   ```csharp
   public class Product
   {
       public string Name 
       { 
           get => field; 
           set => field = value?.Trim() ?? throw new ArgumentNullException();
       }
       
       public decimal Price 
       { 
           get => field; 
           set 
           { 
               if (value < 0) throw new ArgumentException("Price cannot be negative");
               if (value > 100000) Console.WriteLine("⚠️ Unusually high price!");
               field = value;
           }
       }
       
       public int Stock 
       { 
           get => field; 
           set 
           { 
               var oldValue = field;
               field = value;
               if (oldValue > 0 && value == 0)
                   Console.WriteLine($"Product {Name} is now out of stock!");
           }
       }
   }
   ```
4. Test all validation scenarios
5. Add logging to track property changes

### Exercise 3.3: Partial Constructors for Builder Pattern
1. Navigate to `03-partial-constructors/`
2. Create an `Order` class using partial constructors:
   ```csharp
   public partial class Order
   {
       // Base constructor with required fields
       public partial Order(string orderId, DateTime orderDate);
       
       // Extended constructor with validation
       public Order(string orderId, DateTime orderDate) : this(orderId, orderDate)
       {
           if (string.IsNullOrWhiteSpace(orderId))
               throw new ArgumentException("Order ID required");
           if (orderDate > DateTime.Now)
               throw new ArgumentException("Order date cannot be in future");
           
           Status = "Pending";
           Items = new List<OrderItem>();
       }
       
       public string OrderId { get; }
       public DateTime OrderDate { get; }
       public string Status { get; set; }
       public List<OrderItem> Items { get; set; }
   }
   ```
3. Add another partial constructor for loading from database (no validation)
4. Test both construction paths work correctly

### Exercise 3.4: Compound Operators for Domain Math
1. Navigate to `04-compound-operators/`
2. Create a `Quantity` value object with custom operators:
   ```csharp
   public record struct Quantity(int Value, string Unit)
   {
       public static Quantity operator +(Quantity a, Quantity b)
       {
           if (a.Unit != b.Unit) throw new InvalidOperationException("Units must match");
           return new Quantity(a.Value + b.Value, a.Unit);
       }
       
       public static Quantity operator ++(Quantity q)
           => new Quantity(q.Value + 1, q.Unit);
       
       // Add +=, -=, *=, /= compound operators
   }
   ```
3. Test inventory operations:
   ```csharp
   var stock = new Quantity(100, "units");
   stock += new Quantity(50, "units");  // Restock
   stock -= new Quantity(25, "units");  // Sale
   ```

### Exercise 3.5: Span Conversions for SKU Parsing
1. Navigate to `05-span-conversions/`
2. Create a high-performance SKU parser:
   ```csharp
   public readonly record struct SKU
   {
       public string Category { get; init; }
       public int Number { get; init; }
       
       public static SKU Parse(ReadOnlySpan<char> input)
       {
           var dashIndex = input.IndexOf('-');
           if (dashIndex == -1) throw new FormatException();
           
           var category = input[..dashIndex].ToString();
           var number = int.Parse(input[(dashIndex + 1)..]);
           
           return new SKU { Category = category, Number = number };
       }
   }
   ```
3. Benchmark against string-based parsing
4. Measure allocation differences with BenchmarkDotNet

### Exercise 3.6: Compile-Time Safety with nameof
1. Navigate to `06-nameof-generics/`
2. Create a generic repository with compile-time safe logging:
   ```csharp
   public class Repository<T> where T : class
   {
       private readonly Dictionary<string, List<T>> _cache = new();
       
       public void CacheEntities(List<T> entities)
       {
           var key = $"cache_{nameof(T)}";  // Compile-time safe!
           _cache[key] = entities;
           Console.WriteLine($"Cached {entities.Count} {nameof(T)} entities");
       }
       
       public List<T>? GetCached()
       {
           var key = $"cache_{nameof(T)}";
           return _cache.TryGetValue(key, out var cached) ? cached : null;
       }
   }
   ```
3. Test with different entity types (Product, Order, Customer)
4. Refactor entity names - verify compiler catches type name changes

**Deliverable**: Create `results/module3-findings.md` with:
- Code examples using each C# 14 feature
- Before/after comparisons showing reduced boilerplate
- Real-world scenarios where each feature applies
- Recommendations for adopting these features in your codebase

---

## Module 4: EF Core Query Optimization

**Learning Objective**: Use ExecuteUpdate to perform bulk database updates without loading entities into memory.

### Exercise 4.1: Understand the Baseline
1. Navigate to `modules/module4-efcore/`
2. Run the .NET 8 version:
   ```powershell
   cd NET8
   dotnet run
   ```
3. Observe the query time and memory usage
4. Run the .NET 10 version:
   ```powershell
   cd ..\NET10
   dotnet run
   ```
5. Compare the performance difference (should be ~90% faster)

### Exercise 4.2: Bulk Price Update
1. Modify `NET10/Program.cs` to add a bulk price update:
   ```csharp
   // Update all products in a category with a percentage increase
   var rowsAffected = await db.Products
       .Where(p => p.Category == "Grocery")
       .ExecuteUpdateAsync(s => s
           .SetProperty(p => p.Price, p => p.Price * 1.10m)  // 10% increase
       );
   Console.WriteLine($"Updated {rowsAffected} products");
   ```
2. Test this with 100, 1000, and 10000 products
3. Compare with the traditional approach (load → modify → save)
4. Measure time and memory for both approaches

### Exercise 4.3: JSON Attribute Updates
1. Update the `Attributes` JSON column using ExecuteUpdate:
   ```csharp
   await db.Products
       .Where(p => p.Category == "Shoes")
       .ExecuteUpdateAsync(s => s
           .SetProperty(p => p.Attributes, p => 
               JsonSerializer.Serialize(
                   JsonSerializer.Deserialize<Dictionary<string, object>>(p.Attributes)!
                       .Append(new KeyValuePair<string, object>("season", "spring"))
               )
           )
       );
   ```
2. Query the updated products to verify the JSON was modified correctly
3. Test with different JSON modifications:
   - Add a new property
   - Remove an existing property
   - Update a nested value

### Exercise 4.4: Conditional Bulk Updates
1. Implement business logic that selectively updates products:
   ```csharp
   // Mark out-of-stock items as discontinued if they've been out for 90+ days
   var ninetyDaysAgo = DateTime.UtcNow.AddDays(-90);
   var updated = await db.Products
       .Where(p => !p.InStock && p.LastRestockDate < ninetyDaysAgo)
       .ExecuteUpdateAsync(s => s
           .SetProperty(p => p.Status, "Discontinued")
           .SetProperty(p => p.Attributes, p =>
               JsonSerializer.Serialize(
                   JsonSerializer.Deserialize<Dictionary<string, object>>(p.Attributes)!
                       .Append(new KeyValuePair<string, object>("discontinuedDate", DateTime.UtcNow))
               )
           )
       );
   ```
2. Test with sample data
3. Verify only matching products were updated

### Exercise 4.5: Performance Measurement Script
1. Create a comprehensive benchmark script:
   ```csharp
   var stopwatch = Stopwatch.StartNew();
   
   // Traditional approach
   var products = await db.Products.Where(p => p.Category == "Grocery").ToListAsync();
   foreach (var p in products)
       p.Price *= 1.10m;
   await db.SaveChangesAsync();
   
   Console.WriteLine($"Traditional: {stopwatch.ElapsedMilliseconds}ms");
   
   // ExecuteUpdate approach
   stopwatch.Restart();
   await db.Products
       .Where(p => p.Category == "Grocery")
       .ExecuteUpdateAsync(s => s.SetProperty(p => p.Price, p => p.Price * 1.10m));
   
   Console.WriteLine($"ExecuteUpdate: {stopwatch.ElapsedMilliseconds}ms");
   ```
2. Run with varying dataset sizes (100, 1K, 10K, 100K rows)
3. Plot performance curves
4. Identify the crossover point where ExecuteUpdate becomes advantageous

**Deliverable**: Create `results/module4-findings.md` with:
- Performance measurements for different dataset sizes
- Memory usage comparison
- Guidelines on when to use ExecuteUpdate vs traditional entity loading
- Example scenarios from retail domain

---

## Module 5: Container Optimization

**Learning Objective**: Reduce container image sizes and improve deployment speed using .NET 10 optimizations.

### Exercise 5.1: Baseline Image Comparison
1. Navigate to `modules/module5-containers/`
2. Build both container images:
   ```powershell
   .\build-images.ps1
   ```
3. Compare image sizes:
   ```powershell
   .\compare-images.ps1
   ```
4. Document the size differences
5. Test container startup times:
   ```powershell
   .\test-containers.ps1
   ```

### Exercise 5.2: Multi-Stage Build Optimization
1. Create an optimized Dockerfile with multi-stage build:
   ```dockerfile
   # Stage 1: Build
   FROM mcr.microsoft.com/dotnet/sdk:10.0 AS build
   WORKDIR /src
   
   # Copy and restore (cached unless .csproj changes)
   COPY ["02-PromotionsAPI.csproj", "./"]
   RUN dotnet restore
   
   # Copy and build
   COPY . .
   RUN dotnet publish -c Release -o /app/publish
   
   # Stage 2: Runtime
   FROM mcr.microsoft.com/dotnet/aspnet:10.0 AS runtime
   WORKDIR /app
   COPY --from=build /app/publish .
   
   EXPOSE 8080
   ENTRYPOINT ["dotnet", "PromotionsAPI.dll"]
   ```
2. Build and tag:
   ```powershell
   docker build -t promotions:optimized -f Dockerfile.optimized .
   ```
3. Compare size with single-stage build

### Exercise 5.3: Alpine Linux Base
1. Create an Alpine-based Dockerfile:
   ```dockerfile
   FROM mcr.microsoft.com/dotnet/sdk:10.0-alpine AS build
   WORKDIR /src
   COPY . .
   RUN dotnet publish -c Release -o /app/publish
   
   FROM mcr.microsoft.com/dotnet/aspnet:10.0-alpine AS runtime
   WORKDIR /app
   COPY --from=build /app/publish .
   
   # Add required dependencies
   RUN apk add --no-cache icu-libs
   
   ENTRYPOINT ["./PromotionsAPI"]
   ```
2. Build the Alpine image
3. Compare size with Debian-based image
4. Test for compatibility issues

### Exercise 5.4: Layer Caching Strategy
1. Modify Dockerfile to optimize layer caching:
   ```dockerfile
   # Bad: Changes invalidate restore cache
   COPY . .
   RUN dotnet restore
   
   # Good: Restore cached unless dependencies change
   COPY ["*.csproj", "./"]
   RUN dotnet restore
   COPY . .
   RUN dotnet build
   ```
2. Build multiple times with code changes
3. Measure build time difference
4. Document best practices for layer ordering

### Exercise 5.5: Deployment Time Simulation
1. Create a script to simulate Kubernetes deployment:
   ```powershell
   # Simulate deploying 50 pods with rolling update
   $imageSize = (docker image inspect promotions:net10 --format='{{.Size}}') / 1MB
   $pullTime = ($imageSize / 50) * 1000  # Estimate: 50 MB/s
   $startTime = 1950  # From measurements
   
   $totalTime = 0
   for ($pod = 1; $pod -le 50; $pod++) {
       $podTime = $pullTime + $startTime
       $totalTime += $podTime
       Write-Host "Pod $pod ready in $($podTime)ms (cumulative: $($totalTime/1000)s)"
   }
   
   Write-Host "Total deployment time: $($totalTime/1000) seconds"
   ```
2. Run for .NET 8 and .NET 10 images
3. Calculate time savings at scale

### Exercise 5.6: Registry Storage Cost Analysis
1. Calculate storage costs for your container registry:
   ```powershell
   # Get image sizes
   $net8Size = docker image inspect promotions:net8 --format='{{.Size}}'
   $net10Size = docker image inspect promotions:net10 --format='{{.Size}}'
   
   # Assume: 10 versions, 50 services
   $net8Total = ($net8Size * 10 * 50) / 1GB
   $net10Total = ($net10Size * 10 * 50) / 1GB
   
   # Azure Container Registry Premium: $0.024/GB/day
   $dailyCostNet8 = $net8Total * 0.024
   $dailyCostNet10 = $net10Total * 0.024
   
   Write-Host "Annual savings: $((($dailyCostNet8 - $dailyCostNet10) * 365))"
   ```
2. Document the cost savings at production scale

**Deliverable**: Create `results/module5-findings.md` with:
- Image size comparisons (Debian vs Alpine, .NET 8 vs .NET 10)
- Startup time measurements
- Multi-stage build optimizations
- Cost analysis for container registry and bandwidth
- Deployment time simulation results

---

## Module 6: Server-Sent Events (SSE)

**Learning Objective**: Implement real-time push notifications using the new Server-Sent Events API in .NET 10.

### Exercise 6.1: Explore the Demo
1. Navigate to `modules/module6-serversentevents/`
2. Run the application:
   ```powershell
   dotnet run
   ```
3. Open browser to http://localhost:5000
4. Test all three SSE endpoints:
   - String stream
   - JSON stream
   - SseItem stream
5. Observe the automatic reconnection behavior (stop/start server)

### Exercise 6.2: Stock Price Ticker
1. Create a stock price streaming endpoint:
   ```csharp
   app.MapGet("/stocks/{symbol}", async (string symbol, CancellationToken ct) =>
   {
       async IAsyncEnumerable<StockPrice> GetPrices(
           [EnumeratorCancellation] CancellationToken cancellationToken)
       {
           var basePrice = 100m;
           while (!cancellationToken.IsCancellationRequested)
           {
               // Simulate price fluctuation
               var change = (decimal)(Random.Shared.NextDouble() * 2 - 1);
               basePrice += change;
               
               yield return new StockPrice
               {
                   Symbol = symbol,
                   Price = Math.Round(basePrice, 2),
                   Timestamp = DateTime.UtcNow,
                   Change = change
               };
               
               await Task.Delay(1000, cancellationToken);
           }
       }
       
       return TypedResults.ServerSentEvents(GetPrices(ct), eventType: "stockPrice");
   });
   ```
2. Create a client HTML page that displays real-time prices
3. Test with multiple stock symbols simultaneously

### Exercise 6.3: Inventory Level Monitoring
1. Create an endpoint that streams inventory changes:
   ```csharp
   app.MapGet("/inventory/{sku}/watch", async (string sku, CancellationToken ct) =>
   {
       async IAsyncEnumerable<InventoryUpdate> WatchInventory(
           [EnumeratorCancellation] CancellationToken cancellationToken)
       {
           var currentLevel = 100;
           while (!cancellationToken.IsCancellationRequested)
           {
               // Simulate sales and restocks
               var change = Random.Shared.Next(-5, 3);
               currentLevel = Math.Max(0, currentLevel + change);
               
               var status = currentLevel switch
               {
                   0 => "OUT_OF_STOCK",
                   < 10 => "LOW_STOCK",
                   _ => "IN_STOCK"
               };
               
               yield return new InventoryUpdate
               {
                   SKU = sku,
                   Level = currentLevel,
                   Status = status,
                   Timestamp = DateTime.UtcNow
               };
               
               await Task.Delay(2000, cancellationToken);
           }
       }
       
       return TypedResults.ServerSentEvents(WatchInventory(ct), eventType: "inventory");
   });
   ```
2. Add client-side alerts when inventory goes below threshold
3. Test reconnection after network interruption

### Exercise 6.4: Order Status Updates
1. Create a long-running order processing simulation with SSE updates:
   ```csharp
   app.MapGet("/orders/{orderId}/status", async (string orderId, CancellationToken ct) =>
   {
       async IAsyncEnumerable<SseItem<OrderStatus>> TrackOrder(
           [EnumeratorCancellation] CancellationToken cancellationToken)
       {
           var id = 1;
           var statuses = new[] 
           { 
               "Received", "Processing", "Picking", "Packing", 
               "Shipped", "Out for Delivery", "Delivered" 
           };
           
           foreach (var status in statuses)
           {
               if (cancellationToken.IsCancellationRequested) break;
               
               yield return new SseItem<OrderStatus>(
                   new OrderStatus { OrderId = orderId, Status = status, UpdatedAt = DateTime.UtcNow },
                   eventType: "orderStatus")
               {
                   Id = (id++).ToString(),
                   ReconnectionInterval = TimeSpan.FromMinutes(5)
               };
               
               await Task.Delay(TimeSpan.FromSeconds(5), cancellationToken);
           }
       }
       
       return TypedResults.ServerSentEvents(TrackOrder(ct));
   });
   ```
2. Build a progress bar UI that updates with each status change
3. Implement last-event-id handling for resumable streams

### Exercise 6.5: Multi-Event Stream
1. Create an endpoint that emits multiple event types:
   ```csharp
   app.MapGet("/dashboard/feed", async (CancellationToken ct) =>
   {
       async IAsyncEnumerable<SseItem<object>> GetFeed(
           [EnumeratorCancellation] CancellationToken cancellationToken)
       {
           while (!cancellationToken.IsCancellationRequested)
           {
               // Randomly emit different event types
               var eventType = Random.Shared.Next(3);
               
               object data = eventType switch
               {
                   0 => new { Type = "Sale", Amount = Random.Shared.Next(10, 100) },
                   1 => new { Type = "Restock", Quantity = Random.Shared.Next(50, 200) },
                   _ => new { Type = "Alert", Message = "Low inventory warning" }
               };
               
               yield return new SseItem<object>(data, eventType: data.GetType().Name)
               {
                   Id = Guid.NewGuid().ToString()
               };
               
               await Task.Delay(3000, cancellationToken);
           }
       }
       
       return TypedResults.ServerSentEvents(GetFeed(ct));
   });
   ```
2. Create a client that filters and displays different event types differently
3. Test with multiple concurrent browser tabs

### Exercise 6.6: Performance Testing
1. Create a load test to measure SSE scalability:
   ```javascript
   // Test with Node.js or similar
   const concurrentConnections = 100;
   const connections = [];
   
   for (let i = 0; i < concurrentConnections; i++) {
       const eventSource = new EventSource('http://localhost:5000/heartrate');
       eventSource.onmessage = (e) => console.log(`Connection ${i}: ${e.data}`);
       connections.push(eventSource);
   }
   
   // Measure memory usage on server
   ```
2. Monitor server memory and CPU usage
3. Determine maximum concurrent connections your system can handle
4. Compare with WebSocket implementation

**Deliverable**: Create `results/module6-findings.md` with:
- Working SSE endpoints for real-time scenarios
- Client-side implementation examples
- Performance measurements (max concurrent connections)
- Comparison with polling approach (request count, latency)
- Recommendations for when to use SSE vs WebSockets

---

## Module 7: Single File Apps

**Learning Objective**: Create and deploy simple applications using .NET 10's file-based app feature.

### Exercise 7.1: Run the Demo
1. Navigate to `modules/module7-singlefileapps/`
2. Run the single file API:
   ```powershell
   dotnet run SingleFileApi.cs
   ```
3. Test the endpoints using `SingleFileApi.http` or curl
4. Examine the file structure - notice no `.csproj` file!

### Exercise 7.2: Create a Weather API
1. Create a new single file app `WeatherApi.cs`:
   ```csharp
   #!/usr/bin/env dotnet
   #:sdk Microsoft.NET.Sdk.Web
   #:property PublishAot=false
   
   var builder = WebApplication.CreateBuilder(args);
   var app = builder.Build();
   
   app.MapGet("/weather/{city}", (string city) =>
   {
       var temp = Random.Shared.Next(50, 90);
       var conditions = new[] { "Sunny", "Cloudy", "Rainy", "Snowy" };
       var condition = conditions[Random.Shared.Next(conditions.Length)];
       
       return new Weather(city, temp, condition, DateTime.UtcNow);
   });
   
   app.Run();
   
   record Weather(string City, int Temperature, string Condition, DateTime Time);
   ```
2. Run it: `dotnet run WeatherApi.cs`
3. Test: `curl http://localhost:5000/weather/Chicago`

### Exercise 7.3: Add Database Support
1. Enhance the weather API with SQLite persistence:
   ```csharp
   #:package Microsoft.EntityFrameworkCore.Sqlite@10.0.0
   
   // Add DbContext
   public class WeatherDb : DbContext
   {
       public DbSet<WeatherReading> Readings => Set<WeatherReading>();
       
       protected override void OnConfiguring(DbContextOptionsBuilder options)
           => options.UseSqlite("Data Source=weather.db");
   }
   
   public class WeatherReading
   {
       public int Id { get; set; }
       public string City { get; set; } = "";
       public int Temperature { get; set; }
       public string Condition { get; set; } = "";
       public DateTime Timestamp { get; set; }
   }
   
   // Update endpoints
   app.MapGet("/weather/{city}", async (string city, WeatherDb db) =>
   {
       var reading = new WeatherReading { /* ... */ };
       db.Readings.Add(reading);
       await db.SaveChangesAsync();
       return reading;
   });
   
   app.MapGet("/weather/{city}/history", async (string city, WeatherDb db) =>
       await db.Readings.Where(r => r.City == city).ToListAsync()
   );
   ```
2. Run and test the persistence

### Exercise 7.4: Command-Line Tool
1. Create a single file CLI tool `ProductSearch.cs`:
   ```csharp
   #!/usr/bin/env dotnet
   #:sdk Microsoft.NET.Sdk
   #:package System.CommandLine@2.0.0-beta4.22272.1
   
   using System.CommandLine;
   
   var rootCommand = new RootCommand("Product search CLI");
   
   var searchCommand = new Command("search", "Search for products");
   var skuArgument = new Argument<string>("sku", "Product SKU to search");
   searchCommand.AddArgument(skuArgument);
   
   searchCommand.SetHandler((string sku) =>
   {
       Console.WriteLine($"Searching for SKU: {sku}");
       // Simulate search
       Console.WriteLine($"Found: Product {sku} - $29.99");
   }, skuArgument);
   
   rootCommand.AddCommand(searchCommand);
   return await rootCommand.InvokeAsync(args);
   ```
2. Run: `dotnet run ProductSearch.cs -- search ABC-123`
3. Publish: `dotnet publish ProductSearch.cs -o ./bin`
4. Run directly: `./bin/ProductSearch search ABC-123`

### Exercise 7.5: Script Automation
1. Create a data migration script `MigrateData.cs`:
   ```csharp
   #!/usr/bin/env dotnet
   #:sdk Microsoft.NET.Sdk
   
   using System.Text.Json;
   
   var sourceFile = args.Length > 0 ? args[0] : "products.json";
   var destFile = args.Length > 1 ? args[1] : "products_migrated.json";
   
   Console.WriteLine($"Migrating {sourceFile} to {destFile}");
   
   var json = File.ReadAllText(sourceFile);
   var products = JsonSerializer.Deserialize<List<Product>>(json);
   
   // Transform data
   foreach (var product in products!)
   {
       product.Price *= 1.10m;  // 10% price increase
       product.UpdatedAt = DateTime.UtcNow;
   }
   
   var options = new JsonSerializerOptions { WriteIndented = true };
   File.WriteAllText(destFile, JsonSerializer.Serialize(products, options));
   Console.WriteLine($"Migrated {products.Count} products");
   
   class Product
   {
       public string SKU { get; set; } = "";
       public decimal Price { get; set; }
       public DateTime UpdatedAt { get; set; }
   }
   ```
2. Create test data and run migration
3. Make it executable on Unix: `chmod +x MigrateData.cs`

### Exercise 7.6: Publishing and Distribution
1. Publish your single file app as a native executable:
   ```powershell
   dotnet publish SingleFileApi.cs -c Release -o ./publish
   ```
2. Test the published executable:
   ```powershell
   .\publish\SingleFileApi.exe
   ```
3. Measure the executable size
4. Compare startup time with `dotnet run` approach
5. Create a simple deployment package (zip file)

**Deliverable**: Create `results/module7-findings.md` with:
- At least 3 single file apps you created
- Use cases where single file apps are ideal
- Comparison of development speed vs traditional projects
- Publishing and distribution strategy
- Limitations you encountered

---

## Final Project: Integrated Retail API

**Objective**: Combine everything you've learned into a complete retail microservice.

### Requirements

Build a single microservice that demonstrates:

1. **Runtime Performance** (Module 1)
   - Support both FX and AOT deployment
   - Measure and document cold-start times

2. **HTTP Performance** (Module 2)
   - Implement output caching for product catalog
   - Add rate limiting for checkout endpoints

3. **Modern C# Syntax** (Module 3)
   - Use extension members for pricing calculations
   - Use field-backed properties for validation
   - Apply at least 2 other C# 14 features

4. **Database Optimization** (Module 4)
   - Use ExecuteUpdate for bulk inventory updates
   - Demonstrate JSON column manipulation

5. **Container Ready** (Module 5)
   - Provide optimized Dockerfile
   - Target image size < 200MB

6. **Real-Time Updates** (Module 6)
   - SSE endpoint for order status tracking
   - SSE endpoint for flash sale countdowns

7. **Developer Experience** (Module 7)
   - Include admin tools as single file apps
   - Data seeding scripts

### Suggested API Endpoints

```
GET    /products              - List products (cached)
GET    /products/{id}         - Get product details
POST   /products/search       - Search products
PUT    /products/bulk/price   - Bulk price update (ExecuteUpdate)

GET    /inventory/{sku}       - Check inventory
PUT    /inventory/bulk        - Bulk inventory adjustment

POST   /orders                - Create order (rate limited)
GET    /orders/{id}           - Get order
GET    /orders/{id}/status    - SSE stream of order status

GET    /promotions            - List promotions (cached)
POST   /promotions/validate   - Validate promo code (rate limited)

GET    /health                - Health check
GET    /metrics               - Prometheus metrics
```

### Evaluation Criteria

- ✅ Functionality: All endpoints work correctly
- ✅ Performance: Demonstrates measurable improvements
- ✅ Code Quality: Uses modern C# features appropriately
- ✅ Documentation: Clear README with architecture decisions
- ✅ Deployment: Docker image builds and runs successfully
- ✅ Testing: Includes load tests and measurements

### Deliverable

Create a folder `final-project/` containing:
- Source code for the API
- Dockerfile
- README.md with:
  - Architecture overview
  - Performance measurements
  - Deployment instructions
  - Load testing results
- PowerShell scripts for:
  - Building all variants
  - Running load tests
  - Measuring performance

---

## Additional Challenges

### Challenge 1: Global Deployment Simulation
Simulate deploying your services to multiple regions (East US, West Europe, Southeast Asia) and measure:
- Total deployment time
- Image transfer bandwidth
- Regional startup latencies
- Cost projections

### Challenge 2: A/B Testing Framework
Build a feature flag system that:
- Allows toggling between .NET 8 and .NET 10 backends
- Collects performance metrics from both
- Provides statistical analysis of improvements
- Uses SSE to stream live A/B test results to admin dashboard

### Challenge 3: Cost Calculator
Create a tool that calculates ROI of migrating to .NET 10:
- Container registry storage costs
- Bandwidth costs for deployments
- Compute savings from better performance
- Developer time saved from modern C# features
- Takes your infrastructure metrics as input

### Challenge 4: CI/CD Pipeline
Implement a complete CI/CD pipeline using GitHub Actions:
- Build and test both .NET 8 and .NET 10 variants
- Run automated performance benchmarks
- Build and push container images
- Generate performance comparison reports
- Auto-deploy to test environment

---

## Resources

### Official Documentation
- [What's New in .NET 10](https://learn.microsoft.com/en-us/dotnet/core/whats-new/dotnet-10/overview)
- [C# 14 Features](https://learn.microsoft.com/en-us/dotnet/csharp/whats-new/csharp-14)
- [ASP.NET Core 10.0](https://learn.microsoft.com/en-us/aspnet/core/release-notes/aspnetcore-10.0)
- [EF Core 10.0](https://learn.microsoft.com/en-us/ef/core/what-is-new/ef-core-10.0/whatsnew)

### Performance Tools
- [BenchmarkDotNet](https://benchmarkdotnet.org/)
- [dotnet-counters](https://learn.microsoft.com/en-us/dotnet/core/diagnostics/dotnet-counters)
- [bombardier](https://github.com/codesenberg/bombardier)
- [k6](https://k6.io/)

### Community
- [.NET Blog](https://devblogs.microsoft.com/dotnet/)
- [ASP.NET Blog](https://devblogs.microsoft.com/aspnet/)
- [C# Language Proposals](https://github.com/dotnet/csharplang/tree/main/proposals)

---

## Completion Checklist

Track your progress through the workshop:

- [ ] Module 0: Environment setup verified
- [ ] Module 1: Runtime performance measured and analyzed
- [ ] Module 2: HTTP caching and rate limiting implemented
- [ ] Module 3: All six C# 14 features explored
- [ ] Module 4: EF Core bulk updates tested
- [ ] Module 5: Container images optimized
- [ ] Module 6: Real-time SSE endpoints created
- [ ] Module 7: Single file apps built and published
- [ ] Final Project: Complete retail API built
- [ ] Additional Challenge attempted

---

## Getting Help

If you get stuck:
1. Review the module's README.md for detailed explanations
2. Check the TESTING.md files for troubleshooting tips
3. Examine the existing code samples in each module
4. Search Microsoft Learn documentation
5. Ask your workshop facilitator or team members

**Remember**: The goal is to learn by doing. Don't worry about perfection—focus on understanding the concepts and seeing the improvements firsthand.

Good luck, and enjoy exploring .NET 10! 🚀
