namespace Workshop.DomainModels;

/// <summary>
/// Marketing promotion with eligibility rules and discounts.
/// </summary>
public class Promotion
{
    public string Id { get; init; } = string.Empty;
    public string Name { get; init; } = string.Empty;
    public Discount Discount { get; init; } = new();
    public DateTime StartDate { get; init; }
    public DateTime EndDate { get; init; }

    /// <summary>
    /// SKUs eligible for this promotion (empty = all SKUs).
    /// </summary>
    public List<string> EligibleSkus { get; init; } = new();

    /// <summary>
    /// Categories eligible for this promotion (empty = all categories).
    /// </summary>
    public List<string> EligibleCategories { get; init; } = new();

    /// <summary>
    /// Returns true if promotion is currently active.
    /// </summary>
    public bool IsActive(DateTime now)
        => now >= StartDate && now <= EndDate;

    /// <summary>
    /// Returns true if the given product is eligible for this promotion.
    /// </summary>
    public bool IsEligible(Product product)
    {
        // If no restrictions, all products are eligible
        if (EligibleSkus.Count == 0 && EligibleCategories.Count == 0)
            return true;

        // Check SKU eligibility
        if (EligibleSkus.Count > 0 && EligibleSkus.Contains(product.Sku.Code))
            return true;

        // Check category eligibility
        if (EligibleCategories.Count > 0 && EligibleCategories.Contains(product.Category))
            return true;

        return false;
    }
}
