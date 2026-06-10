namespace lucy_auth_payment.Modules.Payment.DTOs
{
    public class WithdrawRequest
    {
        public decimal Amount { get; set; }
        public decimal? FeePercent { get; set; }
        public string BankName { get; set; } = null!;
        public string BankAccountNumber { get; set; } = null!;
        public string BankAccountName { get; set; } = null!;
    }
}
