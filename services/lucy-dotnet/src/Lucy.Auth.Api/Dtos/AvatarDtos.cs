using System.ComponentModel.DataAnnotations;

namespace Lucy.Auth.Api.Dtos;

public sealed class AvatarUpdateRequest
{
    [MaxLength(50)] public string? DisplayName { get; set; }
    [MaxLength(255)] public string? AvatarUrl { get; set; }
    public int? IsAnonymous { get; set; }
    public IFormFile? AvatarFile { get; set; }
}
