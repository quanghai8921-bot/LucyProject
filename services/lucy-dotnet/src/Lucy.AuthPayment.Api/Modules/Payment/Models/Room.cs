namespace lucy_auth_payment.Modules.Payment.Models;

public class Room
{
    public string RoomId { get; set; } = null!;
    public string HostUserId { get; set; } = null!;
    public string HostRole { get; set; } = null!;
    public string? LevelId { get; set; }
    public string? LanguageId { get; set; }
    public string RoomTitle { get; set; } = null!;
    public string? RoomType { get; set; }
    public string? AccessType { get; set; }
    public decimal? PriceAmount { get; set; }
    public DateTime ScheduledStartAt { get; set; }
    public DateTime? StudyStartedAt { get; set; }
    public DateTime? EndedAt { get; set; }
    public string RoomStatus { get; set; } = null!;
    public int? MaxParticipants { get; set; }
    public DateTime CreatedAt { get; set; }
}
