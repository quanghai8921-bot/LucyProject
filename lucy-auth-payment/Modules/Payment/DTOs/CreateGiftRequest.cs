namespace lucy_auth_payment.Modules.Payment.DTOs;

public class CreateGiftRequest
{
    public Guid SenderUserId { get; set; }

    public Guid ReceiverUserId { get; set; }

    public Guid GiftId { get; set; }
}
