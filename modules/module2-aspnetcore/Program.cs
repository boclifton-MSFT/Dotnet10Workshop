using Workshop.PromotionsAPI;
#if NET10_0_OR_GREATER
using System.Threading.RateLimiting;
#endif

var builder = WebApplication.CreateBuilder(args);

// Configure JSON serialization
builder.Services.ConfigureHttpJsonOptions(options =>
{
    options.SerializerOptions.PropertyNamingPolicy = System.Text.Json.JsonNamingPolicy.CamelCase;
});

#if NET10_0_OR_GREATER
// .NET 10 features
builder.Services.AddOutputCache(options =>
{
    options.AddBasePolicy(builder => builder.Expire(TimeSpan.FromSeconds(10)));
});

builder.Services.AddRateLimiter(_ =>
{
    _.FixedWindowLimiter = new FixedWindowRateLimiterOptions
    {
        PermitLimit = 100,
        Window = TimeSpan.FromSeconds(10),
        QueueProcessingOrder = QueueProcessingOrder.OldestFirst,
        QueueLimit = 2
    };
});
#endif

var app = builder.Build();

#if NET10_0_OR_GREATER
app.UseOutputCache();
app.UseRateLimiter();
#endif

// Health check endpoint
app.MapGet("/health", () => Results.Ok(new { status = "Healthy", timestamp = DateTime.UtcNow }))
    .WithName("Health");

// Get all promotions
#if NET10_0_OR_GREATER
app.MapGet("/promotions", () => SampleData.GetPromotions())
    .WithName("GetPromotions")
    .CacheOutput(policyName: "default");
#else
app.MapGet("/promotions", () => SampleData.GetPromotions())
    .WithName("GetPromotions");
#endif

// Get specific promotion
app.MapGet("/promotions/{id}", (string id) =>
{
    var promotion = SampleData.GetPromotion(id);
    return promotion is not null
        ? Results.Ok(promotion)
        : Results.NotFound(new { error = "Promotion not found", id });
})
    .WithName("GetPromotion");

// Validate promotion
#if NET10_0_OR_GREATER
app.MapPost("/promotions/validate", (PromoValidationRequest request) =>
{
    var isValid = SampleData.IsPromotionActive(request.PromotionId);
    var promotion = SampleData.GetPromotion(request.PromotionId);

    if (!isValid || promotion is null)
    {
        return Results.Ok(new PromoValidationResponse(
            PromotionId: request.PromotionId,
            IsValid: false,
            Reason: "Promotion not found or expired"
        ));
    }

    return Results.Ok(new PromoValidationResponse(
        PromotionId: request.PromotionId,
        IsValid: true,
        DiscountPercentage: promotion.DiscountPercentage
    ));
})
    .WithName("ValidatePromotion")
    .RequireRateLimiting("default");
#else
app.MapPost("/promotions/validate", (PromoValidationRequest request) =>
{
    var isValid = SampleData.IsPromotionActive(request.PromotionId);
    var promotion = SampleData.GetPromotion(request.PromotionId);

    if (!isValid || promotion is null)
    {
        return Results.Ok(new PromoValidationResponse(
            PromotionId: request.PromotionId,
            IsValid: false,
            Reason: "Promotion not found or expired"
        ));
    }

    return Results.Ok(new PromoValidationResponse(
        PromotionId: request.PromotionId,
        IsValid: true,
        DiscountPercentage: promotion.DiscountPercentage
    ));
})
    .WithName("ValidatePromotion");
#endif

app.Run();
