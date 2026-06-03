namespace Lucy.Auth.Api.Dtos;

public sealed record UserDto(
    string UserId,
    string FullName,
    string PhoneNumber,
    string Email,
    string? AvatarUrl,
    int IsStatus,
    DateTime CreatedAt
);

public sealed record AdminUserDto(
    string UserId,
    string FullName,
    string PhoneNumber,
    string Email,
    string? AvatarUrl,
    int IsStatus,
    DateTime CreatedAt,
    IReadOnlyList<RoleDto> Roles
);

public sealed record RoleDto(
    string RoleId,
    string RoleName
);

public sealed record AuthTokenData(
    string AccessToken,
    string TokenType,
    UserDto User,
    IReadOnlyList<RoleDto> Roles
);

public sealed record AuthTokenResponse(
    bool Success,
    string Message,
    AuthTokenData Data
);

public sealed record UserProfileData(
    UserDto User,
    IReadOnlyList<RoleDto> Roles
);

public sealed record ApplicationDto(
    string ApplicationId,
    string UserId,
    string Type,
    string Status,
    string? RejectReason,
    DateTime SubmittedAt
);
