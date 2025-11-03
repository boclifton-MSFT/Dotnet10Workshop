namespace Workshop.DomainModels;

/// <summary>
/// Completed order with finalized pricing and promotions.
/// </summary>
public class Order
{
    public string Id { get; init; } = Guid.NewGuid().ToString();
    public string CustomerId { get; init; } = string.Empty;
    public List<OrderLineItem> Items { get; init; } = new();
    public Money Subtotal { get; init; }
    public Money TotalDiscount { get; init; }
    public Money Total { get; init; }
    public DateTime OrderDate { get; init; } = DateTime.UtcNow;
    public OrderStatus Status { get; set; } = OrderStatus.Pending;

    /// <summary>
    /// Applied promotion IDs for tracking.
    /// </summary>
    public List<string> AppliedPromotions { get; init; } = new();
}

/// <summary>
/// Individual line item in an order.
/// </summary>
public class OrderLineItem
{
    public SKU Sku { get; init; }
    public string ProductName { get; init; } = string.Empty;
    public Quantity Quantity { get; init; }
    public Money UnitPrice { get; init; }
    public Money Discount { get; init; }
    public Money LineTotal { get; init; }
}

/// <summary>
/// Order processing status.
/// </summary>
public enum OrderStatus
{
    Pending,
    Confirmed,
    Shipped,
    Delivered,
    Cancelled
}
