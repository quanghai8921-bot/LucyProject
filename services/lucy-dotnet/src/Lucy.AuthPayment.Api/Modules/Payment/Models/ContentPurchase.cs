namespace lucy_auth_payment.Modules.Payment.Models;

public class ContentPurchase
{
    public string PurchaseId { get; set; } = null!;
    public string ContentId { get; set; } = null!;
    public string BuyerUserId { get; set; } = null!;
    public string SellerUserId { get; set; } = null!;
    public decimal PriceAmount { get; set; }
    public string? BuyerWalletTransactionId { get; set; }
    public string? SellerWalletTransactionId { get; set; }
    public DateTime PurchasedAt { get; set; } = DateTime.Now;
}
