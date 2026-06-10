namespace Lucy.Auth.Api.Entities;

public sealed class User
{
    public string UserId { get; set; } = default!;
    public required string FullName { get; set; }
    public required string PhoneNumber { get; set; }
    public required string Email { get; set; }
    public required string Passwords { get; set; }
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
    public int IsStatus { get; set; } = 1;

    public ICollection<UserRole> UserRoles { get; set; } = [];
    public AvatarPersona? AvatarPersona { get; set; }
    public ICollection<MentorApplication> MentorApplications { get; set; } = [];
    public ICollection<CreatorUpgradeRequest> CreatorUpgradeRequests { get; set; } = [];
}
