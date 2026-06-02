namespace Lucy.Auth.Api.Entities;

public sealed class User
{
    public Guid Id { get; set; } = Guid.NewGuid();
    public required string FullName { get; set; }
    public string? PhoneNumber { get; set; }
    public required string Email { get; set; }
    public required string PasswordHash { get; set; }
    public DateOnly? BirthDate { get; set; }
    public string? AvatarPersonaUrl { get; set; }
    public bool IsActive { get; set; } = true;
    public DateTimeOffset CreatedAt { get; set; } = DateTimeOffset.UtcNow;

    // Navigation
    public ICollection<UserRole> UserRoles { get; set; } = [];
    public ICollection<MentorApplication> MentorApplications { get; set; } = [];
    public ICollection<CreatorUpgradeRequest> CreatorUpgradeRequests { get; set; } = [];
}
