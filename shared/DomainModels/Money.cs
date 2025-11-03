namespace Workshop.DomainModels;

/// <summary>
/// Represents a monetary value with currency.
/// Immutable value object following DDD patterns.
/// </summary>
public readonly record struct Money(decimal Amount, string Currency)
{
    /// <summary>
    /// Creates a USD currency amount.
    /// </summary>
    public static Money Usd(decimal amount) => new(amount, "USD");

    /// <summary>
    /// Adds two money values (must be same currency).
    /// </summary>
    public static Money operator +(Money left, Money right)
    {
        if (left.Currency != right.Currency)
            throw new InvalidOperationException($"Cannot add {left.Currency} and {right.Currency}");
        
        return new Money(left.Amount + right.Amount, left.Currency);
    }

    /// <summary>
    /// Multiplies money by a scalar.
    /// </summary>
    public static Money operator *(Money money, decimal multiplier)
        => new(money.Amount * multiplier, money.Currency);

    /// <summary>
    /// Returns true if amount is greater than zero.
    /// </summary>
    public bool IsPositive => Amount > 0;
}
