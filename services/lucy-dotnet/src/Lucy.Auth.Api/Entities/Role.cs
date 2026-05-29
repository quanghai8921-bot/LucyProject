namespace Lucy.Auth.Api.Entities;

public sealed class Role
{
    public Guid Id { get; set; } = Guid.NewGuid();
    public required string Name { get; set; }
}
