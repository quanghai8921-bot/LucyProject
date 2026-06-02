namespace Lucy.Auth.Api.Dtos;

/// <summary>
/// Mentor gửi yêu cầu nâng cấp lên Content Creator
/// </summary>
public sealed record CreatorUpgradeRequestCreateDto(
    string? Reason,
    string? EvidenceUrl
);

/// <summary>
/// Admin duyệt/từ chối - kèm lý do
/// </summary>
public sealed record AdminDecisionRequest(string? Reason);
