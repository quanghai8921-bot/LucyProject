using Microsoft.EntityFrameworkCore;
using lucy_auth_payment.Modules.Payment.Models;

namespace lucy_auth_payment.Data;

public class AppDbContext : DbContext
{
    public AppDbContext(DbContextOptions<AppDbContext> options) : base(options)
    {
    }

    public DbSet<Wallet> Wallets { get; set; } = null!;
    public DbSet<Transaction> Transactions { get; set; } = null!;
    public DbSet<UserBankAccount> UserBankAccounts { get; set; } = null!;
    public DbSet<Gift> Gifts { get; set; } = null!;

    public async Task EnsureAdminWalletExistsAsync()
    {
        var adminWallet = await Wallets.FindAsync("W-ADMIN-001");
        if (adminWallet == null)
        {
            Wallets.Add(new Wallet
            {
                WalletId = "W-ADMIN-001",
                UserId = "U-ADMIN-001",
                Balance = 0,
                CreatedAt = DateTime.UtcNow,
                UpdatedAt = DateTime.UtcNow
            });
            await SaveChangesAsync();
        }
    }

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        base.OnModelCreating(modelBuilder);

        modelBuilder.Entity<Wallet>(entity =>
        {
            entity.ToTable("Wallets");
            entity.HasKey(e => e.WalletId);
            entity.Property(e => e.WalletId).HasMaxLength(50);
            entity.Property(e => e.UserId).HasMaxLength(50).IsRequired();
            entity.Property(e => e.Balance).HasColumnType("decimal(18, 2)");
        });

        modelBuilder.Entity<Transaction>(entity =>
        {
            entity.ToTable("Transactions");
            entity.HasKey(e => e.TransactionId);
            entity.Property(e => e.TransactionId).HasMaxLength(50);
            entity.Property(e => e.WalletId).HasMaxLength(50).IsRequired();
            entity.Property(e => e.Amount).HasColumnType("decimal(18, 2)");
            entity.Property(e => e.TransactionType).HasMaxLength(50).IsRequired();
            entity.Property(e => e.Status).HasMaxLength(20).HasDefaultValue("Pending");
            entity.Property(e => e.Fee).HasColumnType("decimal(18, 2)").HasDefaultValue(0.0);

            entity.HasOne(d => d.Wallet)
                .WithMany()
                .HasForeignKey(d => d.WalletId)
                .OnDelete(DeleteBehavior.Cascade);

            entity.HasOne(d => d.RecipientBankAccount)
                .WithMany()
                .HasForeignKey(d => d.RecipientBankAccountId)
                .OnDelete(DeleteBehavior.SetNull);
        });

        modelBuilder.Entity<UserBankAccount>(entity =>
        {
            entity.ToTable("UserBankAccounts");
            entity.HasKey(e => e.Id);
            entity.Property(e => e.Id).HasMaxLength(50);
            entity.Property(e => e.UserId).HasMaxLength(50).IsRequired();
            entity.Property(e => e.BankCode).HasMaxLength(20).IsRequired();
            entity.Property(e => e.BankName).HasMaxLength(255);
            entity.Property(e => e.AccountNumber).HasMaxLength(50).IsRequired();
            entity.Property(e => e.AccountName).HasMaxLength(255).IsRequired();
        });

        modelBuilder.Entity<Gift>(entity =>
        {
            entity.ToTable("Gifts");
            entity.HasKey(e => e.Id);
            entity.Property(e => e.Name).HasMaxLength(255).IsRequired();
            entity.Property(e => e.Price).HasColumnType("decimal(18, 2)");
            entity.Property(e => e.ImageUrl).HasMaxLength(500);
            entity.Property(e => e.AnimationUrl).HasMaxLength(500);
            
            // Seed sample data
            entity.HasData(
                new Gift { Id = Guid.Parse("00000000-0000-0000-0000-000000000001"), Name = "Cây Bút Thần Kỳ", Price = 1 },
                new Gift { Id = Guid.Parse("00000000-0000-0000-0000-000000000002"), Name = "Cục Tẩy \"Xóa Deadline\"", Price = 2 },
                new Gift { Id = Guid.Parse("00000000-0000-0000-0000-000000000003"), Name = "Ly Cà Phê 24/7", Price = 5 },
                new Gift { Id = Guid.Parse("00000000-0000-0000-0000-000000000004"), Name = "Quyển Bí Kíp Tận Thế", Price = 10 },
                new Gift { Id = Guid.Parse("00000000-0000-0000-0000-000000000005"), Name = "Vòng Đèn Led Chống Cận", Price = 20 },
                new Gift { Id = Guid.Parse("00000000-0000-0000-0000-000000000006"), Name = "Bộ Não Thiên Tài", Price = 50 },
                new Gift { Id = Guid.Parse("00000000-0000-0000-0000-000000000007"), Name = "Chiếc Cúp Thủ Khoa", Price = 100 },
                new Gift { Id = Guid.Parse("00000000-0000-0000-0000-000000000008"), Name = "Vương Miện Học Bá", Price = 200 },
                new Gift { Id = Guid.Parse("00000000-0000-0000-0000-000000000009"), Name = "Tàu Vũ Trụ Vượt Vũ Môn", Price = 500 }
            );
        });
    }
}
