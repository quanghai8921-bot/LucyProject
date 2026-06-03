namespace Lucy.Auth.Api.Entities;

public sealed class UserRole
{
    public string UserId { get; set; } = default!;
    public string RoleId { get; set; } = default!;
    public DateTime AssignedDate { get; set; } = DateTime.UtcNow;

    public User User { get; set; } = null!;
    public Role Role { get; set; } = null!;
}
