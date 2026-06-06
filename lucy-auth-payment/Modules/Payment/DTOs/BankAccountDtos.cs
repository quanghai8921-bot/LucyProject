namespace lucy_auth_payment.Modules.Payment.DTOs
{
    public class CreateBankAccountRequest
    {
        public string BankCode { get; set; } = null!;
        public string BankName { get; set; } = null!;
        public string AccountNumber { get; set; } = null!;
        public string AccountName { get; set; } = null!;
        public bool IsDefault { get; set; } = false;
    }

    public class LookupAccountRequest
    {
        public string BankCode { get; set; } = null!;
        public string AccountNumber { get; set; } = null!;
    }
}
