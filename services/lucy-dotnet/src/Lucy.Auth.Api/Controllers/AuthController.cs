using Lucy.Auth.Api.Dtos;
using Lucy.Auth.Api.Services;
using Microsoft.AspNetCore.Mvc;

namespace Lucy.Auth.Api.Controllers;

[ApiController]
[Route("api/auth")]
public sealed class AuthController(AuthService authService) : ControllerBase
{
    [HttpPost("register")]
    public ActionResult<AuthResponse> Register(RegisterRequest request)
    {
        return Ok(authService.Register(request));
    }

    [HttpPost("login")]
    public ActionResult<AuthResponse> Login(LoginRequest request)
    {
        var response = authService.Login(request);
        return response is null ? Unauthorized() : Ok(response);
    }
}
