using Lucy.Auth.Api.Data;
using Lucy.Auth.Api.Dtos;
using Lucy.Auth.Api.Entities;
using Lucy.Shared.Constants;
using Microsoft.EntityFrameworkCore;

namespace Lucy.Auth.Api.Services;

public sealed class AdminService(AuthDbContext db)
{
    public async Task<(List<AdminUserDto> Users, int Total)> GetUsersAsync(
        string? keyword, string? role, int page, int size)
    {
        var query = db.Users
            .Include(u => u.AvatarPersona)
            .Include(u => u.UserRoles).ThenInclude(ur => ur.Role)
            .AsQueryable();

        if (!string.IsNullOrWhiteSpace(keyword))
        {
            var kw = keyword.Trim().ToLower();
            query = query.Where(u =>
                u.FullName.ToLower().Contains(kw) ||
                u.Email.ToLower().Contains(kw) ||
                u.PhoneNumber.Contains(kw));
        }

        if (!string.IsNullOrWhiteSpace(role))
        {
            var normalizedRole = NormalizeRoleFilter(role);
            query = query.Where(u => u.UserRoles.Any(ur =>
                ur.RoleId == normalizedRole || ur.Role.RoleName == normalizedRole));
        }

        var total = await query.CountAsync();
        var users = await query
            .OrderByDescending(u => u.CreatedAt)
            .Skip((page - 1) * size)
            .Take(size)
            .Select(u => new AdminUserDto(
                u.UserId, u.FullName, u.PhoneNumber, u.Email,
                u.AvatarPersona == null ? null : u.AvatarPersona.AvatarUrl,
                u.IsStatus, u.CreatedAt,
                u.UserRoles
                    .Select(ur => new RoleDto(ur.Role.RoleId, ur.Role.RoleName))
                    .ToList()))
            .ToListAsync();

        return (users, total);
    }

    public async Task<List<ApplicationDto>> GetMentorApplicationsAsync(string? status)
    {
        var query = db.MentorApplications.AsQueryable();

        if (!string.IsNullOrWhiteSpace(status))
            query = query.Where(a => a.Status == status.ToUpper());

        return await query
            .OrderByDescending(a => a.SubmittedAt)
            .Select(a => new ApplicationDto(
                a.ApplicationId, a.UserId, RoleCodes.Mentor,
                a.Status, a.RejectReason, a.SubmittedAt))
            .ToListAsync();
    }

    public async Task<(bool Ok, string? Error)> ApproveMentorApplicationAsync(
        string applicationId, AdminDecisionRequest request, string adminUserId)
    {
        var app = await db.MentorApplications.FindAsync(applicationId);
        if (app is null) return (false, "Khong tim thay ho so.");
        if (app.Status != CommonStatus.Pending) return (false, "Ho so nay da duoc xu ly.");

        await AssignRoleAsync(app.UserId, RoleCodes.MentorId);
        app.Status = CommonStatus.Approved;

        await db.SaveChangesAsync();
        return (true, null);
    }

    public async Task<(bool Ok, string? Error)> RejectMentorApplicationAsync(
        string applicationId, AdminDecisionRequest request, string adminUserId)
    {
        var app = await db.MentorApplications.FindAsync(applicationId);
        if (app is null) return (false, "Khong tim thay ho so.");
        if (app.Status != CommonStatus.Pending) return (false, "Ho so nay da duoc xu ly.");

        app.Status = CommonStatus.Rejected;
        app.RejectReason = request.Reason;

        await db.SaveChangesAsync();
        return (true, null);
    }

    public async Task<List<ApplicationDto>> GetCreatorUpgradeRequestsAsync(string? status)
    {
        var query = db.CreatorUpgradeRequests.AsQueryable();

        if (!string.IsNullOrWhiteSpace(status))
            query = query.Where(r => r.Status == status.ToUpper());

        return await query
            .OrderByDescending(r => r.SubmittedAt)
            .Select(r => new ApplicationDto(
                r.UpgradeRequestId, r.UserId, RoleCodes.Creator,
                r.Status, r.RejectReason, r.SubmittedAt))
            .ToListAsync();
    }

    public async Task<(bool Ok, string? Error)> ApproveCreatorUpgradeRequestAsync(
        string requestId, AdminDecisionRequest request, string adminUserId)
    {
        var upgradeReq = await db.CreatorUpgradeRequests.FindAsync(requestId);
        if (upgradeReq is null) return (false, "Khong tim thay yeu cau.");
        if (upgradeReq.Status != CommonStatus.Pending) return (false, "Yeu cau nay da duoc xu ly.");

        await AssignRoleAsync(upgradeReq.UserId, RoleCodes.CreatorId);
        upgradeReq.Status = CommonStatus.Approved;

        await db.SaveChangesAsync();
        return (true, null);
    }

    public async Task<(bool Ok, string? Error)> RejectCreatorUpgradeRequestAsync(
        string requestId, AdminDecisionRequest request, string adminUserId)
    {
        var upgradeReq = await db.CreatorUpgradeRequests.FindAsync(requestId);
        if (upgradeReq is null) return (false, "Khong tim thay yeu cau.");
        if (upgradeReq.Status != CommonStatus.Pending) return (false, "Yeu cau nay da duoc xu ly.");

        upgradeReq.Status = CommonStatus.Rejected;
        upgradeReq.RejectReason = request.Reason;

        await db.SaveChangesAsync();
        return (true, null);
    }

    public async Task<(bool Ok, string? Error)> UpdateUserStatusAsync(string userId, int isStatus)
    {
        var user = await db.Users.FindAsync(userId);
        if (user is null) return (false, "Khong tim thay nguoi dung.");
        user.IsStatus = isStatus;
        await db.SaveChangesAsync();
        return (true, null);
    }

    private async Task AssignRoleAsync(string userId, string roleId)
    {
        if (!await db.Roles.AnyAsync(r => r.RoleId == roleId))
            throw new InvalidOperationException($"Role {roleId} khong ton tai.");

        var alreadyAssigned = await db.UserRoles.AnyAsync(ur => ur.UserId == userId && ur.RoleId == roleId);
        if (!alreadyAssigned)
            db.UserRoles.Add(new UserRole { UserId = userId, RoleId = roleId });
    }

    private static string NormalizeRoleFilter(string role) => role.Trim().ToUpper() switch
    {
        RoleCodes.Admin => RoleCodes.AdminId,
        RoleCodes.Learner => RoleCodes.LearnerId,
        RoleCodes.Mentor => RoleCodes.MentorId,
        RoleCodes.Creator => RoleCodes.CreatorId,
        _ => role.Trim().ToUpper()
    };
}
