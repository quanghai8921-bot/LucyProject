using Lucy.Auth.Api.Entities;

namespace Lucy.Auth.Api.Services;

public sealed class JwtService
{
    public string CreateToken(User user)
    {
        return Convert.ToBase64String(Guid.NewGuid().ToByteArray());
    }
}
