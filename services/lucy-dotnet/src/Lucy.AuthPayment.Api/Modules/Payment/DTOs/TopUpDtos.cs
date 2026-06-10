using lucy_auth_payment.Modules.Payment.Models;

namespace lucy_auth_payment.Modules.Payment.DTOs;

public class TopUpOrderResponse
{
    public string TopUpOrderId { get; set; } = null!;
    public string UserId { get; set; } = null!;
    public decimal Amount { get; set; }
    public decimal Coins { get; set; }
    public string? PaymentProvider { get; set; }
    public string OrderStatus { get; set; } = null!;
    public DateTime CreatedAt { get; set; }
    public DateTime? PaidAt { get; set; }
    public string? ReceiverName { get; set; }
    public string? ReceiverPhone { get; set; }
    public string? QrImageUrl { get; set; }
    public string? TransferContent { get; set; }

    public static TopUpOrderResponse From(TopUpOrder order, decimal coins, PaymentSetting? setting)
    {
        return new TopUpOrderResponse
        {
            TopUpOrderId = order.TopUpOrderId,
            UserId = order.UserId,
            Amount = order.Amount,
            Coins = coins,
            PaymentProvider = order.PaymentProvider,
            OrderStatus = order.OrderStatus,
            CreatedAt = order.CreatedAt,
            PaidAt = order.PaidAt,
            ReceiverName = setting?.ReceiverName,
            ReceiverPhone = setting?.ReceiverPhone,
            QrImageUrl = setting?.QrImageUrl,
            TransferContent = setting?.TransferContentTemplate.Replace("{ORDER_CODE}", order.TopUpOrderId)
        };
    }
}

public class SavePaymentSettingRequest
{
    public string ReceiverName { get; set; } = null!;
    public string ReceiverPhone { get; set; } = null!;
    public string? QrImageUrl { get; set; }
    public string? TransferContentTemplate { get; set; }
    public int IsActive { get; set; } = 1;
}

public class RejectTopUpRequest
{
    public string? Reason { get; set; }
}
