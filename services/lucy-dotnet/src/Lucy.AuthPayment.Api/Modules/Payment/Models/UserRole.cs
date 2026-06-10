namespace lucy_auth_payment.Modules.Payment.Models;

public class UserRole
{
    public string UserId { get; set; } = null!;
    public string RoleId { get; set; } = null!;
    public DateTime? AssignedDate { get; set; }
}
