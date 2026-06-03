using System.Security.Claims;
using Lucy.Auth.Api.Dtos;
using Lucy.Auth.Api.Services;
using Lucy.Shared.Dtos;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace Lucy.Auth.Api.Controllers.Admin;

[ApiController]
[Route("api/admin/creator-upgrade-requests")]
[Authorize(Roles = "ADMIN")]
[Produces("application/json")]
public sealed class AdminCreatorUpgradeRequestsController(AdminService adminService) : ControllerBase
{
    [HttpGet]
    [ProducesResponseType(typeof(ApiResponse<List<ApplicationDto>>), 200)]
    public async Task<IActionResult> GetCreatorUpgradeRequests([FromQuery] string? status)
    {
        var list = await adminService.GetCreatorUpgradeRequestsAsync(status);
        return Ok(ApiResponse<List<ApplicationDto>>.Ok(list));
    }

    [HttpPatch("{requestId}/approve")]
    [ProducesResponseType(typeof(ApiResponse<object>), 200)]
    [ProducesResponseType(typeof(ApiResponse<object>), 400)]
    [ProducesResponseType(typeof(ApiResponse<object>), 404)]
    public async Task<IActionResult> Approve(
        [FromRoute] string requestId,
        [FromBody] AdminDecisionRequest request)
    {
        var (ok, error) = await adminService.ApproveCreatorUpgradeRequestAsync(requestId, request, GetCurrentUserId());

        if (!ok)
            return error!.Contains("tim thay") ? NotFound(ApiResponse<object>.Fail(error)) : BadRequest(ApiResponse<object>.Fail(error));

        return Ok(ApiResponse<object>.Ok(new { }, "Da duyet yeu cau nang cap Creator thanh cong"));
    }

    [HttpPatch("{requestId}/reject")]
    [ProducesResponseType(typeof(ApiResponse<object>), 200)]
    [ProducesResponseType(typeof(ApiResponse<object>), 400)]
    [ProducesResponseType(typeof(ApiResponse<object>), 404)]
    public async Task<IActionResult> Reject(
        [FromRoute] string requestId,
        [FromBody] AdminDecisionRequest request)
    {
        var (ok, error) = await adminService.RejectCreatorUpgradeRequestAsync(requestId, request, GetCurrentUserId());

        if (!ok)
            return error!.Contains("tim thay") ? NotFound(ApiResponse<object>.Fail(error)) : BadRequest(ApiResponse<object>.Fail(error));

        return Ok(ApiResponse<object>.Ok(new { }, "Da tu choi yeu cau nang cap Creator"));
    }

    private string GetCurrentUserId() =>
        User.FindFirstValue(ClaimTypes.NameIdentifier) ?? User.FindFirstValue("sub") ?? string.Empty;
}
