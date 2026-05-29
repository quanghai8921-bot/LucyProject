using Lucy.Shared.Constants;

namespace Lucy.Auth.Api.Entities;

public sealed class MentorApplication
{
    public Guid Id { get; set; } = Guid.NewGuid();
    public Guid UserId { get; set; }
    public string Status { get; set; } = CommonStatus.Pending;
    public DateTimeOffset CreatedAt { get; set; } = DateTimeOffset.UtcNow;
}
