namespace lucy_auth_payment.Modules.Payment.Models;

public class Payment
{
    public Guid Id { get; set; }

    public Guid UserId { get; set; }

    public decimal Amount { get; set; }

    public string Currency { get; set; } = "VND";

    public string Status { get; set; } = string.Empty;
}
