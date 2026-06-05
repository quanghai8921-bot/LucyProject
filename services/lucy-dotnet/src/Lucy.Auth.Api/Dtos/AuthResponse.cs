namespace Lucy.Auth.Api.Dtos;

public sealed record AuthResponse(Guid UserId, string Email, string DisplayName, string AccessToken);
