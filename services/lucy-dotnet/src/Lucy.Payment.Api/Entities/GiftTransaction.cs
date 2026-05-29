namespace Lucy.Payment.Api.Entities;

public sealed class GiftTransaction
{
    public Guid Id { get; set; } = Guid.NewGuid();
    public Guid GiftId { get; set; }
    public Guid FromUserId { get; set; }
    public Guid ToUserId { get; set; }
    public DateTimeOffset CreatedAt { get; set; } = DateTimeOffset.UtcNow;
}
