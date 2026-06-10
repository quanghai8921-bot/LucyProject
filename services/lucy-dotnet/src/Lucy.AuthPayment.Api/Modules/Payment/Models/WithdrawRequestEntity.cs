namespace lucy_auth_payment.Modules.Payment.Models;

public class WithdrawRequestEntity
{
    public string WithdrawRequestId { get; set; } = null!;
    public string UserId { get; set; } = null!;
    public string WalletId { get; set; } = null!;
    public decimal Amount { get; set; }
    public decimal FeePercent { get; set; }
    public decimal FeeAmount { get; set; }
    public decimal NetAmount { get; set; }
    public string BankName { get; set; } = null!;
    public string BankAccountNumber { get; set; } = null!;
    public string BankAccountName { get; set; } = null!;
    public string RequestStatus { get; set; } = "PENDING";
    public string? RejectReason { get; set; }
    public DateTime RequestedAt { get; set; } = DateTime.Now;
    public DateTime? ReviewedAt { get; set; }
}
