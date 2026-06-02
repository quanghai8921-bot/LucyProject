using Lucy.Auth.Api.Dtos;
using Lucy.Auth.Api.Services;
using Lucy.Shared.Dtos;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace Lucy.Auth.Api.Controllers.Admin;

[ApiController]
[Route("api/admin/users")]
[Authorize(Roles = "ADMIN")]
[Produces("application/json")]
public sealed class AdminUsersController(AdminService adminService) : ControllerBase
{
    // GET /api/admin/users?keyword=&role=&page=1&size=20
    [HttpGet]
    [ProducesResponseType(typeof(object), 200)]
    public async Task<IActionResult> GetUsers(
        [FromQuery] string? keyword,
        [FromQuery] string? role,
        [FromQuery] int page = 1,
        [FromQuery] int size = 20)
    {
        if (page < 1) page = 1;
        if (size < 1 || size > 100) size = 20;

        var (users, total) = await adminService.GetUsersAsync(keyword, role, page, size);

        return Ok(new
        {
            success = true,
            data = users,
            page,
            size,
            total
        });
    }
}
