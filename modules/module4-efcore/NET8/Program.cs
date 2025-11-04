using Microsoft.EntityFrameworkCore;
using System.Text.Json;
using System.Diagnostics;

var db = new ProductDb("catalog.db");
await db.Database.EnsureCreatedAsync();

// Seed sample data if needed
if (!await db.Products.AnyAsync())
{
    Console.WriteLine("Seeding sample data...");
    for (int i = 0; i < 100; i++)
    {
        var attrs = new Dictionary<string, object>
        {
            ["colors"] = new[] { "red", "blue", "green" },
            ["sizes"] = new[] { "S", "M", "L", "XL" },
            ["inStock"] = true,
            ["costPerUnit"] = 5.50m
        };

        db.Products.Add(new Product
        {
            SKU = $"PROD-{i:D5}",
            Name = $"Product {i}",
            Price = 29.99m,
            Category = (i % 3 == 0) ? "Shoes" : (i % 3 == 1) ? "Shirts" : "Hats",
            Attributes = JsonSerializer.Serialize(attrs)
        });
    }
    await db.SaveChangesAsync();
}

// Demonstrate the BEFORE approach (Full Entity Load - slow for bulk updates)
Console.WriteLine("=== .NET 8: Full Entity Load Approach ===\n");

var stopwatch = Stopwatch.StartNew();

// Load all products that need updating
var productsToUpdate = await db.Products
    .Where(p => p.Category == "Shoes")
    .ToListAsync();

Console.WriteLine($"Loaded {productsToUpdate.Count} products");

// Modify each one in memory
foreach (var product in productsToUpdate)
{
    var attrs = JsonSerializer.Deserialize<Dictionary<string, object>>(product.Attributes) ?? new();
    attrs["newColor"] = "purple";  // Add new color
    product.Attributes = JsonSerializer.Serialize(attrs);
}

// Save all changes
await db.SaveChangesAsync();

stopwatch.Stop();

Console.WriteLine($"\nQuery time: {stopwatch.ElapsedMilliseconds}ms");
Console.WriteLine($"Entities loaded: {productsToUpdate.Count}");
Console.WriteLine($"Entities saved: {productsToUpdate.Count}");
Console.WriteLine("\nWhy this is slow:");
Console.WriteLine("  • Loads ALL properties for each product");
Console.WriteLine("  • Modifies in memory");
Console.WriteLine("  • Saves ALL properties, even ones unchanged");
Console.WriteLine("  • Generates large UPDATE statements");

await db.DisposeAsync();

public class Product
{
    public int Id { get; set; }
    public string SKU { get; set; } = "";
    public string Name { get; set; } = "";
    public decimal Price { get; set; }
    public string Category { get; set; } = "";
    public string Attributes { get; set; } = "{}";  // JSON column as string
}

public class ProductDb : DbContext
{
    private readonly string _connectionString;

    public ProductDb(string connectionString)
    {
        _connectionString = connectionString;
    }

    public DbSet<Product> Products { get; set; }

    protected override void OnConfiguring(DbContextOptionsBuilder options)
    {
        options.UseSqlite($"Data Source={_connectionString}");
    }
}
