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
    }
}
