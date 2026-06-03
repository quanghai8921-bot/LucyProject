using System.ComponentModel.DataAnnotations;

namespace Lucy.Auth.Api.Dtos;

public sealed record RegisterRequest(
    [Required][MaxLength(50)] string FullName,
    [Required][EmailAddress][MaxLength(50)] string Email,
    [Required] string Password,
    [Required][MaxLength(10)] string PhoneNumber,
    [MaxLength(50)] string? AvatarDisplayName,
    [MaxLength(255)] string? AvatarUrl
);
