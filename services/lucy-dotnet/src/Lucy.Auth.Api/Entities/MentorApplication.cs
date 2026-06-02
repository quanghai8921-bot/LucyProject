using Lucy.Shared.Constants;

namespace Lucy.Auth.Api.Entities;

public sealed class MentorApplication
{
    public Guid Id { get; set; } = Guid.NewGuid();
    public Guid UserId { get; set; }
    public string? LanguageId { get; set; }
    public string? ExperienceDescription { get; set; }
    public string? CertificateFileUrl { get; set; }
    public string Status { get; set; } = CommonStatus.Pending;
    public string? RejectReason { get; set; }
    public DateTimeOffset CreatedAt { get; set; } = DateTimeOffset.UtcNow;
    public DateTimeOffset? ReviewedAt { get; set; }
    public Guid? ReviewedByUserId { get; set; }

    // Navigation
    public User User { get; set; } = null!;
}
