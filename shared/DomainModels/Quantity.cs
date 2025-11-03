namespace Workshop.DomainModels;

/// <summary>
/// Represents a product quantity.
/// Immutable value object with validation.
/// </summary>
public readonly record struct Quantity(int Value)
{
    /// <summary>
    /// Returns true if quantity is greater than zero.
    /// </summary>
    public bool IsPositive => Value > 0;

    /// <summary>
    /// Returns true if quantity is zero.
    /// </summary>
    public bool IsZero => Value == 0;

    /// <summary>
    /// Adds two quantities.
    /// </summary>
    public static Quantity operator +(Quantity left, Quantity right)
        => new(left.Value + right.Value);

    /// <summary>
    /// Subtracts two quantities (result can be negative).
    /// </summary>
    public static Quantity operator -(Quantity left, Quantity right)
        => new(left.Value - right.Value);

    public override string ToString() => Value.ToString();
}
