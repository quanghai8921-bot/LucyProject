using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using System.Text;
using Lucy.Auth.Api.Entities;
using Microsoft.IdentityModel.Tokens;

namespace Lucy.Auth.Api.Services;

public sealed class JwtService(IConfiguration configuration)
{
    private readonly string _secret = configuration["JwtSettings:SecretKey"]
        ?? throw new InvalidOperationException("JwtSettings:SecretKey is missing.");
    private readonly string _issuer = configuration["JwtSettings:Issuer"] ?? "lucy-auth";
    private readonly string _audience = configuration["JwtSettings:Audience"] ?? "lucy-client";
    private readonly int _expiryDays = int.TryParse(configuration["JwtSettings:ExpiryDays"], out var d) ? d : 7;

    public string CreateToken(User user, IEnumerable<string> roleCodes)
    {
        var key = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(_secret));
        var creds = new SigningCredentials(key, SecurityAlgorithms.HmacSha256);

        var claims = new List<Claim>
        {
            new(JwtRegisteredClaimNames.Sub, user.Id.ToString()),
            new(JwtRegisteredClaimNames.Email, user.Email),
            new(JwtRegisteredClaimNames.Name, user.FullName),
            new(JwtRegisteredClaimNames.Jti, Guid.NewGuid().ToString())
        };

        // Thêm từng role thành một claim riêng để [Authorize(Roles="...")] hoạt động
        foreach (var role in roleCodes)
            claims.Add(new Claim(ClaimTypes.Role, role));

        var token = new JwtSecurityToken(
            issuer: _issuer,
            audience: _audience,
            claims: claims,
            expires: DateTime.UtcNow.AddDays(_expiryDays),
            signingCredentials: creds
        );

        return new JwtSecurityTokenHandler().WriteToken(token);
    }

    public ClaimsPrincipal? ValidateToken(string token)
    {
        var key = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(_secret));
        var handler = new JwtSecurityTokenHandler();
        try
        {
            return handler.ValidateToken(token, new TokenValidationParameters
            {
                ValidateIssuer = true,
                ValidIssuer = _issuer,
                ValidateAudience = true,
                ValidAudience = _audience,
                ValidateIssuerSigningKey = true,
                IssuerSigningKey = key,
                ValidateLifetime = true,
                ClockSkew = TimeSpan.Zero
            }, out _);
        }
        catch
        {
            return null;
        }
    }
}
