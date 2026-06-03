using Lucy.Shared.Constants;

namespace Lucy.Auth.Api.Entities;

public sealed class MentorApplication
{
    public string ApplicationId { get; set; } = default!;
    public string UserId { get; set; } = default!;
    public string? LanguageId { get; set; }
    public string? CertificateUrl { get; set; }
    public string Status { get; set; } = CommonStatus.Pending;
    public string? RejectReason { get; set; }
    public DateTime SubmittedAt { get; set; } = DateTime.UtcNow;

    public User User { get; set; } = null!;
    public Language? Language { get; set; }
}
