using System.ComponentModel.DataAnnotations;

namespace Lucy.Auth.Api.Dtos;

/// <summary>
/// Request đăng ký mentor - multipart/form-data
/// </summary>
public sealed class MentorRegisterRequest
{
    [Required] public string FullName { get; set; } = string.Empty;
    [Required][EmailAddress] public string Email { get; set; } = string.Empty;
    [Required] public string Password { get; set; } = string.Empty;
    public string? PhoneNumber { get; set; }
    public string? BirthDate { get; set; }
    [Required] public string LanguageId { get; set; } = string.Empty;
    public string? ExperienceDescription { get; set; }
    public IFormFile? CertificateFile { get; set; }
}
