namespace lucy_auth_payment.Modules.Payment.Models;

public class PaidContent
{
    public string ContentId { get; set; } = null!;
    public string CreatorUserId { get; set; } = null!;
    public string? RoomId { get; set; }
    public string? RecordingId { get; set; }
    public string ContentType { get; set; } = null!;
    public string Title { get; set; } = null!;
    public string? DescriptionText { get; set; }
    public string? ThumbnailUrl { get; set; }
    public string? AudioUrl { get; set; }
    public decimal PriceAmount { get; set; }
    public string ContentStatus { get; set; } = "DRAFT";
    public DateTime? PublishedAt { get; set; }
}
