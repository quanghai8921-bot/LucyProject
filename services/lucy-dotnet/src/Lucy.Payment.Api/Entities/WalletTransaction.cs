namespace Lucy.Payment.Api.Entities;

public sealed class WalletTransaction
{
    public Guid Id { get; set; } = Guid.NewGuid();
    public Guid WalletId { get; set; }
    public decimal Amount { get; set; }
    public required string Type { get; set; }
    public DateTimeOffset CreatedAt { get; set; } = DateTimeOffset.UtcNow;
}
