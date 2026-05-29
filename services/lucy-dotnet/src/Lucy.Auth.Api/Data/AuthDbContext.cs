using Lucy.Auth.Api.Entities;

namespace Lucy.Auth.Api.Data;

public sealed class AuthDbContext
{
    public AuthDbContext(IConfiguration configuration)
    {
        DefaultConnection = configuration.GetConnectionString("DefaultConnection")
            ?? throw new InvalidOperationException("Connection string 'DefaultConnection' is missing.");
    }

    public string DefaultConnection { get; }

    public List<User> Users { get; } = [];
    public List<Role> Roles { get; } = [];
    public List<UserRole> UserRoles { get; } = [];
    public List<MentorApplication> MentorApplications { get; } = [];
    public List<CreatorUpgradeRequest> CreatorUpgradeRequests { get; } = [];
}
