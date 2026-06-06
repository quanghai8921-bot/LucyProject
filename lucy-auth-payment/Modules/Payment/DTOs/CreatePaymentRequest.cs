namespace lucy_auth_payment.Modules.Payment.DTOs;

public class CreatePaymentRequest
{
    public Guid UserId { get; set; }

    public decimal Amount { get; set; }

    public string Currency { get; set; } = "VND";
}
