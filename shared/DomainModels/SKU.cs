namespace Workshop.DomainModels;

/// <summary>
/// Stock Keeping Unit - unique product identifier.
/// Immutable value object.
/// </summary>
public readonly record struct SKU(string Code)
{
    /// <summary>
    /// Validates SKU format (alphanumeric, 3-20 characters).
    /// </summary>
    public bool IsValid()
    {
        if (string.IsNullOrWhiteSpace(Code))
            return false;

        if (Code.Length is < 3 or > 20)
            return false;

        return Code.All(c => char.IsLetterOrDigit(c) || c == '-');
    }

    public override string ToString() => Code;
}
