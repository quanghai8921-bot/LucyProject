namespace Lucy.Payment.Api.Entities;

public sealed class ContentPurchase
{
    public Guid Id { get; set; } = Guid.NewGuid();
    public Guid BuyerUserId { get; set; }
    public Guid ContentId { get; set; }
    public decimal Amount { get; set; }
    public DateTimeOffset CreatedAt { get; set; } = DateTimeOffset.UtcNow;
}
