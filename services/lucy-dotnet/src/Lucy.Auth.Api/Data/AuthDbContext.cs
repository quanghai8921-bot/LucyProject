using Lucy.Auth.Api.Entities;
using Lucy.Shared.Constants;
using Microsoft.EntityFrameworkCore;

namespace Lucy.Auth.Api.Data;

public sealed class AuthDbContext(DbContextOptions<AuthDbContext> options) : DbContext(options)
{
    public DbSet<Language> Languages => Set<Language>();
    public DbSet<User> Users => Set<User>();
    public DbSet<Role> Roles => Set<Role>();
    public DbSet<UserRole> UserRoles => Set<UserRole>();
    public DbSet<AvatarPersona> AvatarPersonas => Set<AvatarPersona>();
    public DbSet<MentorApplication> MentorApplications => Set<MentorApplication>();
    public DbSet<CreatorUpgradeRequest> CreatorUpgradeRequests => Set<CreatorUpgradeRequest>();

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        base.OnModelCreating(modelBuilder);

        modelBuilder.Entity<Language>(e =>
        {
            e.ToTable("Languages");
            e.HasKey(l => l.LanguageId);
            e.Property(l => l.LanguageId).HasMaxLength(50);
            e.Property(l => l.LanguageName).HasMaxLength(50).IsRequired();
        });

        modelBuilder.Entity<User>(e =>
        {
            e.ToTable("Users");
            e.HasKey(u => u.UserId);
            e.HasIndex(u => u.PhoneNumber).IsUnique();
            e.HasIndex(u => u.Email).IsUnique();
            e.Property(u => u.UserId).HasMaxLength(50);
            e.Property(u => u.FullName).HasMaxLength(50).IsRequired();
            e.Property(u => u.PhoneNumber).HasMaxLength(10).IsRequired();
            e.Property(u => u.Email).HasMaxLength(50).IsRequired();
            e.Property(u => u.Passwords).HasMaxLength(255).IsRequired();
            e.Property(u => u.CreatedAt).HasColumnType("datetime").HasDefaultValueSql("CURRENT_TIMESTAMP");
            e.Property(u => u.IsStatus).IsRequired();
        });

        modelBuilder.Entity<Role>(e =>
        {
            e.ToTable("Roles");
            e.HasKey(r => r.RoleId);
            e.Property(r => r.RoleId).HasMaxLength(50);
            e.Property(r => r.RoleName).HasMaxLength(50).IsRequired();
            e.Property(r => r.IsActive).HasColumnType("tinyint").HasDefaultValue((byte)1);

            e.HasData(
                new Role { RoleId = RoleCodes.AdminId, RoleName = RoleCodes.AdminName, IsActive = 1 },
                new Role { RoleId = RoleCodes.LearnerId, RoleName = RoleCodes.LearnerName, IsActive = 1 },
                new Role { RoleId = RoleCodes.MentorId, RoleName = RoleCodes.MentorName, IsActive = 1 },
                new Role { RoleId = RoleCodes.CreatorId, RoleName = RoleCodes.CreatorName, IsActive = 1 }
            );
        });

        modelBuilder.Entity<UserRole>(e =>
        {
            e.ToTable("UserRoles");
            e.HasKey(ur => new { ur.UserId, ur.RoleId });
            e.Property(ur => ur.UserId).HasMaxLength(50);
            e.Property(ur => ur.RoleId).HasMaxLength(50);
            e.Property(ur => ur.AssignedDate).HasColumnType("datetime").HasDefaultValueSql("CURRENT_TIMESTAMP");

            e.HasOne(ur => ur.User)
                .WithMany(u => u.UserRoles)
                .HasForeignKey(ur => ur.UserId)
                .OnDelete(DeleteBehavior.Cascade);

            e.HasOne(ur => ur.Role)
                .WithMany(r => r.UserRoles)
                .HasForeignKey(ur => ur.RoleId)
                .OnDelete(DeleteBehavior.Cascade);
        });

        modelBuilder.Entity<AvatarPersona>(e =>
        {
            e.ToTable("AvatarPersonas");
            e.HasKey(a => a.UserId);
            e.Property(a => a.UserId).HasMaxLength(50);
            e.Property(a => a.DisplayName).HasMaxLength(50).IsRequired();
            e.Property(a => a.AvatarUrl).HasMaxLength(255);
            e.Property(a => a.IsAnonymous).HasDefaultValue(1).IsRequired();
            e.Property(a => a.CreatedAt).HasColumnType("datetime").HasDefaultValueSql("CURRENT_TIMESTAMP");

            e.HasOne(a => a.User)
                .WithOne(u => u.AvatarPersona)
                .HasForeignKey<AvatarPersona>(a => a.UserId)
                .OnDelete(DeleteBehavior.Cascade);
        });

        modelBuilder.Entity<MentorApplication>(e =>
        {
            e.ToTable("MentorApplications");
            e.HasKey(m => m.ApplicationId);
            e.Property(m => m.ApplicationId).HasMaxLength(50);
            e.Property(m => m.UserId).HasMaxLength(50).IsRequired();
            e.Property(m => m.LanguageId).HasMaxLength(50);
            e.Property(m => m.CertificateUrl).HasMaxLength(255);
            e.Property(m => m.Status).HasMaxLength(30).HasDefaultValue(CommonStatus.Pending).IsRequired();
            e.Property(m => m.RejectReason).HasMaxLength(255);
            e.Property(m => m.SubmittedAt).HasColumnType("datetime").HasDefaultValueSql("CURRENT_TIMESTAMP");

            e.HasOne(m => m.User)
                .WithMany(u => u.MentorApplications)
                .HasForeignKey(m => m.UserId)
                .OnDelete(DeleteBehavior.Cascade);

            e.HasOne(m => m.Language)
                .WithMany(l => l.MentorApplications)
                .HasForeignKey(m => m.LanguageId)
                .OnDelete(DeleteBehavior.Restrict);
        });

        modelBuilder.Entity<CreatorUpgradeRequest>(e =>
        {
            e.ToTable("CreatorUpgradeRequests");
            e.HasKey(c => c.UpgradeRequestId);
            e.Property(c => c.UpgradeRequestId).HasMaxLength(50);
            e.Property(c => c.UserId).HasMaxLength(50).IsRequired();
            e.Property(c => c.TotalTeachingMinutes).HasDefaultValue(0).IsRequired();
            e.Property(c => c.AverageRating).HasColumnType("decimal(3,2)");
            e.Property(c => c.LearnerCount).HasDefaultValue(0).IsRequired();
            e.Property(c => c.Status).HasMaxLength(30).HasDefaultValue(CommonStatus.Pending).IsRequired();
            e.Property(c => c.RejectReason).HasMaxLength(255);
            e.Property(c => c.SubmittedAt).HasColumnType("datetime").HasDefaultValueSql("CURRENT_TIMESTAMP");

            e.HasOne(c => c.User)
                .WithMany(u => u.CreatorUpgradeRequests)
                .HasForeignKey(c => c.UserId)
                .OnDelete(DeleteBehavior.Cascade);
        });
    }
}
