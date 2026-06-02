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
public sealed class AuthController(AuthService authService) : ControllerBase
{
    // POST /api/auth/register
    [HttpPost("register")]
    [AllowAnonymous]
    [ProducesResponseType(typeof(ApiResponse<AuthTokenResponse>), 201)]
    [ProducesResponseType(typeof(ApiResponse<object>), 400)]
    public async Task<IActionResult> Register([FromBody] RegisterRequest request)
    {
        var (response, error) = await authService.RegisterAsync(request);
        if (error is not null)
            return BadRequest(ApiResponse<object>.Fail(error));

        return StatusCode(201, ApiResponse<AuthTokenResponse>.Ok(response!, "Đăng ký thành công"));
    }

    // POST /api/auth/register-mentor
    [HttpPost("register-mentor")]
    [AllowAnonymous]
    [Consumes("multipart/form-data")]
    [ProducesResponseType(typeof(ApiResponse<ApplicationDto>), 201)]
    [ProducesResponseType(typeof(ApiResponse<object>), 400)]
    public async Task<IActionResult> RegisterMentor([FromForm] MentorRegisterRequest request)
    {
        // Xử lý upload file (lưu local hoặc trả URL mock)
        string? certificateFileUrl = null;
        if (request.CertificateFile is { Length: > 0 })
        {
            var fileName = $"{Guid.NewGuid()}_{request.CertificateFile.FileName}";
            var uploadPath = Path.Combine("uploads", "certificates");
            Directory.CreateDirectory(uploadPath);
            var filePath = Path.Combine(uploadPath, fileName);
            await using var stream = System.IO.File.Create(filePath);
            await request.CertificateFile.CopyToAsync(stream);
            certificateFileUrl = $"/uploads/certificates/{fileName}";
        }

        var (application, error) = await authService.RegisterMentorAsync(request, certificateFileUrl);
        if (error is not null)
            return BadRequest(ApiResponse<object>.Fail(error));

        return StatusCode(201, ApiResponse<ApplicationDto>.Ok(application!, "Hồ sơ mentor đã được nộp, chờ admin xét duyệt"));
    }

    // POST /api/auth/login
    [HttpPost("login")]
    [AllowAnonymous]
    [ProducesResponseType(typeof(ApiResponse<AuthTokenResponse>), 200)]
    [ProducesResponseType(typeof(ApiResponse<object>), 401)]
    public async Task<IActionResult> Login([FromBody] LoginRequest request)
    {
        var (response, error) = await authService.LoginAsync(request);
        if (error is not null)
            return Unauthorized(ApiResponse<object>.Fail(error));

        return Ok(ApiResponse<AuthTokenResponse>.Ok(response!, "Đăng nhập thành công"));
    }

    // POST /api/auth/logout
    [HttpPost("logout")]
    [Authorize]
    [ProducesResponseType(typeof(ApiResponse<object>), 200)]
    public IActionResult Logout()
    {
        // JWT là stateless – client tự xóa token
        return Ok(ApiResponse<object>.Ok(new { }, "Đăng xuất thành công"));
    }

    // GET /api/auth/me
    [HttpGet("me")]
    [Authorize]
    [ProducesResponseType(typeof(ApiResponse<UserProfileData>), 200)]
    [ProducesResponseType(401)]
    public async Task<IActionResult> Me()
    {
        var userId = GetCurrentUserId();
        if (userId is null) return Unauthorized();

        var profile = await authService.GetMeAsync(userId.Value);
        if (profile is null) return NotFound(ApiResponse<object>.Fail("Người dùng không tồn tại."));

        return Ok(ApiResponse<UserProfileData>.Ok(profile));
    }

    // GET /api/auth/my-roles
    [HttpGet("my-roles")]
    [Authorize]
    [ProducesResponseType(typeof(ApiResponse<List<RoleDto>>), 200)]
    public async Task<IActionResult> MyRoles()
    {
        var userId = GetCurrentUserId();
        if (userId is null) return Unauthorized();

        var roles = await authService.GetMyRolesAsync(userId.Value);
        return Ok(ApiResponse<List<RoleDto>>.Ok(roles));
    }

    // POST /api/auth/creator-upgrade-requests
    [HttpPost("creator-upgrade-requests")]
    [Authorize(Roles = "MENTOR")]
    [ProducesResponseType(typeof(ApiResponse<ApplicationDto>), 201)]
    [ProducesResponseType(typeof(ApiResponse<object>), 400)]
    public async Task<IActionResult> CreateCreatorUpgradeRequest([FromBody] CreatorUpgradeRequestCreateDto request)
    {
        var userId = GetCurrentUserId();
        if (userId is null) return Unauthorized();

        var (application, error) = await authService.CreateCreatorUpgradeRequestAsync(userId.Value, request);
        if (error is not null)
            return BadRequest(ApiResponse<object>.Fail(error));

        return StatusCode(201, ApiResponse<ApplicationDto>.Ok(application!, "Yêu cầu nâng cấp Creator đã được gửi"));
    }

    // ── Helper ───────────────────────────────────────────────────────────────
    private Guid? GetCurrentUserId()
    {
        var sub = User.FindFirstValue(ClaimTypes.NameIdentifier)
               ?? User.FindFirstValue("sub");
        return Guid.TryParse(sub, out var id) ? id : null;
    }
}
