using Workshop.DomainModels;
using Workshop.PricingService;
using System.Text.Json.Serialization;
#if NET10_0_OR_GREATER
using Microsoft.AspNetCore.OpenApi;
#endif

var builder = WebApplication.CreateBuilder(args);

#if NET10_0_OR_GREATER
// Add OpenAPI support (built-in to .NET 10)
builder.Services.AddOpenApi();
#endif

// Configure JSON serialization for minimal APIs
builder.Services.ConfigureHttpJsonOptions(options =>
{
    options.SerializerOptions.PropertyNamingPolicy = System.Text.Json.JsonNamingPolicy.CamelCase;
    // Register source-generated serialization context for Native AOT support
    options.SerializerOptions.TypeInfoResolver = PricingSerializerContext.Default;
});

var app = builder.Build();

#if NET10_0_OR_GREATER
// Map OpenAPI endpoint (only in Development, only in .NET 10+)
if (app.Environment.IsDevelopment())
{
    app.MapOpenApi();
}
#endif

// Health check endpoint
app.MapGet("/health", () => Results.Ok(new HealthResponse("Healthy", DateTime.UtcNow)));

// Simple root endpoint
app.MapGet("/", () => "PricingService is running.");

// Pricing calculation endpoint
app.MapPost("/api/pricing/calculate", (PricingRequest request) =>
{
    var calculator = new PricingCalculator();
    var response = calculator.Calculate(request);
    return Results.Ok(response);
});

app.Run();

namespace Workshop.PricingService
{
    /// <summary>
    /// Health check response.
    /// </summary>
    public record HealthResponse(string Status, DateTime Timestamp);

    /// <summary>
    /// Request model for pricing calculation.
    /// </summary>
    public record PricingRequest(string Sku, int Quantity, string CustomerId);

    /// <summary>
    /// Response model with itemized pricing.
    /// </summary>
    public record PricingResponse(
        string Sku,
        decimal BasePrice,
        int Quantity,
        decimal Discount,
        decimal Total
    );

    /// <summary>
    /// Calculates pricing with promotional discounts.
    /// </summary>
    public class PricingCalculator
    {
        // Mock product catalog (in-memory for simplicity)
        private static readonly Dictionary<string, Product> _catalog = new()
        {
            ["WIDGET-001"] = new Product
            {
                Sku = new SKU("WIDGET-001"),
                Name = "Standard Widget",
                Category = "Widgets",
                BasePrice = Money.Usd(29.99m),
                Tags = new List<string> { "popular" }
            },
            ["GADGET-001"] = new Product
            {
                Sku = new SKU("GADGET-001"),
                Name = "Premium Gadget",
                Category = "Gadgets",
                BasePrice = Money.Usd(99.99m),
                Tags = new List<string> { "premium" }
            },
            ["TOOL-001"] = new Product
            {
                Sku = new SKU("TOOL-001"),
                Name = "Basic Tool",
                Category = "Tools",
                BasePrice = Money.Usd(15.49m),
                Tags = new List<string> { "clearance" }
            }
        };

        // Mock promotions (in-memory for simplicity)
        private static readonly List<Promotion> _promotions = new()
        {
            new Promotion
            {
                Id = "PROMO-WIDGET-10",
                Name = "10% off Widgets",
                Discount = new Discount { Percentage = 10m },
                StartDate = DateTime.UtcNow.AddDays(-7),
                EndDate = DateTime.UtcNow.AddDays(7),
                EligibleCategories = new List<string> { "Widgets" }
            },
            new Promotion
            {
                Id = "PROMO-CLEARANCE-25",
                Name = "25% off Clearance",
                Discount = new Discount { Percentage = 25m },
                StartDate = DateTime.UtcNow.AddDays(-30),
                EndDate = DateTime.UtcNow.AddDays(30),
                EligibleSkus = new List<string> { "TOOL-001" }
            }
        };

        /// <summary>
        /// Calculates pricing with discounts applied.
        /// </summary>
        public PricingResponse Calculate(PricingRequest request)
        {
            // Lookup product
            if (!_catalog.TryGetValue(request.Sku, out var product))
            {
                throw new ArgumentException($"Product not found: {request.Sku}");
            }

            // Calculate base price
            var quantity = new Quantity(request.Quantity);
            var basePrice = product.BasePrice * quantity.Value;

            // Find applicable promotions
            var now = DateTime.UtcNow;
            var applicablePromo = _promotions
                .FirstOrDefault(p => p.IsActive(now) && p.IsEligible(product));

            // Apply discount
            var discountAmount = Money.Usd(0);
            if (applicablePromo != null)
            {
                discountAmount = applicablePromo.Discount.CalculateDiscount(basePrice);
            }

            var total = basePrice.Amount - discountAmount.Amount;

            return new PricingResponse(
                Sku: request.Sku,
                BasePrice: product.BasePrice.Amount,
                Quantity: request.Quantity,
                Discount: discountAmount.Amount,
                Total: total
            );
        }
    }

    /// <summary>
    /// JSON serialization context for Native AOT support.
    /// Source generation ensures JSON serialization works in Native AOT builds.
    /// </summary>
    [JsonSourceGenerationOptions(PropertyNamingPolicy = JsonKnownNamingPolicy.CamelCase)]
    [JsonSerializable(typeof(HealthResponse))]
    [JsonSerializable(typeof(PricingRequest))]
    [JsonSerializable(typeof(PricingResponse))]
    internal partial class PricingSerializerContext : JsonSerializerContext
    {
    }
}
