namespace Lucy.Payment.Api.Entities;

public sealed class LiveAccessTicket
{
    public Guid Id { get; set; } = Guid.NewGuid();
    public Guid UserId { get; set; }
    public Guid LiveSessionId { get; set; }
    public DateTimeOffset ExpiresAt { get; set; }
}
