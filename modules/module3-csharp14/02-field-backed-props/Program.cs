// DEMO
var money1 = new MoneyBefore { Amount = 100, Currency = "USD" };
money1.Display();

var money2 = new MoneyAfter();
money2.SetAmount(100);
money2.SetCurrency("USD");
money2.Display();

Console.WriteLine("\n✓ Both approaches work!");
Console.WriteLine("AFTER has validation - try setting negative amount:");
var money3 = new MoneyAfter();
money3.SetAmount(-50);  // This will warn!
money3.Display();

// BEFORE: Basic properties, no validation
class MoneyBefore
{
    public decimal Amount { get; set; }
    public string Currency { get; set; } = "";
    
    public void Display() => Console.WriteLine($"Money (Before): {Amount} {Currency}");
}

// AFTER: Field-backed properties with validation
class MoneyAfter
{
    private decimal _amount = 0;
    private string _currency = "";

    public decimal Amount
    {
        get => _amount;
        init => _amount = value;
    }

    public string Currency
    {
        get => _currency;
        init => _currency = value;
    }

    public void SetAmount(decimal value)
    {
        if (value < 0)
            Console.WriteLine("⚠️ Warning: Money amount is negative!");
        _amount = value;
    }

    public void SetCurrency(string value) => _currency = value;

    public void Display() => Console.WriteLine($"Money (After):  {_amount} {_currency}");
}
