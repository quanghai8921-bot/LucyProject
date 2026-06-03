using System.ComponentModel.DataAnnotations;

namespace Lucy.Auth.Api.Dtos;

public sealed class MentorRegisterRequest
{
    [Required][MaxLength(50)] public string FullName { get; set; } = string.Empty;
    [Required][EmailAddress][MaxLength(50)] public string Email { get; set; } = string.Empty;
    [Required] public string Password { get; set; } = string.Empty;
    [Required][MaxLength(10)] public string PhoneNumber { get; set; } = string.Empty;
    [MaxLength(50)] public string? AvatarDisplayName { get; set; }
    [MaxLength(255)] public string? AvatarUrl { get; set; }
    [MaxLength(50)] public string? LanguageId { get; set; }
    public IFormFile? CertificateFile { get; set; }
}
