namespace lucy_auth_payment.Modules.Payment.Models;

public class Gift
{
    public Guid Id { get; set; }

    public string Name { get; set; } = string.Empty;

    public decimal Price { get; set; }
}
