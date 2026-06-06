namespace lucy_auth_payment.Modules.Payment.DTOs
{
    public class TransferRequest
    {
        public string ToUserId { get; set; } = null!;
        public decimal Amount { get; set; }
        public string TransferType { get; set; } = null!; // Donate, BuyPodcast, PayLive
    }
}
