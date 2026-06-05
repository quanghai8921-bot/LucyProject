using Lucy.Shared.Constants;

namespace Lucy.Payment.Api.Entities;

public sealed class WithdrawRequest
{
    public Guid Id { get; set; } = Guid.NewGuid();
    public Guid UserId { get; set; }
    public decimal Amount { get; set; }
    public string Status { get; set; } = CommonStatus.Pending;
    public DateTimeOffset CreatedAt { get; set; } = DateTimeOffset.UtcNow;
}
