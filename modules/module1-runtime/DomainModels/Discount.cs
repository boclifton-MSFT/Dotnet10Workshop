namespace Workshop.DomainModels;

/// <summary>
/// Represents a discount with percentage and optional limits.
/// </summary>
public class Discount
{
    public decimal Percentage { get; init; }
    public Money? MaxDiscountAmount { get; init; }

    /// <summary>
    /// Calculates the discount amount for a given price.
    /// </summary>
    public Money CalculateDiscount(Money price)
    {
        if (Percentage <= 0)
            return Money.Usd(0);

        var discountAmount = price * (Percentage / 100m);

        if (MaxDiscountAmount.HasValue && discountAmount.Amount > MaxDiscountAmount.Value.Amount)
            return MaxDiscountAmount.Value;

        return discountAmount;
    }

    /// <summary>
    /// Applies the discount to a price.
    /// </summary>
    public Money ApplyTo(Money price)
    {
        var discount = CalculateDiscount(price);
        return new Money(price.Amount - discount.Amount, price.Currency);
    }
}
