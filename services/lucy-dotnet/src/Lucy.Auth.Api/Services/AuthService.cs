using Lucy.Auth.Api.Data;
using Lucy.Auth.Api.Dtos;
using Lucy.Auth.Api.Entities;

namespace Lucy.Auth.Api.Services;

public sealed class AuthService(AuthDbContext dbContext, JwtService jwtService)
{
    public AuthResponse Register(RegisterRequest request)
    {
        var user = new User
        {
            Email = request.Email,
            PasswordHash = request.Password,
            DisplayName = request.DisplayName
        };

        dbContext.Users.Add(user);

        return new AuthResponse(user.Id, user.Email, user.DisplayName, jwtService.CreateToken(user));
    }

    public AuthResponse? Login(LoginRequest request)
    {
        var user = dbContext.Users.FirstOrDefault(x =>
            string.Equals(x.Email, request.Email, StringComparison.OrdinalIgnoreCase)
            && x.PasswordHash == request.Password);

        return user is null
            ? null
            : new AuthResponse(user.Id, user.Email, user.DisplayName, jwtService.CreateToken(user));
    }
}
