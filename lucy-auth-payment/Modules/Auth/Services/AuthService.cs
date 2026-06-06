using lucy_auth_payment.Common;
using lucy_auth_payment.Modules.Auth.DTOs;

namespace lucy_auth_payment.Modules.Auth.Services;

public class AuthService
{
    public BaseResponse<object> Login(LoginRequest request)
    {
        return new BaseResponse<object>
        {
            Message = "Login endpoint is ready.",
            Data = new { request.Email }
        };
    }

    public BaseResponse<object> Register(RegisterRequest request)
    {
        return new BaseResponse<object>
        {
            Message = "Register endpoint is ready.",
            Data = new { request.Email, request.FullName }
        };
    }
}
