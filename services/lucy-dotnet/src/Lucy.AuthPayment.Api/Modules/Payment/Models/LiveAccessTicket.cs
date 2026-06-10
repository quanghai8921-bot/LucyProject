namespace lucy_auth_payment.Modules.Payment.Models;

public class LiveAccessTicket
{
    public string TicketId { get; set; } = null!;
    public string RoomId { get; set; } = null!;
    public string UserId { get; set; } = null!;
    public string? PurchaseId { get; set; }
    public string TicketStatus { get; set; } = "ACTIVE";
    public DateTime CreatedAt { get; set; } = DateTime.Now;
}
