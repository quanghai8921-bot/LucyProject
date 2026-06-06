namespace lucy_auth_payment.Modules.Auth.DTOs;

public class RegisterRequest
{
    public string Email { get; set; } = string.Empty;

    public string Password { get; set; } = string.Empty;

    public string FullName { get; set; } = string.Empty;
}
