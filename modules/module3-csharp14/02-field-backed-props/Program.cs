// DEMO
var money1 = new MoneyBefore { Amount = 100, Currency = "USD" };
money1.Display();

var money2 = new MoneyAfter { Amount = 100, Currency = "USD" };
money2.Display();

Console.WriteLine("\n✓ Both approaches work!");
Console.WriteLine("AFTER has validation - try setting negative amount:");
var money3 = new MoneyAfter();
money3.Amount = -50;  // This will warn!
money3.Display();

// BEFORE: Basic properties, no validation
class MoneyBefore
{
    public decimal Amount { get; set; }
    public string Currency { get; set; } = "";
    
    public void Display() => Console.WriteLine($"Money (Before): {Amount} {Currency}");
}

// AFTER: Field-backed properties with C# 14 'field' keyword
// This demonstrates the new C# 14 feature available in .NET 10
class MoneyAfter
{
#if NET10_0_OR_GREATER
    // C# 14: Use 'field' keyword - compiler generates the backing field automatically!
    // No need to manually declare private _amount or _currency fields
    public decimal Amount
    {
        get => field;  // 'field' refers to compiler-generated backing field
        set
        {
            // Add validation directly in the property setter
            if (value < 0)
                Console.WriteLine("⚠️ Warning: Money amount is negative!");
            field = value;  // Assign to compiler-generated backing field
        }
    }

    public string Currency
    {
        get => field;
        set => field = value ?? "";  // Use 'field' keyword with null-coalescing
    }
#else
    // C# 13 (NET 8): Traditional approach - must manually declare backing fields
    // This is the old way before C# 14's 'field' keyword
    private decimal _amount = 0;
    private string _currency = "";

    public decimal Amount
    {
        get => _amount;
        set
        {
            if (value < 0)
                Console.WriteLine("⚠️ Warning: Money amount is negative!");
            _amount = value;
        }
    }

    public string Currency
    {
        get => _currency;
        set => _currency = value ?? "";
    }
#endif

    public void Display() => Console.WriteLine($"Money (After):  {Amount} {Currency}");
}
