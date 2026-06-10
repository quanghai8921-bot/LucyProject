namespace lucy_auth_payment.Modules.Payment.Models;

public class PaymentSetting
{
    public string PaymentSettingId { get; set; } = null!;
    public string ProviderCode { get; set; } = null!;
    public string ReceiverUserId { get; set; } = null!;
    public string ReceiverName { get; set; } = null!;
    public string ReceiverPhone { get; set; } = null!;
    public string? QrImageUrl { get; set; }
    public string TransferContentTemplate { get; set; } = "LUCY NAP TIEN {ORDER_CODE}";
    public int IsActive { get; set; } = 1;
    public DateTime CreatedAt { get; set; } = DateTime.Now;
    public DateTime? UpdatedAt { get; set; }
}
