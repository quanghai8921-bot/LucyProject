namespace Lucy.Shared.Dtos;

public sealed record CurrentUserDto(Guid UserId, string Email, IReadOnlyCollection<string> Roles);
