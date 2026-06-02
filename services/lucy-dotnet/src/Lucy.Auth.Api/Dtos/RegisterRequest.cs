using System.ComponentModel.DataAnnotations;

namespace Lucy.Auth.Api.Dtos;

public sealed record RegisterRequest(
    [Required] string FullName,
    [Required][EmailAddress] string Email,
    [Required] string Password,
    string? PhoneNumber,
    string? BirthDate,        // "yyyy-MM-dd"
    string? AvatarPersonaUrl
);
