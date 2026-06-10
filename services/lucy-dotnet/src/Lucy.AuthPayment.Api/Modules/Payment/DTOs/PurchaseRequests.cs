namespace lucy_auth_payment.Modules.Payment.DTOs;

public class PurchaseContentRequest
{
    public string ContentId { get; set; } = null!;
}

public class PurchaseLiveRequest
{
    public string RoomId { get; set; } = null!;
}

public class DonateRequest
{
    public string ToUserId { get; set; } = null!;
    public string? RoomId { get; set; }
    public decimal Amount { get; set; }
    public string? MessageText { get; set; }
}

public class RejectWithdrawRequest
{
    public string? RejectReason { get; set; }
}
