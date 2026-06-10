namespace lucy_auth_payment.Modules.Payment.Models;

public class TopUpOrder
{
    public string TopUpOrderId { get; set; } = null!;
    public string UserId { get; set; } = null!;
    public string WalletId { get; set; } = null!;
    public decimal Amount { get; set; }
    public string? PaymentProvider { get; set; }
    public string? ExternalTransactionCode { get; set; }
    public string OrderStatus { get; set; } = "PENDING";
    public DateTime CreatedAt { get; set; } = DateTime.Now;
    public DateTime? PaidAt { get; set; }
}
