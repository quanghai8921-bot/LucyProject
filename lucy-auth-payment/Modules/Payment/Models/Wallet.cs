namespace lucy_auth_payment.Modules.Payment.Models;

public class Wallet
{
    public Guid Id { get; set; }

    public Guid UserId { get; set; }

    public decimal Balance { get; set; }
}
