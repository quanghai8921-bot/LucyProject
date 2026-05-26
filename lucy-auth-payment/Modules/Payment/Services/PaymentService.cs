using lucy_auth_payment.Common;
using lucy_auth_payment.Modules.Payment.DTOs;

namespace lucy_auth_payment.Modules.Payment.Services;

public class PaymentService
{
    public BaseResponse<object> CreatePayment(CreatePaymentRequest request)
    {
        return new BaseResponse<object>
        {
            Message = "Create payment endpoint is ready.",
            Data = new { PaymentId = Guid.NewGuid(), request.UserId, request.Amount, request.Currency }
        };
    }

    public BaseResponse<object> CreateGift(CreateGiftRequest request)
    {
        return new BaseResponse<object>
        {
            Message = "Create gift endpoint is ready.",
            Data = new { GiftTransactionId = Guid.NewGuid(), request.SenderUserId, request.ReceiverUserId, request.GiftId }
        };
    }
}
