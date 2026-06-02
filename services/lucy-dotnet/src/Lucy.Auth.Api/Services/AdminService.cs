using Lucy.Auth.Api.Data;
using Lucy.Auth.Api.Dtos;
using Lucy.Auth.Api.Entities;
using Lucy.Shared.Constants;
using Microsoft.EntityFrameworkCore;

namespace Lucy.Auth.Api.Services;

public sealed class AdminService(AuthDbContext db)
{
    // ────────────────────────────────────────────────────────────────────────
    // Danh sách tài khoản
    // ────────────────────────────────────────────────────────────────────────
    public async Task<(List<UserDto> Users, int Total)> GetUsersAsync(
        string? keyword, string? role, int page, int size)
    {
        var query = db.Users
            .Include(u => u.UserRoles).ThenInclude(ur => ur.Role)
            .AsQueryable();

        if (!string.IsNullOrWhiteSpace(keyword))
        {
            var kw = keyword.Trim().ToLower();
            query = query.Where(u =>
                u.FullName.ToLower().Contains(kw) ||
                u.Email.ToLower().Contains(kw) ||
                (u.PhoneNumber != null && u.PhoneNumber.Contains(kw)));
        }

        if (!string.IsNullOrWhiteSpace(role))
        {
            query = query.Where(u => u.UserRoles.Any(ur => ur.Role.Code == role.ToUpper()));
        }

        var total = await query.CountAsync();
        var users = await query
            .OrderByDescending(u => u.CreatedAt)
            .Skip((page - 1) * size)
            .Take(size)
            .Select(u => new UserDto(
                u.Id.ToString(), u.FullName, u.PhoneNumber,
                u.Email, u.AvatarPersonaUrl, u.IsActive, u.CreatedAt))
            .ToListAsync();

        return (users, total);
    }

    // ────────────────────────────────────────────────────────────────────────
    // Hồ sơ đăng ký Mentor
    // ────────────────────────────────────────────────────────────────────────
    public async Task<List<ApplicationDto>> GetMentorApplicationsAsync(string? status)
    {
        var query = db.MentorApplications.AsQueryable();

        if (!string.IsNullOrWhiteSpace(status))
            query = query.Where(a => a.Status == status.ToUpper());

        return await query
            .OrderByDescending(a => a.CreatedAt)
            .Select(a => new ApplicationDto(
                a.Id.ToString(), a.UserId.ToString(), "MENTOR",
                a.Status, a.RejectReason, a.CreatedAt))
            .ToListAsync();
    }

    public async Task<(bool Ok, string? Error)> ApproveMentorApplicationAsync(
        string applicationId, AdminDecisionRequest request, Guid adminUserId)
    {
        if (!Guid.TryParse(applicationId, out var appGuid))
            return (false, "applicationId không hợp lệ.");

        var app = await db.MentorApplications.FindAsync(appGuid);
        if (app is null) return (false, "Không tìm thấy hồ sơ.");
        if (app.Status != CommonStatus.Pending) return (false, "Hồ sơ này đã được xử lý.");

        // Assign MENTOR role
        var mentorRole = await db.Roles.FirstOrDefaultAsync(r => r.Code == RoleCodes.Mentor)
            ?? throw new InvalidOperationException("Role MENTOR không tồn tại.");

        var alreadyMentor = await db.UserRoles
            .AnyAsync(ur => ur.UserId == app.UserId && ur.RoleId == mentorRole.Id);

        if (!alreadyMentor)
            db.UserRoles.Add(new UserRole { UserId = app.UserId, RoleId = mentorRole.Id });

        app.Status = CommonStatus.Approved;
        app.ReviewedAt = DateTimeOffset.UtcNow;
        app.ReviewedByUserId = adminUserId;

        await db.SaveChangesAsync();
        return (true, null);
    }

    public async Task<(bool Ok, string? Error)> RejectMentorApplicationAsync(
        string applicationId, AdminDecisionRequest request, Guid adminUserId)
    {
        if (!Guid.TryParse(applicationId, out var appGuid))
            return (false, "applicationId không hợp lệ.");

        var app = await db.MentorApplications.FindAsync(appGuid);
        if (app is null) return (false, "Không tìm thấy hồ sơ.");
        if (app.Status != CommonStatus.Pending) return (false, "Hồ sơ này đã được xử lý.");

        app.Status = CommonStatus.Rejected;
        app.RejectReason = request.Reason;
        app.ReviewedAt = DateTimeOffset.UtcNow;
        app.ReviewedByUserId = adminUserId;

        await db.SaveChangesAsync();
        return (true, null);
    }

    // ────────────────────────────────────────────────────────────────────────
    // Yêu cầu nâng cấp Creator
    // ────────────────────────────────────────────────────────────────────────
    public async Task<List<ApplicationDto>> GetCreatorUpgradeRequestsAsync(string? status)
    {
        var query = db.CreatorUpgradeRequests.AsQueryable();

        if (!string.IsNullOrWhiteSpace(status))
            query = query.Where(r => r.Status == status.ToUpper());

        return await query
            .OrderByDescending(r => r.CreatedAt)
            .Select(r => new ApplicationDto(
                r.Id.ToString(), r.UserId.ToString(), "CREATOR",
                r.Status, r.RejectReason, r.CreatedAt))
            .ToListAsync();
    }

    public async Task<(bool Ok, string? Error)> ApproveCreatorUpgradeRequestAsync(
        string requestId, AdminDecisionRequest request, Guid adminUserId)
    {
        if (!Guid.TryParse(requestId, out var reqGuid))
            return (false, "requestId không hợp lệ.");

        var upgradeReq = await db.CreatorUpgradeRequests.FindAsync(reqGuid);
        if (upgradeReq is null) return (false, "Không tìm thấy yêu cầu.");
        if (upgradeReq.Status != CommonStatus.Pending) return (false, "Yêu cầu này đã được xử lý.");

        var creatorRole = await db.Roles.FirstOrDefaultAsync(r => r.Code == RoleCodes.Creator)
            ?? throw new InvalidOperationException("Role CREATOR không tồn tại.");

        var alreadyCreator = await db.UserRoles
            .AnyAsync(ur => ur.UserId == upgradeReq.UserId && ur.RoleId == creatorRole.Id);

        if (!alreadyCreator)
            db.UserRoles.Add(new UserRole { UserId = upgradeReq.UserId, RoleId = creatorRole.Id });

        upgradeReq.Status = CommonStatus.Approved;
        upgradeReq.ReviewedAt = DateTimeOffset.UtcNow;
        upgradeReq.ReviewedByUserId = adminUserId;

        await db.SaveChangesAsync();
        return (true, null);
    }

    public async Task<(bool Ok, string? Error)> RejectCreatorUpgradeRequestAsync(
        string requestId, AdminDecisionRequest request, Guid adminUserId)
    {
        if (!Guid.TryParse(requestId, out var reqGuid))
            return (false, "requestId không hợp lệ.");

        var upgradeReq = await db.CreatorUpgradeRequests.FindAsync(reqGuid);
        if (upgradeReq is null) return (false, "Không tìm thấy yêu cầu.");
        if (upgradeReq.Status != CommonStatus.Pending) return (false, "Yêu cầu này đã được xử lý.");

        upgradeReq.Status = CommonStatus.Rejected;
        upgradeReq.RejectReason = request.Reason;
        upgradeReq.ReviewedAt = DateTimeOffset.UtcNow;
        upgradeReq.ReviewedByUserId = adminUserId;

        await db.SaveChangesAsync();
        return (true, null);
    }
}
