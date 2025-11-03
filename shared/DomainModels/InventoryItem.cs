namespace Workshop.DomainModels;

/// <summary>
/// Inventory tracking for a product SKU.
/// </summary>
public class InventoryItem
{
    public SKU Sku { get; init; }
    public Quantity AvailableQuantity { get; set; }
    public Quantity ReservedQuantity { get; set; }
    public DateTime LastUpdated { get; set; } = DateTime.UtcNow;

    /// <summary>
    /// Total quantity on hand.
    /// </summary>
    public Quantity TotalQuantity => AvailableQuantity + ReservedQuantity;

    /// <summary>
    /// Returns true if sufficient quantity is available.
    /// </summary>
    public bool IsAvailable(Quantity requested)
        => AvailableQuantity.Value >= requested.Value;

    /// <summary>
    /// Reserves quantity for an order.
    /// </summary>
    public bool Reserve(Quantity quantity)
    {
        if (!IsAvailable(quantity))
            return false;

        AvailableQuantity -= quantity;
        ReservedQuantity += quantity;
        LastUpdated = DateTime.UtcNow;
        return true;
    }

    /// <summary>
    /// Releases reserved quantity back to available.
    /// </summary>
    public void ReleaseReservation(Quantity quantity)
    {
        ReservedQuantity -= quantity;
        AvailableQuantity += quantity;
        LastUpdated = DateTime.UtcNow;
    }
}
