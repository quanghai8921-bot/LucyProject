using System.Security.Claims;
using Lucy.Auth.Api.Dtos;
using Lucy.Auth.Api.Services;
using Lucy.Shared.Dtos;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace Lucy.Auth.Api.Controllers.Admin;

[ApiController]
[Route("api/admin/mentor-applications")]
[Authorize(Roles = "ADMIN")]
[Produces("application/json")]
public sealed class AdminMentorApplicationsController(AdminService adminService) : ControllerBase
{
    [HttpGet]
    [ProducesResponseType(typeof(ApiResponse<List<ApplicationDto>>), 200)]
    public async Task<IActionResult> GetMentorApplications([FromQuery] string? status)
    {
        var list = await adminService.GetMentorApplicationsAsync(status);
        return Ok(ApiResponse<List<ApplicationDto>>.Ok(list));
    }

    [HttpPatch("{applicationId}/approve")]
    [ProducesResponseType(typeof(ApiResponse<object>), 200)]
    [ProducesResponseType(typeof(ApiResponse<object>), 400)]
    [ProducesResponseType(typeof(ApiResponse<object>), 404)]
    public async Task<IActionResult> Approve(
        [FromRoute] string applicationId,
        [FromBody] AdminDecisionRequest request)
    {
        var (ok, error) = await adminService.ApproveMentorApplicationAsync(applicationId, request, GetCurrentUserId());

        if (!ok)
            return error!.Contains("tim thay") ? NotFound(ApiResponse<object>.Fail(error)) : BadRequest(ApiResponse<object>.Fail(error));

        return Ok(ApiResponse<object>.Ok(new { }, "Da duyet ho so mentor thanh cong"));
    }

    [HttpPatch("{applicationId}/reject")]
    [ProducesResponseType(typeof(ApiResponse<object>), 200)]
    [ProducesResponseType(typeof(ApiResponse<object>), 400)]
    [ProducesResponseType(typeof(ApiResponse<object>), 404)]
    public async Task<IActionResult> Reject(
        [FromRoute] string applicationId,
        [FromBody] AdminDecisionRequest request)
    {
        var (ok, error) = await adminService.RejectMentorApplicationAsync(applicationId, request, GetCurrentUserId());

        if (!ok)
            return error!.Contains("tim thay") ? NotFound(ApiResponse<object>.Fail(error)) : BadRequest(ApiResponse<object>.Fail(error));

        return Ok(ApiResponse<object>.Ok(new { }, "Da tu choi ho so mentor"));
    }

    private string GetCurrentUserId() =>
        User.FindFirstValue(ClaimTypes.NameIdentifier) ?? User.FindFirstValue("sub") ?? string.Empty;
}
