namespace Workshop.DomainModels;

/// <summary>
/// Product catalog entry with pricing and metadata.
/// </summary>
public class Product
{
    public SKU Sku { get; init; }
    public string Name { get; init; } = string.Empty;
    public string Category { get; init; } = string.Empty;
    public Money BasePrice { get; init; }
    public bool IsActive { get; init; } = true;

    /// <summary>
    /// Tags for flexible categorization (e.g., "seasonal", "clearance").
    /// </summary>
    public List<string> Tags { get; init; } = new();
}
