using Lucy.Auth.Api.Data;
using Lucy.Auth.Api.Dtos;
using Lucy.Auth.Api.Entities;
using Lucy.Shared.Constants;
using Lucy.Shared.Dtos;
using Microsoft.EntityFrameworkCore;

namespace Lucy.Auth.Api.Services;

public sealed class AuthService(AuthDbContext db, JwtService jwtService)
{
    // ────────────────────────────────────────────────────────────────────────
    // Đăng ký tài khoản Lucy ẩn danh (Learner)
    // ────────────────────────────────────────────────────────────────────────
    public async Task<(AuthTokenResponse? Response, string? Error)> RegisterAsync(RegisterRequest request)
    {
        if (await db.Users.AnyAsync(u => u.Email == request.Email))
            return (null, "Email đã được sử dụng.");

        if (request.PhoneNumber != null && await db.Users.AnyAsync(u => u.PhoneNumber == request.PhoneNumber))
            return (null, "Số điện thoại đã được sử dụng.");

        var learnerRole = await db.Roles.FirstOrDefaultAsync(r => r.Code == RoleCodes.Learner)
            ?? throw new InvalidOperationException("Role LEARNER không tìm thấy trong DB.");

        var user = new User
        {
            FullName = request.FullName,
            Email = request.Email,
            PhoneNumber = request.PhoneNumber,
            PasswordHash = BCrypt.Net.BCrypt.HashPassword(request.Password),
            BirthDate = request.BirthDate != null ? DateOnly.Parse(request.BirthDate) : null,
            AvatarPersonaUrl = request.AvatarPersonaUrl
        };

        db.Users.Add(user);
        db.UserRoles.Add(new UserRole { UserId = user.Id, RoleId = learnerRole.Id });
        await db.SaveChangesAsync();

        return (BuildAuthTokenResponse(user, [learnerRole], "Đăng ký thành công"), null);
    }

    // ────────────────────────────────────────────────────────────────────────
    // Đăng ký Mentor (cần admin phê duyệt)
    // ────────────────────────────────────────────────────────────────────────
    public async Task<(ApplicationDto? Application, string? Error)> RegisterMentorAsync(
        MentorRegisterRequest request, string? certificateFileUrl)
    {
        if (await db.Users.AnyAsync(u => u.Email == request.Email))
            return (null, "Email đã được sử dụng.");

        var learnerRole = await db.Roles.FirstOrDefaultAsync(r => r.Code == RoleCodes.Learner)
            ?? throw new InvalidOperationException("Role LEARNER không tìm thấy.");

        var user = new User
        {
            FullName = request.FullName,
            Email = request.Email,
            PhoneNumber = request.PhoneNumber,
            PasswordHash = BCrypt.Net.BCrypt.HashPassword(request.Password),
            BirthDate = request.BirthDate != null ? DateOnly.Parse(request.BirthDate) : null
        };

        var application = new MentorApplication
        {
            UserId = user.Id,
            LanguageId = request.LanguageId,
            ExperienceDescription = request.ExperienceDescription,
            CertificateFileUrl = certificateFileUrl,
            Status = CommonStatus.Pending
        };

        db.Users.Add(user);
        db.UserRoles.Add(new UserRole { UserId = user.Id, RoleId = learnerRole.Id });
        db.MentorApplications.Add(application);
        await db.SaveChangesAsync();

        return (MapApplication(application, "MENTOR"), null);
    }

    // ────────────────────────────────────────────────────────────────────────
    // Đăng nhập
    // ────────────────────────────────────────────────────────────────────────
    public async Task<(AuthTokenResponse? Response, string? Error)> LoginAsync(LoginRequest request)
    {
        var user = await db.Users
            .Include(u => u.UserRoles).ThenInclude(ur => ur.Role)
            .FirstOrDefaultAsync(u => u.Email == request.Email);

        if (user is null || !BCrypt.Net.BCrypt.Verify(request.Password, user.PasswordHash))
            return (null, "Email hoặc mật khẩu không đúng.");

        if (!user.IsActive)
            return (null, "Tài khoản đã bị khóa.");

        var roles = user.UserRoles.Select(ur => ur.Role).ToList();
        return (BuildAuthTokenResponse(user, roles, "Đăng nhập thành công"), null);
    }

    // ────────────────────────────────────────────────────────────────────────
    // Lấy thông tin user hiện tại
    // ────────────────────────────────────────────────────────────────────────
    public async Task<UserProfileData?> GetMeAsync(Guid userId)
    {
        var user = await db.Users
            .Include(u => u.UserRoles).ThenInclude(ur => ur.Role)
            .FirstOrDefaultAsync(u => u.Id == userId);

        if (user is null) return null;

        var roles = user.UserRoles.Select(ur => new RoleDto(ur.Role.Code, ur.Role.Name)).ToList();
        return new UserProfileData(MapUserDto(user), roles);
    }

    // ────────────────────────────────────────────────────────────────────────
    // Lấy danh sách roles của user hiện tại
    // ────────────────────────────────────────────────────────────────────────
    public async Task<List<RoleDto>> GetMyRolesAsync(Guid userId)
    {
        return await db.UserRoles
            .Where(ur => ur.UserId == userId)
            .Include(ur => ur.Role)
            .Select(ur => new RoleDto(ur.Role.Code, ur.Role.Name))
            .ToListAsync();
    }

    // ────────────────────────────────────────────────────────────────────────
    // Mentor gửi yêu cầu nâng cấp lên Creator
    // ────────────────────────────────────────────────────────────────────────
    public async Task<(ApplicationDto? Application, string? Error)> CreateCreatorUpgradeRequestAsync(
        Guid userId, CreatorUpgradeRequestCreateDto request)
    {
        // Kiểm tra user có role MENTOR chưa
        var isMentor = await db.UserRoles
            .Include(ur => ur.Role)
            .AnyAsync(ur => ur.UserId == userId && ur.Role.Code == RoleCodes.Mentor);

        if (!isMentor)
            return (null, "Chỉ Mentor mới có thể gửi yêu cầu nâng cấp Creator.");

        // Kiểm tra đã có yêu cầu PENDING chưa
        var hasPending = await db.CreatorUpgradeRequests
            .AnyAsync(r => r.UserId == userId && r.Status == CommonStatus.Pending);

        if (hasPending)
            return (null, "Bạn đã có yêu cầu đang chờ xét duyệt.");

        var upgradeRequest = new CreatorUpgradeRequest
        {
            UserId = userId,
            Reason = request.Reason,
            EvidenceUrl = request.EvidenceUrl,
            Status = CommonStatus.Pending
        };

        db.CreatorUpgradeRequests.Add(upgradeRequest);
        await db.SaveChangesAsync();

        return (MapApplication(upgradeRequest, "CREATOR"), null);
    }

    // ────────────────────────────────────────────────────────────────────────
    // Helpers
    // ────────────────────────────────────────────────────────────────────────
    private AuthTokenResponse BuildAuthTokenResponse(User user, IEnumerable<Role> roles, string message)
    {
        var roleDtos = roles.Select(r => new RoleDto(r.Code, r.Name)).ToList();
        var roleCodes = roles.Select(r => r.Code);
        var token = jwtService.CreateToken(user, roleCodes);

        return new AuthTokenResponse(
            Success: true,
            Message: message,
            Data: new AuthTokenData(
                AccessToken: token,
                TokenType: "Bearer",
                User: MapUserDto(user),
                Roles: roleDtos
            )
        );
    }

    private static UserDto MapUserDto(User user) =>
        new(user.Id.ToString(), user.FullName, user.PhoneNumber, user.Email,
            user.AvatarPersonaUrl, user.IsActive, user.CreatedAt);

    private static ApplicationDto MapApplication(MentorApplication app, string type) =>
        new(app.Id.ToString(), app.UserId.ToString(), type, app.Status,
            app.RejectReason, app.CreatedAt);

    private static ApplicationDto MapApplication(CreatorUpgradeRequest req, string type) =>
        new(req.Id.ToString(), req.UserId.ToString(), type, req.Status,
            req.RejectReason, req.CreatedAt);
}
