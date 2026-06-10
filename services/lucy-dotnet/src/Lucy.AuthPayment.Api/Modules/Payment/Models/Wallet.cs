using System;

namespace lucy_auth_payment.Modules.Payment.Models
{
    public class Wallet
    {
        public string WalletId { get; set; } = null!;
        public string UserId { get; set; } = null!;
        public decimal Balance { get; set; }
        public string CurrencyCode { get; set; } = "XU";
        public string WalletStatus { get; set; } = "ACTIVE";
        public DateTime CreatedAt { get; set; } = DateTime.Now;
    }
}
