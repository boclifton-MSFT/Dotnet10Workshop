namespace Workshop.DomainModels;

/// <summary>
/// Shopping cart containing line items.
/// </summary>
public class Cart
{
    public string Id { get; init; } = Guid.NewGuid().ToString();
    public string CustomerId { get; init; } = string.Empty;
    public List<CartLineItem> Items { get; init; } = new();
    public DateTime CreatedAt { get; init; } = DateTime.UtcNow;
    public DateTime UpdatedAt { get; set; } = DateTime.UtcNow;

    /// <summary>
    /// Adds or updates a line item.
    /// </summary>
    public void AddItem(SKU sku, Quantity quantity, Money unitPrice)
    {
        var existing = Items.FirstOrDefault(i => i.Sku.Code == sku.Code);
        if (existing != null)
        {
            existing.Quantity = existing.Quantity + quantity;
        }
        else
        {
            Items.Add(new CartLineItem
            {
                Sku = sku,
                Quantity = quantity,
                UnitPrice = unitPrice
            });
        }
        UpdatedAt = DateTime.UtcNow;
    }

    /// <summary>
    /// Calculates the total before discounts.
    /// </summary>
    public Money CalculateSubtotal()
    {
        return Items.Aggregate(
            Money.Usd(0),
            (sum, item) => sum + (item.UnitPrice * item.Quantity.Value)
        );
    }
}

/// <summary>
/// Individual line item in a cart.
/// </summary>
public class CartLineItem
{
    public SKU Sku { get; init; }
    public Quantity Quantity { get; set; }
    public Money UnitPrice { get; init; }
}
