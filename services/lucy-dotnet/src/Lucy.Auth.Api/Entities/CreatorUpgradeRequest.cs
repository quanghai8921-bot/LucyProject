using Lucy.Shared.Constants;

namespace Lucy.Auth.Api.Entities;

public sealed class CreatorUpgradeRequest
{
    public Guid Id { get; set; } = Guid.NewGuid();
    public Guid UserId { get; set; }
    public string? Reason { get; set; }
    public string? EvidenceUrl { get; set; }
    public string Status { get; set; } = CommonStatus.Pending;
    public string? RejectReason { get; set; }
    public DateTimeOffset CreatedAt { get; set; } = DateTimeOffset.UtcNow;
    public DateTimeOffset? ReviewedAt { get; set; }
    public Guid? ReviewedByUserId { get; set; }

    // Navigation
    public User User { get; set; } = null!;
}
