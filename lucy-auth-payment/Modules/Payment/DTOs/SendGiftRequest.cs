namespace lucy_auth_payment.Modules.Payment.DTOs
{
    public class SendGiftRequest
    {
        public string ToUserId { get; set; } = null!;
        public string GiftId { get; set; } = null!;
        public string? Message { get; set; }
        public bool IsReceiverContentCreator { get; set; }
    }
}
