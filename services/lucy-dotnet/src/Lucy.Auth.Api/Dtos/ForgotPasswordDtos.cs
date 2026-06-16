using System.ComponentModel.DataAnnotations;

namespace Lucy.Auth.Api.Dtos;

public sealed record ForgotPasswordRequest(
    [Required][EmailAddress] string Email
);

public sealed record VerifyOtpRequest(
    [Required][EmailAddress] string Email,
    [Required] string Otp
);

public sealed record ResetPasswordRequest(
    [Required][EmailAddress] string Email,
    [Required] string Otp,
    [Required][MinLength(6)] string NewPassword
);
