namespace Lucy.Auth.Api.Entities;

public sealed class Role
{
    public Guid Id { get; set; } = Guid.NewGuid();
    public required string Code { get; set; }  // LEARNER, MENTOR, CREATOR, ADMIN
    public required string Name { get; set; }  // Tên hiển thị

    // Navigation
    public ICollection<UserRole> UserRoles { get; set; } = [];
}
