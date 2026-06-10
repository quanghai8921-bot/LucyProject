namespace lucy_auth_payment.Modules.Payment.Models;

public class WalletTransaction
{
    public string WalletTransactionId { get; set; } = null!;
    public string WalletId { get; set; } = null!;
    public string UserId { get; set; } = null!;
    public string? RelatedUserId { get; set; }
    public string TransactionType { get; set; } = null!;
    public string Direction { get; set; } = null!;
    public decimal Amount { get; set; }
    public decimal BalanceBefore { get; set; }
    public decimal BalanceAfter { get; set; }
    public string? RelatedRefType { get; set; }
    public string? RelatedRefId { get; set; }
    public string? DescriptionText { get; set; }
    public string TransactionStatus { get; set; } = "SUCCESS";
    public DateTime CreatedAt { get; set; } = DateTime.Now;
}
