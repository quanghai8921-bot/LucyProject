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
    // GET /api/admin/creator-upgrade-requests?status=PENDING
    [HttpGet]
    [ProducesResponseType(typeof(ApiResponse<List<ApplicationDto>>), 200)]
    public async Task<IActionResult> GetCreatorUpgradeRequests([FromQuery] string? status)
    {
        var list = await adminService.GetCreatorUpgradeRequestsAsync(status);
        return Ok(ApiResponse<List<ApplicationDto>>.Ok(list));
    }

    // PATCH /api/admin/creator-upgrade-requests/{requestId}/approve
    [HttpPatch("{requestId}/approve")]
    [ProducesResponseType(typeof(ApiResponse<object>), 200)]
    [ProducesResponseType(typeof(ApiResponse<object>), 400)]
    [ProducesResponseType(typeof(ApiResponse<object>), 404)]
    public async Task<IActionResult> Approve(
        [FromRoute] string requestId,
        [FromBody] AdminDecisionRequest request)
    {
        var adminId = GetCurrentUserId();
        var (ok, error) = await adminService.ApproveCreatorUpgradeRequestAsync(requestId, request, adminId);

        if (!ok)
        {
            if (error!.Contains("không tìm thấy"))
                return NotFound(ApiResponse<object>.Fail(error));
            return BadRequest(ApiResponse<object>.Fail(error));
        }

        return Ok(ApiResponse<object>.Ok(new { }, "Đã duyệt yêu cầu nâng cấp Creator thành công"));
    }

    // PATCH /api/admin/creator-upgrade-requests/{requestId}/reject
    [HttpPatch("{requestId}/reject")]
    [ProducesResponseType(typeof(ApiResponse<object>), 200)]
    [ProducesResponseType(typeof(ApiResponse<object>), 400)]
    [ProducesResponseType(typeof(ApiResponse<object>), 404)]
    public async Task<IActionResult> Reject(
        [FromRoute] string requestId,
        [FromBody] AdminDecisionRequest request)
    {
        var adminId = GetCurrentUserId();
        var (ok, error) = await adminService.RejectCreatorUpgradeRequestAsync(requestId, request, adminId);

        if (!ok)
        {
            if (error!.Contains("không tìm thấy"))
                return NotFound(ApiResponse<object>.Fail(error));
            return BadRequest(ApiResponse<object>.Fail(error));
        }

        return Ok(ApiResponse<object>.Ok(new { }, "Đã từ chối yêu cầu nâng cấp Creator"));
    }

    private Guid GetCurrentUserId()
    {
        var sub = User.FindFirstValue(ClaimTypes.NameIdentifier)
               ?? User.FindFirstValue("sub");
        return Guid.TryParse(sub, out var id) ? id : Guid.Empty;
    }
}
