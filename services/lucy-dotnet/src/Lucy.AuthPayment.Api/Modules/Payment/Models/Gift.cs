namespace lucy_auth_payment.Modules.Payment.Models;

public class Gift
{
    public string GiftId { get; set; } = null!;

    public string GiftName { get; set; } = string.Empty;

    public decimal PriceAmount { get; set; }

    public string? IconUrl { get; set; }

    public bool IsActive { get; set; } = true;

    public DateTime CreatedAt { get; set; } = DateTime.Now;
}
