namespace lucy_auth_payment.Modules.Payment.Models;

public class Notification
{
    public string NotificationId { get; set; } = null!;
    public string UserId { get; set; } = null!;
    public string Title { get; set; } = null!;
    public string BodyText { get; set; } = null!;
    public string NotificationType { get; set; } = null!;
    public string? RefType { get; set; }
    public int IsRead { get; set; }
    public DateTime CreatedAt { get; set; } = DateTime.Now;
}
