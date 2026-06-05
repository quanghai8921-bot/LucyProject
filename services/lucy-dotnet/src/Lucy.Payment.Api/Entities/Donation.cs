namespace Lucy.Payment.Api.Entities;

public sealed class Donation
{
    public Guid Id { get; set; } = Guid.NewGuid();
    public Guid FromUserId { get; set; }
    public Guid ToUserId { get; set; }
    public decimal Amount { get; set; }
    public DateTimeOffset CreatedAt { get; set; } = DateTimeOffset.UtcNow;
}
