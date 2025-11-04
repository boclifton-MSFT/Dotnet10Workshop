# Key Code Changes for OpenAPI + Testing Solution

## 1. Program.cs - Conditional OpenAPI Support

### Before
```csharp
using Workshop.DomainModels;
using Workshop.PricingService;

var builder = WebApplication.CreateBuilder(args);
builder.Services.ConfigureHttpJsonOptions(options => { ... });
var app = builder.Build();
app.MapGet("/health", () => Results.Ok(new { status = "Healthy", ... }));
// ... endpoints
```

### After
```csharp
using Workshop.DomainModels;
using Workshop.PricingService;
using System.Text.Json.Serialization;
#if NET10_0_OR_GREATER
using Microsoft.AspNetCore.OpenApi;
#endif

var builder = WebApplication.CreateBuilder(args);

#if NET10_0_OR_GREATER
builder.Services.AddOpenApi();  // ← NEW: Built-in OpenAPI for .NET 10
#endif

builder.Services.ConfigureHttpJsonOptions(options =>
{
    options.SerializerOptions.PropertyNamingPolicy = System.Text.Json.JsonNamingPolicy.CamelCase;
    options.SerializerOptions.TypeInfoResolver = PricingSerializerContext.Default;  // ← FOR AOT
});

var app = builder.Build();

#if NET10_0_OR_GREATER
if (app.Environment.IsDevelopment())
{
    app.MapOpenApi();  // ← NEW: Exposes /openapi/v1.json
}
#endif

app.MapGet("/health", () => Results.Ok(new HealthResponse("Healthy", DateTime.UtcNow)));  // ← CHANGED: Named record
// ... rest unchanged

namespace Workshop.PricingService
{
    // ← NEW: HealthResponse record for AOT serialization
    public record HealthResponse(string Status, DateTime Timestamp);
    
    public record PricingRequest(string Sku, int Quantity, string CustomerId);
    public record PricingResponse(...);
    
    // ← NEW: JsonSerializerContext for source-generated serialization
    [JsonSourceGenerationOptions(PropertyNamingPolicy = JsonKnownNamingPolicy.CamelCase)]
    [JsonSerializable(typeof(HealthResponse))]  // ← NEW
    [JsonSerializable(typeof(PricingRequest))]
    [JsonSerializable(typeof(PricingResponse))]
    internal partial class PricingSerializerContext : JsonSerializerContext { }
}
```

## 2. PricingService.csproj - Conditional OpenAPI Dependency

### Before
```xml
<ItemGroup>
    <PackageReference Include="Scalar.AspNetCore" Version="2.10.0" />
</ItemGroup>
```

### After
```xml
<ItemGroup>
    <!-- Only include OpenAPI for .NET 10 (built-in feature) -->
    <PackageReference Include="Microsoft.AspNetCore.OpenApi" 
        Version="10.0.0-rc.2.25502.107" 
        Condition="'$(TargetFramework)' == 'net10.0'" />
</ItemGroup>
```

**Key benefit**: .NET 8 target doesn't get the dependency, .NET 10 gets it for free!

## 3. New File: test-pricing.ps1

```powershell
# Attendees run this to test the service
param(
    [string]$sku = "WIDGET-001",
    [int]$quantity = 10,
    [string]$customerId = "CUST-123",
    [string]$hostname = "localhost",
    [int]$port = 5000
)

$url = "http://$hostname`:$port/api/pricing/calculate"

Write-Host "Testing PricingService at $url" -ForegroundColor Cyan
# ... [testing logic] ...
```

**Usage**:
```powershell
.\test-pricing.ps1                     # Uses defaults
.\test-pricing.ps1 -sku "GADGET-500"  # Custom values
```

## Why This Design

### ✅ Single Codebase Advantage
- No duplicate code between .NET 8 and .NET 10 versions
- Conditional compilation (`#if NET10_0_OR_GREATER`) handles differences
- Easy to maintain one set of business logic

### ✅ Demonstrates Real Upgrade Benefits
- .NET 10 has OpenAPI built-in (vs NuGet for .NET 8)
- Same API works for both (with conditionals)
- Workshop attendees see actual framework improvements

### ✅ Perfect for Workshop Environment
- PowerShell test script = no external tools needed
- Works from command line = no terminal blocking
- Formatted output = easy to understand results

### ✅ Native AOT Fully Supported
- Source-generated JSON serialization (no reflection)
- All types explicitly registered
- Builds for both Framework-Dependent and AOT

## Testing All 4 Variants

```powershell
# .NET 8 Framework-Dependent
cd artifacts/pub8-fx
.\PricingService.exe
# In another terminal: .\test-pricing.ps1

# .NET 8 Native AOT
cd artifacts/pub8-aot
.\PricingService.exe
# In another terminal: .\test-pricing.ps1

# .NET 10 Framework-Dependent (with OpenAPI!)
cd artifacts/pub10-fx
.\PricingService.exe
# In browser: http://localhost:5000/openapi/v1.json
# Or in terminal: .\test-pricing.ps1

# .NET 10 Native AOT (with OpenAPI!)
cd artifacts/pub10-aot
.\PricingService.exe
# In another terminal: .\test-pricing.ps1
```

## Talking Points for Attendees

1. **"Notice how .NET 10 includes OpenAPI support built-in?"**
   - Look at `Program.cs`: `#if NET10_0_OR_GREATER` only enables it for .NET 10
   - This is a real upgrade benefit - less dependencies to manage

2. **"Same API, different capabilities"**
   - Both .NET 8 and .NET 10 share 99% of the code
   - Conditional compilation handles framework-specific features
   - Perfect example of multi-targeting best practices

3. **"Easy testing without external tools"**
   - Show the PowerShell script: `test-pricing.ps1`
   - Run it against both versions - same results!
   - This is how real apps enable customer testing

4. **"Native AOT works for both"**
   - All 4 variants build successfully
   - JSON serialization uses source generation (no reflection)
   - Important for cloud scenarios (smaller, faster)

---

## Lines of Code Changed

```
Program.cs:               ~50 lines added (conditionals, context, HealthResponse)
PricingService.csproj:     2 lines changed (conditional package reference)
test-pricing.ps1:        NEW (47 lines) - test helper for attendees
TESTING.md:              NEW (80 lines) - testing guide
IMPLEMENTATION-STATUS.md: NEW (190 lines) - detailed implementation notes
```

**Total changes**: Minimal, focused, no breaking changes!
