# Data Model: LTS to LTS Performance Lab Workshop

**Feature**: 001-lts-performance-lab  
**Created**: 2025-11-03  
**Purpose**: Define domain entities used across workshop modules

## Overview

This workshop uses realistic retail domain objects from Meijer-scale operations. Entities are implemented in `shared/DomainModels/` and used across modules to demonstrate .NET 8 vs .NET 10 comparisons with production-relevant scenarios.

---

## Core Value Objects

### Money

**Purpose**: Represents monetary amounts with currency and validation

**Fields**:
- `Amount` (decimal): The monetary amount with 2 decimal precision
- `Currency` (string): ISO 4217 currency code (e.g., "USD", "EUR")

**Validation Rules**:
- Amount must be >= 0 for prices, can be negative for adjustments
- Currency must be valid ISO 4217 code
- Amount rounded to 2 decimal places

**State Transitions**: Immutable value object, operations return new instances

**Relationships**: Used by Product (base price), Discount (fixed amount), Order (total, tax)

**C# 14 Features**: Field-Backed Properties add validation with logging (Module 3, Example 2)

**Operations**:
- Arithmetic: Add, Subtract, Multiply, Divide
- Comparison: Equals, GreaterThan, LessThan
- Compound Operators (C# 14): `Money += Discount` (Module 3, Example 4)

---

### SKU (Stock Keeping Unit)

**Purpose**: Unique product identifier with parsing and validation

**Fields**:
- `Value` (string): SKU identifier (format: "DEPT-CAT-ITEM", e.g., "GRO-DAI-001")
- `Department` (string): Parsed department code (3 letters)
- `Category` (string): Parsed category code (3 letters)
- `ItemNumber` (string): Parsed item number (3 digits)

**Validation Rules**:
- Format: `[A-Z]{3}-[A-Z]{3}-[0-9]{3}`
- Must parse into three components
- Case-insensitive input, normalized to uppercase

**State Transitions**: Immutable value object

**Relationships**: Used by Product (primary key), InventoryItem (reference)

**C# 14 Features**: Expanded Span<T> conversions reduce allocations in parsing hot-path (Module 3, Example 5)

**Operations**:
- Parse from string with validation
- ToString for display
- Equality comparison

---

### Quantity

**Purpose**: Represents item counts with unit of measure

**Fields**:
- `Count` (int): Number of items
- `Unit` (string): Unit of measure ("EA" for each, "CS" for case, "LB" for pounds)

**Validation Rules**:
- Count must be > 0
- Unit must be valid UOM code

**State Transitions**: Immutable value object

**Relationships**: Used by Cart (line item quantity), InventoryItem (on-hand quantity)

**C# 14 Features**: User-Defined Compound Operators enable `Quantity *= Multiplier` (Module 3, Example 4)

**Operations**:
- Arithmetic: Multiply by scalar, Add quantities
- Conversion between units (case to each: 1 CS = 12 EA)

---

## Product Entities

### Product

**Purpose**: Core retail product with pricing, attributes, and inventory

**Fields**:
- `SKU` (SKU): Unique product identifier
- `Name` (string): Display name (max 200 chars)
- `Description` (string): Long description (max 2000 chars)
- `BasePrice` (Money): Regular price before discounts
- `Category` (string): Product category ("Grocery", "Dairy", "Produce", etc.)
- `Attributes` (JSON): Dynamic metadata (color options, size charts, seasonal flags)
- `InventoryQuantity` (Quantity): On-hand quantity
- `IsActive` (bool): Available for sale
- `LastUpdated` (DateTime): UTC timestamp

**Validation Rules**:
- SKU must be unique
- Name required, non-empty
- BasePrice must be > 0
- Category must be valid enum or reference data

**State Transitions**:
- Created → Active → Inactive (deactivation)
- Inventory updated via separate InventoryItem entity

**Relationships**:
- Has many InventoryItems (by SKU)
- Referenced by Cart line items
- Referenced by Order line items
- Has many Promotions (via applicability rules)

**Module Usage**:
- Module 3: Extension Members add tax calculation (Example 1)
- Module 4: JSON attributes column with EF Core 10 ExecuteUpdate

**JSON Attributes Example**:
```json
{
  "colorOptions": ["Red", "Blue", "Green"],
  "sizeChart": {"S": "Small", "M": "Medium", "L": "Large"},
  "seasonal": true,
  "tags": ["organic", "local", "sale"]
}
```

---

### InventoryItem

**Purpose**: Warehouse inventory record with location and dynamic attributes

**Fields**:
- `Id` (Guid): Unique inventory record ID
- `SKU` (SKU): Product reference
- `Location` (string): Warehouse location code ("DC01", "STORE-123")
- `Quantity` (Quantity): On-hand quantity
- `ReservedQuantity` (Quantity): Allocated to orders, not available
- `AvailableQuantity` (Quantity): Computed: Quantity - ReservedQuantity
- `Attributes` (JSON): Location-specific metadata (bin, aisle, temperature zone)
- `LastCounted` (DateTime): Last physical inventory count
- `LastUpdated` (DateTime): UTC timestamp

**Validation Rules**:
- SKU must reference valid Product
- Quantity >= ReservedQuantity
- Location must be valid warehouse code

**State Transitions**:
- Quantity updated via inventory transactions (receive, ship, adjust)
- ReservedQuantity updated when orders placed/fulfilled

**Relationships**:
- References Product by SKU
- Used by fulfillment system to allocate stock

**Module Usage**:
- Module 3: Partial Constructors for clean layering with source generator (Example 3)

---

## Discount & Promotion Entities

### Discount

**Purpose**: Price reduction applied to products or orders

**Fields**:
- `Type` (enum): Percentage or FixedAmount
- `Value` (decimal): Discount amount or percentage (0-100)
- `AppliesTo` (enum): Product, Category, Order
- `MaxDiscount` (Money?): Optional cap for percentage discounts

**Validation Rules**:
- Percentage discounts: Value between 0-100
- FixedAmount discounts: Value > 0
- MaxDiscount only applies to percentage discounts

**State Transitions**: Immutable value object created per promotion rule

**Relationships**:
- Applied by Promotion to calculate final price
- Used in Cart and Order calculations

**C# 14 Features**: Compound Operators enable `Money += Discount` (Module 3, Example 4)

**Operations**:
- Calculate discounted price: `originalPrice - (originalPrice * percentage)` or `originalPrice - fixedAmount`
- Apply max discount cap

---

### Promotion

**Purpose**: Marketing campaign with discount rules and applicability

**Fields**:
- `Id` (Guid): Unique promotion ID
- `Code` (string): Promo code entered by customer ("SAVE20", "FREESHIP")
- `Name` (string): Internal name
- `Description` (string): Customer-facing description
- `Discount` (Discount): Discount to apply
- `ValidFrom` (DateTime): Start date/time (UTC)
- `ValidTo` (DateTime): End date/time (UTC)
- `MinimumPurchase` (Money?): Optional minimum order amount
- `ApplicableCategories` (List<string>): Categories eligible for promotion
- `ExcludedSKUs` (List<SKU>): SKUs explicitly excluded
- `IsActive` (bool): Can be applied
- `UsageLimit` (int?): Optional max uses per customer

**Validation Rules**:
- Code must be unique and non-empty
- ValidTo must be after ValidFrom
- MinimumPurchase must be > 0 if specified
- At least one applicability rule (categories or all products)

**State Transitions**:
- Created → Active (when ValidFrom reached)
- Active → Expired (when ValidTo passed)
- Active → Deactivated (manually disabled)

**Relationships**:
- References Products via category or SKU exclusions
- Applied to Cart during checkout

**Module Usage**:
- Module 2: Promotions API with three endpoints (list, details, validate)

**API Operations**:
- `GET /promotions` - List active promotions
- `GET /promotions/{id}` - Get promotion details
- `POST /promotions/validate` - Validate promo code against cart

---

## Shopping & Order Entities

### Cart

**Purpose**: Customer shopping cart with line items

**Fields**:
- `Id` (Guid): Unique cart ID
- `CustomerId` (Guid?): Optional customer reference (null for guest)
- `LineItems` (List<CartLineItem>): Products added to cart
- `Subtotal` (Money): Sum of line item totals before discounts
- `AppliedPromotions` (List<Promotion>): Promotions applied
- `DiscountTotal` (Money): Total discount amount
- `Tax` (Money): Calculated tax
- `Total` (Money): Final amount (Subtotal - DiscountTotal + Tax)
- `CreatedAt` (DateTime): UTC timestamp
- `UpdatedAt` (DateTime): Last modification UTC timestamp

**Validation Rules**:
- LineItems must have at least one item for checkout
- Subtotal must equal sum of line item totals
- Total must equal Subtotal - DiscountTotal + Tax

**State Transitions**:
- Created → Updated (items added/removed) → Checked Out (converted to Order)
- Abandoned carts: no updates for 30 days → archived

**Relationships**:
- Contains CartLineItems (nested)
- References Promotions applied
- Converted to Order on checkout

**Module Usage**:
- Module 3: Extension Members add tax calculation to Cart (Example 1)

**Nested Entity: CartLineItem**:
- `SKU` (SKU): Product reference
- `Quantity` (Quantity): Number of items
- `UnitPrice` (Money): Price at time of add
- `LineTotal` (Money): Quantity * UnitPrice

---

### Order

**Purpose**: Completed purchase with payment and fulfillment status

**Fields**:
- `Id` (Guid): Unique order ID
- `OrderNumber` (string): Customer-facing order number ("ORD-2025-123456")
- `CustomerId` (Guid): Customer reference
- `LineItems` (List<OrderLineItem>): Products purchased
- `Subtotal` (Money): Sum of line item totals before discounts
- `DiscountTotal` (Money): Total discount applied
- `Tax` (Money): Tax calculated at checkout
- `ShippingFee` (Money): Delivery fee
- `Total` (Money): Final charged amount
- `PaymentStatus` (enum): Pending, Paid, Refunded
- `FulfillmentStatus` (enum): Pending, Shipped, Delivered, Cancelled
- `OrderedAt` (DateTime): UTC timestamp
- `PaidAt` (DateTime?): Payment completion timestamp
- `ShippedAt` (DateTime?): Shipment timestamp
- `DeliveredAt` (DateTime?): Delivery timestamp

**Validation Rules**:
- OrderNumber must be unique
- Total must equal Subtotal - DiscountTotal + Tax + ShippingFee
- LineItems must have at least one item
- PaidAt must be after OrderedAt
- ShippedAt must be after PaidAt

**State Transitions**:
- Created (Pending payment) → Paid → Shipped → Delivered
- Can be Cancelled before shipped
- Can be Refunded after delivery

**Relationships**:
- Contains OrderLineItems (nested)
- References Customer
- Triggers InventoryItem reservation and allocation

**Module Usage**:
- Module 3: Extension Members add tax calculation to Order (Example 1)

**Nested Entity: OrderLineItem**:
- `SKU` (SKU): Product reference
- `ProductName` (string): Snapshot of product name at order time
- `Quantity` (Quantity): Number purchased
- `UnitPrice` (Money): Price at order time (locked)
- `LineTotal` (Money): Quantity * UnitPrice
- `DiscountApplied` (Money): Line-level discount

---

## Service Entities

### PricingService

**Purpose**: Microservice API for calculating discounted prices

**Fields**: N/A (stateless service)

**API Operations**:
- `POST /calculate-price`
  - Input: `originalPrice` (decimal), `discountPercentage` (decimal)
  - Output: `finalPrice` (decimal), `discountAmount` (decimal)

**Validation Rules**:
- originalPrice must be > 0
- discountPercentage must be between 0-100

**Module Usage**:
- Module 1: Simple pricing API published in 4 variants (8-FX, 8-AOT, 10-FX, 10-AOT)
- Module 5: Same pricing API containerized with Docker

---

### PromotionsAPI

**Purpose**: API managing promotional campaigns

**Fields**: N/A (stateless service with database backend)

**API Operations**:
- `GET /promotions` - List active promotions (cached in .NET 10)
- `GET /promotions/{id}` - Get promotion details by ID
- `POST /promotions/validate` - Validate promo code against cart context

**Validation Rules**:
- Promo code must be valid and active
- Minimum purchase requirements must be met
- Category restrictions must be satisfied

**Module Usage**:
- Module 2: ASP.NET Core performance comparison with output caching and rate limiting

**Rate Limiting**: 100 requests per 10 seconds per endpoint (Module 2, .NET 10 version)

---

## Entity Relationships Diagram

```
Product (SKU, BasePrice, Attributes)
  ├─→ InventoryItem (SKU, Quantity, Location)
  └─→ Used by: CartLineItem, OrderLineItem

Promotion (Code, Discount, Applicability)
  └─→ Applied to: Cart, Order

Cart (LineItems, AppliedPromotions, Total)
  ├─→ CartLineItem (SKU, Quantity, UnitPrice)
  └─→ Converted to: Order

Order (LineItems, Total, PaymentStatus)
  └─→ OrderLineItem (SKU, Quantity, UnitPrice)

Value Objects:
  - Money (Amount, Currency)
  - SKU (Department, Category, ItemNumber)
  - Quantity (Count, Unit)
  - Discount (Type, Value)
```

---

## Implementation Notes

### Shared Domain Models

All entities implemented in `shared/DomainModels/` folder with:
- Immutable value objects (Money, SKU, Quantity)
- Entity classes with validation
- C# 14 features demonstrated in Module 3 examples

### Database Schema (Module 4)

Products table with JSON attributes column:
```sql
CREATE TABLE Products (
    SKU VARCHAR(11) PRIMARY KEY,
    Name VARCHAR(200) NOT NULL,
    BasePrice DECIMAL(10,2) NOT NULL,
    Category VARCHAR(50),
    Attributes JSONB,  -- PostgreSQL or JSON for SQL Server
    InventoryQuantity INT,
    IsActive BIT,
    LastUpdated DATETIME2
);
```

### C# 14 Feature Demonstrations

| Feature | Entity | Module 3 Example |
|---------|--------|------------------|
| Extension Members | Product, Order | Tax calculation (Example 1) |
| Field-Backed Properties | Money | Validation with logging (Example 2) |
| Partial Constructors | InventoryItem | Clean layering (Example 3) |
| Compound Operators | Money, Quantity | `+=`, `*=` operations (Example 4) |
| Span<T> Conversions | SKU | Parsing optimization (Example 5) |
| nameof Generics | Generic Repository | Safer refactoring (Example 6) |

---

## Next Steps

1. Create API contracts for PricingService and PromotionsAPI in `contracts/` folder
2. Create quickstart.md with setup instructions and prerequisites
3. Update agent context with selected technologies
