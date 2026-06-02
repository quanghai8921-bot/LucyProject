using System;

namespace lucy_auth_payment.Modules.Payment.Models
{
    public class Wallet
    {
        public string WalletId { get; set; } = null!;
        public string UserId { get; set; } = null!;
        public decimal Balance { get; set; }
        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
        public DateTime UpdatedAt { get; set; } = DateTime.UtcNow;
    }
}
