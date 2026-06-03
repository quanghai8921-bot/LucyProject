using Lucy.Auth.Api.Data;
using Lucy.Auth.Api.Dtos;
using Lucy.Auth.Api.Entities;
using Lucy.Shared.Constants;
using Microsoft.EntityFrameworkCore;

namespace Lucy.Auth.Api.Services;

public sealed class AuthService(AuthDbContext db, JwtService jwtService)
{
    public async Task<(AuthTokenResponse? Response, string? Error)> RegisterAsync(RegisterRequest request)
    {
        var normalizedEmail = request.Email.Trim();
        var phoneNumber = request.PhoneNumber.Trim();

        if (await db.Users.AnyAsync(u => u.Email == normalizedEmail))
            return (null, "Email da duoc su dung.");

        if (await db.Users.AnyAsync(u => u.PhoneNumber == phoneNumber))
            return (null, "So dien thoai da duoc su dung.");

        var learnerRole = await db.Roles.FindAsync(RoleCodes.LearnerId)
            ?? throw new InvalidOperationException("Role R002 khong ton tai trong DB.");

        var user = new User
        {
            UserId = NewId("U"),
            FullName = request.FullName.Trim(),
            Email = normalizedEmail,
            PhoneNumber = phoneNumber,
            Passwords = BCrypt.Net.BCrypt.HashPassword(request.Password),
            IsStatus = 1
        };

        var avatarPersona = new AvatarPersona
        {
            UserId = user.UserId,
            DisplayName = string.IsNullOrWhiteSpace(request.AvatarDisplayName)
                ? user.FullName
                : request.AvatarDisplayName.Trim(),
            AvatarUrl = request.AvatarUrl,
            IsAnonymous = 1
        };
        user.AvatarPersona = avatarPersona;

        db.Users.Add(user);
        db.UserRoles.Add(new UserRole { UserId = user.UserId, RoleId = learnerRole.RoleId });
        db.AvatarPersonas.Add(avatarPersona);

        await db.SaveChangesAsync();

        user.UserRoles.Add(new UserRole { UserId = user.UserId, RoleId = learnerRole.RoleId, Role = learnerRole });
        return (BuildAuthTokenResponse(user, [learnerRole], "Dang ky thanh cong"), null);
    }

    public async Task<(ApplicationDto? Application, string? Error)> RegisterMentorAsync(
        MentorRegisterRequest request, string? certificateUrl)
    {
        var normalizedEmail = request.Email.Trim();
        var phoneNumber = request.PhoneNumber.Trim();

        if (await db.Users.AnyAsync(u => u.Email == normalizedEmail))
            return (null, "Email da duoc su dung.");

        if (await db.Users.AnyAsync(u => u.PhoneNumber == phoneNumber))
            return (null, "So dien thoai da duoc su dung.");

        if (!string.IsNullOrWhiteSpace(request.LanguageId)
            && !await db.Languages.AnyAsync(l => l.LanguageId == request.LanguageId))
        {
            return (null, "LanguageId khong ton tai.");
        }

        var learnerRole = await db.Roles.FindAsync(RoleCodes.LearnerId)
            ?? throw new InvalidOperationException("Role R002 khong ton tai trong DB.");

        var user = new User
        {
            UserId = NewId("U"),
            FullName = request.FullName.Trim(),
            Email = normalizedEmail,
            PhoneNumber = phoneNumber,
            Passwords = BCrypt.Net.BCrypt.HashPassword(request.Password),
            IsStatus = 1
        };

        var application = new MentorApplication
        {
            ApplicationId = NewId("MA"),
            UserId = user.UserId,
            LanguageId = string.IsNullOrWhiteSpace(request.LanguageId) ? null : request.LanguageId,
            CertificateUrl = certificateUrl,
            Status = CommonStatus.Pending
        };

        var avatarPersona = new AvatarPersona
        {
            UserId = user.UserId,
            DisplayName = string.IsNullOrWhiteSpace(request.AvatarDisplayName)
                ? user.FullName
                : request.AvatarDisplayName.Trim(),
            AvatarUrl = request.AvatarUrl,
            IsAnonymous = 1
        };
        user.AvatarPersona = avatarPersona;

        db.Users.Add(user);
        db.UserRoles.Add(new UserRole { UserId = user.UserId, RoleId = learnerRole.RoleId });
        db.AvatarPersonas.Add(avatarPersona);
        db.MentorApplications.Add(application);
        await db.SaveChangesAsync();

        return (MapApplication(application, RoleCodes.Mentor), null);
    }

    public async Task<(AuthTokenResponse? Response, string? Error)> LoginAsync(LoginRequest request)
    {
        var user = await db.Users
            .Include(u => u.AvatarPersona)
            .Include(u => u.UserRoles).ThenInclude(ur => ur.Role)
            .FirstOrDefaultAsync(u => u.Email == request.Email);

        if (user is null || !BCrypt.Net.BCrypt.Verify(request.Password, user.Passwords))
            return (null, "Email hoac mat khau khong dung.");

        if (user.IsStatus == 0)
            return (null, "Tai khoan da bi khoa.");

        var roles = user.UserRoles.Select(ur => ur.Role).ToList();
        return (BuildAuthTokenResponse(user, roles, "Dang nhap thanh cong"), null);
    }

    public async Task<UserProfileData?> GetMeAsync(string userId)
    {
        var user = await db.Users
            .Include(u => u.AvatarPersona)
            .Include(u => u.UserRoles).ThenInclude(ur => ur.Role)
            .FirstOrDefaultAsync(u => u.UserId == userId);

        if (user is null) return null;

        var roles = user.UserRoles.Select(ur => new RoleDto(ur.Role.RoleId, ur.Role.RoleName)).ToList();
        return new UserProfileData(MapUserDto(user), roles);
    }

    public async Task<List<RoleDto>> GetMyRolesAsync(string userId)
    {
        return await db.UserRoles
            .Where(ur => ur.UserId == userId)
            .Include(ur => ur.Role)
            .Select(ur => new RoleDto(ur.Role.RoleId, ur.Role.RoleName))
            .ToListAsync();
    }

    public async Task<(UserProfileData? Profile, string? Error)> UpdateAvatarAsync(
        string userId, string? displayName, string? avatarUrl, int? isAnonymous)
    {
        var user = await db.Users
            .Include(u => u.AvatarPersona)
            .Include(u => u.UserRoles).ThenInclude(ur => ur.Role)
            .FirstOrDefaultAsync(u => u.UserId == userId);

        if (user is null)
            return (null, "Nguoi dung khong ton tai.");

        var avatar = user.AvatarPersona;
        if (avatar is null)
        {
            avatar = new AvatarPersona
            {
                UserId = user.UserId,
                DisplayName = string.IsNullOrWhiteSpace(displayName) ? user.FullName : displayName.Trim(),
                IsAnonymous = isAnonymous ?? 1
            };
            db.AvatarPersonas.Add(avatar);
            user.AvatarPersona = avatar;
        }

        if (!string.IsNullOrWhiteSpace(displayName))
            avatar.DisplayName = displayName.Trim();

        if (!string.IsNullOrWhiteSpace(avatarUrl))
            avatar.AvatarUrl = avatarUrl.Trim();

        if (isAnonymous is not null)
            avatar.IsAnonymous = isAnonymous.Value;

        await db.SaveChangesAsync();

        var roles = user.UserRoles.Select(ur => new RoleDto(ur.Role.RoleId, ur.Role.RoleName)).ToList();
        return (new UserProfileData(MapUserDto(user), roles), null);
    }

    public async Task<(ApplicationDto? Application, string? Error)> CreateCreatorUpgradeRequestAsync(
        string userId, CreatorUpgradeRequestCreateDto request)
    {
        var isMentor = await db.UserRoles
            .AnyAsync(ur => ur.UserId == userId && ur.RoleId == RoleCodes.MentorId);

        if (!isMentor)
            return (null, "Chi Mentor moi co the gui yeu cau nang cap Creator.");

        var hasPending = await db.CreatorUpgradeRequests
            .AnyAsync(r => r.UserId == userId && r.Status == CommonStatus.Pending);

        if (hasPending)
            return (null, "Ban da co yeu cau dang cho xet duyet.");

        var upgradeRequest = new CreatorUpgradeRequest
        {
            UpgradeRequestId = NewId("CU"),
            UserId = userId,
            TotalTeachingMinutes = request.TotalTeachingMinutes,
            AverageRating = request.AverageRating,
            LearnerCount = request.LearnerCount,
            Status = CommonStatus.Pending
        };

        db.CreatorUpgradeRequests.Add(upgradeRequest);
        await db.SaveChangesAsync();

        return (MapApplication(upgradeRequest, RoleCodes.Creator), null);
    }

    private AuthTokenResponse BuildAuthTokenResponse(User user, IEnumerable<Role> roles, string message)
    {
        var roleDtos = roles.Select(r => new RoleDto(r.RoleId, r.RoleName)).ToList();
        var tokenRoles = roles.Select(ToAuthorizationRole);
        var token = jwtService.CreateToken(user, tokenRoles);

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
        new(user.UserId, 
            !string.IsNullOrWhiteSpace(user.AvatarPersona?.DisplayName) ? user.AvatarPersona.DisplayName : user.FullName, 
            user.PhoneNumber, user.Email,
            user.AvatarPersona?.AvatarUrl, user.IsStatus, user.CreatedAt);

    private static ApplicationDto MapApplication(MentorApplication app, string type) =>
        new(app.ApplicationId, app.UserId, type, app.Status, app.RejectReason, app.SubmittedAt);

    private static ApplicationDto MapApplication(CreatorUpgradeRequest req, string type) =>
        new(req.UpgradeRequestId, req.UserId, type, req.Status, req.RejectReason, req.SubmittedAt);

    private static string ToAuthorizationRole(Role role) => role.RoleId switch
    {
        RoleCodes.AdminId => RoleCodes.Admin,
        RoleCodes.LearnerId => RoleCodes.Learner,
        RoleCodes.MentorId => RoleCodes.Mentor,
        RoleCodes.CreatorId => RoleCodes.Creator,
        _ => role.RoleName
    };

    private static string NewId(string prefix) => $"{prefix}{Guid.NewGuid():N}"[..Math.Min(prefix.Length + 32, 50)];
}
