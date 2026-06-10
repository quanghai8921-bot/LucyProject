namespace lucy_auth_payment.Modules.Payment.DTOs
{
    public class TransferRequest
    {
        public string? ToUserId { get; set; }
        public decimal Amount { get; set; }
        public string TransferType { get; set; } = null!; // Donate, BuyPodcast, PayLive
        public string? RefId { get; set; }
        public string? MessageText { get; set; }
    }
}
