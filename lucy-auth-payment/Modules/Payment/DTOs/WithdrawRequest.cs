namespace lucy_auth_payment.Modules.Payment.DTOs
{
    public class WithdrawRequest
    {
        public decimal Amount { get; set; }
        public string BankAccountId { get; set; } = null!;
    }
}
