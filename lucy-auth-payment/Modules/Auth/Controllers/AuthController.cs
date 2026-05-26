using lucy_auth_payment.Common;
using lucy_auth_payment.Modules.Auth.DTOs;
using lucy_auth_payment.Modules.Auth.Services;
using Microsoft.AspNetCore.Mvc;

namespace lucy_auth_payment.Modules.Auth.Controllers;

[ApiController]
[Route(Constants.AuthRoute)]
public class AuthController : ControllerBase
{
    private readonly AuthService _authService;

    public AuthController(AuthService authService)
    {
        _authService = authService;
    }

    [HttpPost("login")]
    public IActionResult Login(LoginRequest request)
    {
        return Ok(_authService.Login(request));
    }

    [HttpPost("register")]
    public IActionResult Register(RegisterRequest request)
    {
        return Ok(_authService.Register(request));
    }
}
