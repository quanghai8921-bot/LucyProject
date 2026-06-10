namespace lucy_auth_payment.Modules.Payment.DTOs
{
    public class DepositRequest
    {
        public decimal Amount { get; set; }
        public string? PaymentProvider { get; set; }
        public string? ExternalTransactionCode { get; set; }
    }
}
