namespace Workshop.PromotionsAPI;

/// <summary>
/// Sample promotion data for testing.
/// </summary>
public static class SampleData
{
    private static readonly List<Promotion> _promotions = new()
    {
        new Promotion(
            Id: "SAVE20",
            Name: "20% Off Groceries",
            Description: "Save 20% on all grocery items",
            DiscountPercentage: 20m,
            ValidFrom: DateTime.UtcNow.AddDays(-7),
            ValidTo: DateTime.UtcNow.AddDays(7)
        ),
        new Promotion(
            Id: "FREESHIP",
            Name: "Free Shipping",
            Description: "Free shipping on orders over $50",
            DiscountPercentage: 0m,
            ValidFrom: DateTime.UtcNow.AddDays(-30),
            ValidTo: DateTime.UtcNow.AddDays(30)
        ),
        new Promotion(
            Id: "BOGO50",
            Name: "Buy One Get One 50% Off",
            Description: "Second item 50% off on select items",
            DiscountPercentage: 50m,
            ValidFrom: DateTime.UtcNow.AddDays(-14),
            ValidTo: DateTime.UtcNow.AddDays(14)
        )
    };

    /// <summary>
    /// Gets all active promotions.
    /// </summary>
    public static IEnumerable<Promotion> GetPromotions()
    {
        var now = DateTime.UtcNow;
        return _promotions
            .Where(p => p.ValidFrom <= now && now <= p.ValidTo)
            .ToList();
    }

    /// <summary>
    /// Gets a specific promotion by ID.
    /// </summary>
    public static Promotion? GetPromotion(string id)
    {
        return _promotions.FirstOrDefault(p => p.Id == id);
    }

    /// <summary>
    /// Validates if a promotion is currently active.
    /// </summary>
    public static bool IsPromotionActive(string id)
    {
        var now = DateTime.UtcNow;
        return _promotions.Any(p => p.Id == id && p.ValidFrom <= now && now <= p.ValidTo);
    }
}

/// <summary>
/// Promotion model.
/// </summary>
public record Promotion(
    string Id,
    string Name,
    string Description,
    decimal DiscountPercentage,
    DateTime ValidFrom,
    DateTime ValidTo
);

/// <summary>
/// Promotion validation request.
/// </summary>
public record PromoValidationRequest(
    string PromotionId,
    string? CustomerId = null
);

/// <summary>
/// Promotion validation response.
/// </summary>
public record PromoValidationResponse(
    string PromotionId,
    bool IsValid,
    string? Reason = null,
    decimal? DiscountPercentage = null
);
