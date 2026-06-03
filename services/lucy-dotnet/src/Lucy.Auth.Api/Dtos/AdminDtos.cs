namespace Lucy.Auth.Api.Dtos;

public sealed record CreatorUpgradeRequestCreateDto(
    int TotalTeachingMinutes = 0,
    decimal? AverageRating = null,
    int LearnerCount = 0
);

public sealed record AdminDecisionRequest(string? Reason);
