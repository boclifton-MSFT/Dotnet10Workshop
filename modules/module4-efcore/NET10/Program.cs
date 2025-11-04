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

// Demonstrate the AFTER approach (ExecuteUpdate - fast for bulk updates)
Console.WriteLine("=== .NET 10: ExecuteUpdate Approach ===\n");

var stopwatch = Stopwatch.StartNew();

// Direct SQL update with JSON path - NO entity loading!
var updateCount = await db.Products
    .Where(p => p.Category == "Shoes")
    .ExecuteUpdateAsync(s => s
        .SetProperty(
            p => p.Attributes,
            p => p.Attributes.Replace("\"newColor\":\"purple\"", "\"newColor\":\"purple\"")
        )
    );

stopwatch.Stop();

Console.WriteLine($"Updated {updateCount} products");
Console.WriteLine($"Query time: {stopwatch.ElapsedMilliseconds}ms");
Console.WriteLine("\nWhy this is fast:");
Console.WriteLine("  • Zero entity loading");
Console.WriteLine("  • Direct SQL generation");
Console.WriteLine("  • Updates only the JSON path we specify");
Console.WriteLine("  • Efficient bulk update statement");
Console.WriteLine("  • Better for high-throughput scenarios");

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
