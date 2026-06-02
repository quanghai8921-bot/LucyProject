using Lucy.Auth.Api.Entities;
using Lucy.Shared.Constants;
using Microsoft.EntityFrameworkCore;

namespace Lucy.Auth.Api.Data;

public sealed class AuthDbContext(DbContextOptions<AuthDbContext> options) : DbContext(options)
{
    public DbSet<User> Users => Set<User>();
    public DbSet<Role> Roles => Set<Role>();
    public DbSet<UserRole> UserRoles => Set<UserRole>();
    public DbSet<MentorApplication> MentorApplications => Set<MentorApplication>();
    public DbSet<CreatorUpgradeRequest> CreatorUpgradeRequests => Set<CreatorUpgradeRequest>();

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        base.OnModelCreating(modelBuilder);

        // ── User ──────────────────────────────────────────────
        modelBuilder.Entity<User>(e =>
        {
            e.HasKey(u => u.Id);
            e.HasIndex(u => u.Email).IsUnique();
            e.HasIndex(u => u.PhoneNumber).IsUnique();
            e.Property(u => u.FullName).HasMaxLength(200).IsRequired();
            e.Property(u => u.Email).HasMaxLength(256).IsRequired();
            e.Property(u => u.PhoneNumber).HasMaxLength(20);
            e.Property(u => u.PasswordHash).IsRequired();
            e.Property(u => u.AvatarPersonaUrl).HasMaxLength(500);
        });

        // ── Role ──────────────────────────────────────────────
        modelBuilder.Entity<Role>(e =>
        {
            e.HasKey(r => r.Id);
            e.HasIndex(r => r.Code).IsUnique();
            e.Property(r => r.Code).HasMaxLength(50).IsRequired();
            e.Property(r => r.Name).HasMaxLength(100).IsRequired();

            // Seed dữ liệu roles
            e.HasData(
                new Role { Id = new Guid("10000000-0000-0000-0000-000000000001"), Code = RoleCodes.Learner,  Name = "Lucy ẩn danh" },
                new Role { Id = new Guid("10000000-0000-0000-0000-000000000002"), Code = RoleCodes.Mentor,   Name = "Mentor" },
                new Role { Id = new Guid("10000000-0000-0000-0000-000000000003"), Code = RoleCodes.Creator,  Name = "Content Creator" },
                new Role { Id = new Guid("10000000-0000-0000-0000-000000000004"), Code = RoleCodes.Admin,    Name = "Quản trị viên" }
            );
        });

        // ── UserRole ──────────────────────────────────────────
        modelBuilder.Entity<UserRole>(e =>
        {
            e.HasKey(ur => new { ur.UserId, ur.RoleId });

            e.HasOne(ur => ur.User)
                .WithMany(u => u.UserRoles)
                .HasForeignKey(ur => ur.UserId)
                .OnDelete(DeleteBehavior.Cascade);

            e.HasOne(ur => ur.Role)
                .WithMany(r => r.UserRoles)
                .HasForeignKey(ur => ur.RoleId)
                .OnDelete(DeleteBehavior.Cascade);
        });

        // ── MentorApplication ─────────────────────────────────
        modelBuilder.Entity<MentorApplication>(e =>
        {
            e.HasKey(m => m.Id);
            e.Property(m => m.Status).HasMaxLength(20).IsRequired();
            e.Property(m => m.LanguageId).HasMaxLength(50);
            e.Property(m => m.CertificateFileUrl).HasMaxLength(500);
            e.Property(m => m.RejectReason).HasMaxLength(500);

            e.HasOne(m => m.User)
                .WithMany(u => u.MentorApplications)
                .HasForeignKey(m => m.UserId)
                .OnDelete(DeleteBehavior.Cascade);
        });

        // ── CreatorUpgradeRequest ─────────────────────────────
        modelBuilder.Entity<CreatorUpgradeRequest>(e =>
        {
            e.HasKey(c => c.Id);
            e.Property(c => c.Status).HasMaxLength(20).IsRequired();
            e.Property(c => c.Reason).HasMaxLength(1000);
            e.Property(c => c.EvidenceUrl).HasMaxLength(500);
            e.Property(c => c.RejectReason).HasMaxLength(500);

            e.HasOne(c => c.User)
                .WithMany(u => u.CreatorUpgradeRequests)
                .HasForeignKey(c => c.UserId)
                .OnDelete(DeleteBehavior.Cascade);
        });
    }
}
