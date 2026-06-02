namespace Lucy.Auth.Api.Dtos;

/// <summary>
/// Thông tin user trả về trong AuthTokenResponse và UserProfileResponse
/// </summary>
public sealed record UserDto(
    string UserId,
    string FullName,
    string? PhoneNumber,
    string Email,
    string? AvatarPersonaUrl,
    bool IsActive,
    DateTimeOffset CreatedAt
);

/// <summary>
/// Thông tin role trả về
/// </summary>
public sealed record RoleDto(
    string RoleCode,
    string RoleName
);

/// <summary>
/// Data bên trong AuthTokenResponse
/// </summary>
public sealed record AuthTokenData(
    string AccessToken,
    string TokenType,
    UserDto User,
    IReadOnlyList<RoleDto> Roles
);

/// <summary>
/// AuthTokenResponse (khớp với OpenAPI schema AuthTokenResponse)
/// </summary>
public sealed record AuthTokenResponse(
    bool Success,
    string Message,
    AuthTokenData Data
);

/// <summary>
/// UserProfileResponse
/// </summary>
public sealed record UserProfileData(
    UserDto User,
    IReadOnlyList<RoleDto> Roles
);

/// <summary>
/// ApplicationResponse data
/// </summary>
public sealed record ApplicationDto(
    string ApplicationId,
    string UserId,
    string Type,
    string Status,
    string? RejectReason,
    DateTimeOffset SubmittedAt
);
