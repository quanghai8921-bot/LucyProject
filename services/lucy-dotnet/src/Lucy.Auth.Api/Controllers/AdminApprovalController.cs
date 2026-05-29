using Lucy.Auth.Api.Data;
using Microsoft.AspNetCore.Mvc;

namespace Lucy.Auth.Api.Controllers;

[ApiController]
[Route("api/admin/approvals")]
public sealed class AdminApprovalController(AuthDbContext dbContext) : ControllerBase
{
    [HttpGet("mentor-applications")]
    public IActionResult GetMentorApplications()
    {
        return Ok(dbContext.MentorApplications);
    }

    [HttpGet("creator-upgrade-requests")]
    public IActionResult GetCreatorUpgradeRequests()
    {
        return Ok(dbContext.CreatorUpgradeRequests);
    }
}
