namespace lucy_auth_payment.Modules.Payment.DTOs
{
    public class CreateGiftAdminRequest
    {
        public string Name { get; set; } = string.Empty;
        public decimal Price { get; set; }
        public string? ImageUrl { get; set; }
        public string? AnimationUrl { get; set; }
    }
}
