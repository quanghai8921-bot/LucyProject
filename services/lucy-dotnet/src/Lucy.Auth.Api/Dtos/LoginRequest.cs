using System.ComponentModel.DataAnnotations;

namespace Lucy.Auth.Api.Dtos;

public sealed record LoginRequest(
    [Required][EmailAddress] string Email,
    [Required] string Password
);
