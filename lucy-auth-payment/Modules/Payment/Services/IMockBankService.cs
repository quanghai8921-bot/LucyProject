namespace lucy_auth_payment.Modules.Payment.Services
{
    public interface IMockBankService
    {
        string? LookupAccountName(string bankCode, string accountNumber);
    }
}
