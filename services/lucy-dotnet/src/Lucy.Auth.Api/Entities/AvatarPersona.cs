namespace Lucy.Auth.Api.Entities;

public sealed class AvatarPersona
{
    public string UserId { get; set; } = default!;
    public required string DisplayName { get; set; }
    public string? AvatarUrl { get; set; }
    public int IsAnonymous { get; set; } = 1;
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

    public User User { get; set; } = null!;
}
