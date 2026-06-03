namespace Lucy.Auth.Api.Entities;

public sealed class Role
{
    public string RoleId { get; set; } = default!;
    public required string RoleName { get; set; }
    public byte IsActive { get; set; } = 1;

    public ICollection<UserRole> UserRoles { get; set; } = [];
}
