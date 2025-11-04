// DEMO
Console.WriteLine("=== nameof on Generics Demo ===\n");

// BEFORE: Magic strings (breaks on refactoring)
Console.WriteLine("BEFORE (Magic strings - breaks on rename):");
var repo1 = new MagicStringRepository<string>();
repo1.PrintCacheName();

// AFTER: nameof on generics (compile-time safe)
Console.WriteLine("\nAFTER (nameof on generics - compile-time safe):");
var repo2 = new SafeNameofRepository<string>();
repo2.PrintCacheName();

Console.WriteLine("\n✓ Same output, but AFTER breaks at compile time if you rename Product!");
Console.WriteLine("Before would only break at runtime when cache miss happens.");

class MagicStringRepository<T>
{
    // BEFORE: Magic strings - runtime error if type renamed
    public void PrintCacheName()
    {
        var typeName = typeof(T).Name;
        var cacheKey = $"repo_{typeName}";
        Console.WriteLine($"  Cache key: {cacheKey}");
        Console.WriteLine("  ⚠️ If Product renamed to ProductV2, this breaks at runtime!");
    }
}

class SafeNameofRepository<T>
{
    // AFTER: nameof on generics - compile-time safe
    public void PrintCacheName()
    {
        var cacheKey = $"repo_{nameof(T)}";
        Console.WriteLine($"  Cache key: {cacheKey}");
        Console.WriteLine("  ✓ If renamed, compiler catches it immediately!");
    }
}
