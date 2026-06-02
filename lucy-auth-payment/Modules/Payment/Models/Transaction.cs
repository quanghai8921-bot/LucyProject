using System;

namespace lucy_auth_payment.Modules.Payment.Models
{
    public class Transaction
    {
        public string TransactionId { get; set; } = null!;
        public string WalletId { get; set; } = null!;
        public decimal Amount { get; set; }
        public string TransactionType { get; set; } = null!; // Deposit, Withdraw, Donate, PayLive, BuyPodcast
        public string Status { get; set; } = "Pending"; // Pending, Success, Failed
        public DateTime CreatedAt { get; set; } = DateTime.Now;
        public decimal Fee { get; set; }

        // Navigation Property
        public Wallet Wallet { get; set; } = null!;
    }
}
