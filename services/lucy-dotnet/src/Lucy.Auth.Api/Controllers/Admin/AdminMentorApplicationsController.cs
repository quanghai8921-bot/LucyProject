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
    // GET /api/admin/mentor-applications?status=PENDING
    [HttpGet]
    [ProducesResponseType(typeof(ApiResponse<List<ApplicationDto>>), 200)]
    public async Task<IActionResult> GetMentorApplications([FromQuery] string? status)
    {
        var list = await adminService.GetMentorApplicationsAsync(status);
        return Ok(ApiResponse<List<ApplicationDto>>.Ok(list));
    }

    // PATCH /api/admin/mentor-applications/{applicationId}/approve
    [HttpPatch("{applicationId}/approve")]
    [ProducesResponseType(typeof(ApiResponse<object>), 200)]
    [ProducesResponseType(typeof(ApiResponse<object>), 400)]
    [ProducesResponseType(typeof(ApiResponse<object>), 404)]
    public async Task<IActionResult> Approve(
        [FromRoute] string applicationId,
        [FromBody] AdminDecisionRequest request)
    {
        var adminId = GetCurrentUserId();
        var (ok, error) = await adminService.ApproveMentorApplicationAsync(applicationId, request, adminId);

        if (!ok)
        {
            if (error!.Contains("không tìm thấy"))
                return NotFound(ApiResponse<object>.Fail(error));
            return BadRequest(ApiResponse<object>.Fail(error));
        }

        return Ok(ApiResponse<object>.Ok(new { }, "Đã duyệt hồ sơ mentor thành công"));
    }

    // PATCH /api/admin/mentor-applications/{applicationId}/reject
    [HttpPatch("{applicationId}/reject")]
    [ProducesResponseType(typeof(ApiResponse<object>), 200)]
    [ProducesResponseType(typeof(ApiResponse<object>), 400)]
    [ProducesResponseType(typeof(ApiResponse<object>), 404)]
    public async Task<IActionResult> Reject(
        [FromRoute] string applicationId,
        [FromBody] AdminDecisionRequest request)
    {
        var adminId = GetCurrentUserId();
        var (ok, error) = await adminService.RejectMentorApplicationAsync(applicationId, request, adminId);

        if (!ok)
        {
            if (error!.Contains("không tìm thấy"))
                return NotFound(ApiResponse<object>.Fail(error));
            return BadRequest(ApiResponse<object>.Fail(error));
        }

        return Ok(ApiResponse<object>.Ok(new { }, "Đã từ chối hồ sơ mentor"));
    }

    private Guid GetCurrentUserId()
    {
        var sub = User.FindFirstValue(ClaimTypes.NameIdentifier)
               ?? User.FindFirstValue("sub");
        return Guid.TryParse(sub, out var id) ? id : Guid.Empty;
    }
}
