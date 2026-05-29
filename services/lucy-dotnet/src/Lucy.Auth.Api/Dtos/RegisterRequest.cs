namespace Lucy.Auth.Api.Dtos;

public sealed record RegisterRequest(string Email, string Password, string DisplayName);
