using System.Security.Claims;
using Lucy.Auth.Api.Dtos;
using Lucy.Auth.Api.Services;
using Lucy.Shared.Dtos;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace Lucy.Auth.Api.Controllers;

[ApiController]
[Route("api/auth")]
[Produces("application/json")]
public sealed class AuthController(AuthService authService, IWebHostEnvironment environment) : ControllerBase
{
    private static readonly HashSet<string> AllowedAvatarExtensions = new(StringComparer.OrdinalIgnoreCase)
    {
        ".jpg", ".jpeg", ".png", ".webp"
    };

    private const long MaxAvatarBytes = 5 * 1024 * 1024;

    [HttpPost("register")]
    [AllowAnonymous]
    [ProducesResponseType(typeof(ApiResponse<AuthTokenResponse>), 201)]
    [ProducesResponseType(typeof(ApiResponse<object>), 400)]
    public async Task<IActionResult> Register([FromBody] RegisterRequest request)
    {
        var (response, error) = await authService.RegisterAsync(request);
        if (error is not null)
            return BadRequest(ApiResponse<object>.Fail(error));

        return StatusCode(201, ApiResponse<AuthTokenResponse>.Ok(response!, "Dang ky thanh cong"));
    }

    [HttpPost("register-mentor")]
    [AllowAnonymous]
    [Consumes("multipart/form-data")]
    [ProducesResponseType(typeof(ApiResponse<ApplicationDto>), 201)]
    [ProducesResponseType(typeof(ApiResponse<object>), 400)]
    public async Task<IActionResult> RegisterMentor([FromForm] MentorRegisterRequest request)
    {
        string? certificateUrl = null;
        if (request.CertificateFile is { Length: > 0 })
        {
            var fileName = $"{Guid.NewGuid()}_{request.CertificateFile.FileName}";
            var uploadPath = Path.Combine(environment.ContentRootPath, "uploads", "certificates");
            Directory.CreateDirectory(uploadPath);
            var filePath = Path.Combine(uploadPath, fileName);
            await using var stream = System.IO.File.Create(filePath);
            await request.CertificateFile.CopyToAsync(stream);
            certificateUrl = $"/uploads/certificates/{fileName}";
        }

        var (application, error) = await authService.RegisterMentorAsync(request, certificateUrl);
        if (error is not null)
            return BadRequest(ApiResponse<object>.Fail(error));

        return StatusCode(201, ApiResponse<ApplicationDto>.Ok(application!, "Ho so mentor da duoc nop, cho admin xet duyet"));
    }

    [HttpPost("login")]
    [AllowAnonymous]
    [ProducesResponseType(typeof(ApiResponse<AuthTokenResponse>), 200)]
    [ProducesResponseType(typeof(ApiResponse<object>), 401)]
    public async Task<IActionResult> Login([FromBody] LoginRequest request)
    {
        var (response, error) = await authService.LoginAsync(request);
        if (error is not null)
            return Unauthorized(ApiResponse<object>.Fail(error));

        return Ok(ApiResponse<AuthTokenResponse>.Ok(response!, "Dang nhap thanh cong"));
    }

    [HttpPost("logout")]
    [Authorize]
    [ProducesResponseType(typeof(ApiResponse<object>), 200)]
    public IActionResult Logout()
    {
        return Ok(ApiResponse<object>.Ok(new { }, "Dang xuat thanh cong"));
    }

    [HttpGet("me")]
    [Authorize]
    [ProducesResponseType(typeof(ApiResponse<UserProfileData>), 200)]
    [ProducesResponseType(401)]
    public async Task<IActionResult> Me()
    {
        var userId = GetCurrentUserId();
        if (userId is null) return Unauthorized();

        var profile = await authService.GetMeAsync(userId);
        if (profile is null) return NotFound(ApiResponse<object>.Fail("Nguoi dung khong ton tai."));

        return Ok(ApiResponse<UserProfileData>.Ok(profile));
    }

    [HttpGet("my-roles")]
    [Authorize]
    [ProducesResponseType(typeof(ApiResponse<List<RoleDto>>), 200)]
    public async Task<IActionResult> MyRoles()
    {
        var userId = GetCurrentUserId();
        if (userId is null) return Unauthorized();

        var roles = await authService.GetMyRolesAsync(userId);
        return Ok(ApiResponse<List<RoleDto>>.Ok(roles));
    }

    [HttpPut("avatar")]
    [Authorize]
    [Consumes("multipart/form-data")]
    [ProducesResponseType(typeof(ApiResponse<UserProfileData>), 200)]
    [ProducesResponseType(typeof(ApiResponse<object>), 400)]
    public async Task<IActionResult> UpdateAvatar([FromForm] AvatarUpdateRequest request)
    {
        var userId = GetCurrentUserId();
        if (userId is null) return Unauthorized();

        var avatarUrl = request.AvatarUrl;
        if (request.AvatarFile is { Length: > 0 })
        {
            var (savedUrl, uploadError) = await SaveAvatarAsync(userId, request.AvatarFile);
            if (uploadError is not null)
                return BadRequest(ApiResponse<object>.Fail(uploadError));

            avatarUrl = savedUrl;
        }

        var (profile, error) = await authService.UpdateAvatarAsync(
            userId, request.DisplayName, avatarUrl, request.IsAnonymous);

        if (error is not null)
            return BadRequest(ApiResponse<object>.Fail(error));

        return Ok(ApiResponse<UserProfileData>.Ok(profile!, "Cap nhat avatar thanh cong"));
    }

    [HttpPost("creator-upgrade-requests")]
    [Authorize(Roles = "MENTOR")]
    [ProducesResponseType(typeof(ApiResponse<ApplicationDto>), 201)]
    [ProducesResponseType(typeof(ApiResponse<object>), 400)]
    public async Task<IActionResult> CreateCreatorUpgradeRequest([FromBody] CreatorUpgradeRequestCreateDto request)
    {
        var userId = GetCurrentUserId();
        if (userId is null) return Unauthorized();

        var (application, error) = await authService.CreateCreatorUpgradeRequestAsync(userId, request);
        if (error is not null)
            return BadRequest(ApiResponse<object>.Fail(error));

        return StatusCode(201, ApiResponse<ApplicationDto>.Ok(application!, "Yeu cau nang cap Creator da duoc gui"));
    }

    private string? GetCurrentUserId()
    {
        return User.FindFirstValue(ClaimTypes.NameIdentifier)
            ?? User.FindFirstValue("sub");
    }

    private async Task<(string? Url, string? Error)> SaveAvatarAsync(string userId, IFormFile file)
    {
        if (file.Length > MaxAvatarBytes)
            return (null, "Anh avatar khong duoc vuot qua 5MB.");

        var extension = Path.GetExtension(file.FileName);
        if (string.IsNullOrWhiteSpace(extension) || !AllowedAvatarExtensions.Contains(extension))
            return (null, "Chi chap nhan anh .jpg, .jpeg, .png, .webp.");

        if (!file.ContentType.StartsWith("image/", StringComparison.OrdinalIgnoreCase) &&
            !string.Equals(file.ContentType, "application/octet-stream", StringComparison.OrdinalIgnoreCase))
        {
            return (null, "File upload phai la anh.");
        }

        var uploadsRoot = Path.Combine(environment.ContentRootPath, "uploads", "avatars");
        Directory.CreateDirectory(uploadsRoot);

        var fileName = $"{userId}_{Guid.NewGuid():N}{extension.ToLowerInvariant()}";
        var filePath = Path.Combine(uploadsRoot, fileName);

        await using var stream = System.IO.File.Create(filePath);
        await file.CopyToAsync(stream);

        return ($"/uploads/avatars/{fileName}", null);
    }
}
