using Lucy.Shared.Constants;

namespace Lucy.Auth.Api.Entities;

public sealed class CreatorUpgradeRequest
{
    public string UpgradeRequestId { get; set; } = default!;
    public string UserId { get; set; } = default!;
    public int TotalTeachingMinutes { get; set; }
    public decimal? AverageRating { get; set; }
    public int LearnerCount { get; set; }
    public string Status { get; set; } = CommonStatus.Pending;
    public string? RejectReason { get; set; }
    public DateTime SubmittedAt { get; set; } = DateTime.UtcNow;

    public User User { get; set; } = null!;
}
