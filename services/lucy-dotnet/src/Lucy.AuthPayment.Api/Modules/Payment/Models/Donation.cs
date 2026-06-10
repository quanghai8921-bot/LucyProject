namespace lucy_auth_payment.Modules.Payment.Models;

public class Donation
{
    public string DonationId { get; set; } = null!;
    public string FromUserId { get; set; } = null!;
    public string ToUserId { get; set; } = null!;
    public string? RoomId { get; set; }
    public decimal Amount { get; set; }
    public string? MessageText { get; set; }
    public string? FromWalletTransactionId { get; set; }
    public string? ToWalletTransactionId { get; set; }
    public DateTime CreatedAt { get; set; } = DateTime.Now;
}
