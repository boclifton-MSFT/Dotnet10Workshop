// DEMO
var item1 = InventoryItemBefore.Create("SKU-001", 50);
item1.Display();

var item2 = InventoryItemAfter.Create("SKU-001", 50);
item2.Display();

Console.WriteLine("\n✓ Both work the same!");
Console.WriteLine("After is easier to extend with source generators and layering.");

// BEFORE: Single constructor
class InventoryItemBefore
{
    public string SKU { get; set; }
    public int Quantity { get; set; }

    private InventoryItemBefore(string sku, int qty)
    {
        SKU = sku;
        Quantity = qty;
    }

    public static InventoryItemBefore Create(string sku, int qty)
        => new(sku, qty);

    public void Display() => Console.WriteLine($"Item (Before): {SKU}, Qty: {Quantity}");
}

// AFTER: Layered construction with partial constructors
partial class InventoryItemAfter
{
    public string SKU { get; set; }
    public int Quantity { get; set; }

    public partial void Initialize();
    public partial void Validate();

    private InventoryItemAfter(string sku, int qty)
    {
        SKU = sku;
        Quantity = qty;
        Initialize();
        Validate();
    }

    public static InventoryItemAfter Create(string sku, int qty)
        => new(sku, qty);

    public void Display() => Console.WriteLine($"Item (After):  {SKU}, Qty: {Quantity}");
}

// This could be in a different file (auto-generated)
partial class InventoryItemAfter
{
    public partial void Initialize()
    {
        // Initialization logic here
    }

    public partial void Validate()
    {
        if (Quantity < 0)
            throw new ArgumentException("Quantity cannot be negative");
    }
}
