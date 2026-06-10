using lucy_auth_payment.Modules.Payment.Models;
using Microsoft.EntityFrameworkCore;

namespace lucy_auth_payment.Data;

public class AppDbContext : DbContext
{
    public AppDbContext(DbContextOptions<AppDbContext> options) : base(options)
    {
    }

    public DbSet<Wallet> Wallets => Set<Wallet>();
    public DbSet<WalletTransaction> WalletTransactions => Set<WalletTransaction>();
    public DbSet<TopUpOrder> TopUpOrders => Set<TopUpOrder>();
    public DbSet<WithdrawRequestEntity> WithdrawRequests => Set<WithdrawRequestEntity>();
    public DbSet<Gift> Gifts => Set<Gift>();
    public DbSet<Donation> Donations => Set<Donation>();
    public DbSet<ContentPurchase> ContentPurchases => Set<ContentPurchase>();
    public DbSet<LiveAccessTicket> LiveAccessTickets => Set<LiveAccessTicket>();
    public DbSet<PaidContent> PaidContents => Set<PaidContent>();
    public DbSet<Room> Rooms => Set<Room>();
    public DbSet<UserRole> UserRoles => Set<UserRole>();
    public DbSet<PaymentUser> Users => Set<PaymentUser>();
    public DbSet<PaymentSetting> PaymentSettings => Set<PaymentSetting>();
    public DbSet<Notification> Notifications => Set<Notification>();

    public async Task EnsureAdminWalletExistsAsync()
    {
        if (await Wallets.AnyAsync(wallet => wallet.WalletId == "W-ADMIN-001"))
        {
            return;
        }

        if (!await Users.AnyAsync(user => user.UserId == "Uadmin"))
        {
            return;
        }

        Wallets.Add(new Wallet
        {
            WalletId = "W-ADMIN-001",
            UserId = "Uadmin",
            Balance = 0,
            CurrencyCode = "XU",
            WalletStatus = "ACTIVE",
            CreatedAt = DateTime.Now
        });
        await SaveChangesAsync();
    }

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        modelBuilder.Entity<Wallet>(entity =>
        {
            entity.ToTable("Wallets");
            entity.HasKey(e => e.WalletId);
            entity.Property(e => e.WalletId).HasMaxLength(50);
            entity.Property(e => e.UserId).HasMaxLength(50).IsRequired();
            entity.Property(e => e.Balance).HasColumnType("decimal(12,2)");
            entity.Property(e => e.CurrencyCode).HasMaxLength(10);
            entity.Property(e => e.WalletStatus).HasMaxLength(30);
        });

        modelBuilder.Entity<WalletTransaction>(entity =>
        {
            entity.ToTable("WalletTransactions");
            entity.HasKey(e => e.WalletTransactionId);
            entity.Property(e => e.Amount).HasColumnType("decimal(12,2)");
            entity.Property(e => e.BalanceBefore).HasColumnType("decimal(12,2)");
            entity.Property(e => e.BalanceAfter).HasColumnType("decimal(12,2)");
            entity.Property(e => e.WalletId).HasMaxLength(50);
            entity.Property(e => e.UserId).HasMaxLength(50);
            entity.Property(e => e.RelatedUserId).HasMaxLength(50);
            entity.Property(e => e.TransactionType).HasMaxLength(50);
            entity.Property(e => e.Direction).HasMaxLength(10);
            entity.Property(e => e.TransactionStatus).HasMaxLength(30);
        });

        modelBuilder.Entity<TopUpOrder>(entity =>
        {
            entity.ToTable("TopUpOrders");
            entity.HasKey(e => e.TopUpOrderId);
            entity.Property(e => e.Amount).HasColumnType("decimal(12,2)");
            entity.Property(e => e.OrderStatus).HasMaxLength(30);
        });

        modelBuilder.Entity<PaymentSetting>(entity =>
        {
            entity.ToTable("PaymentSettings");
            entity.HasKey(e => e.PaymentSettingId);
            entity.Property(e => e.PaymentSettingId).HasMaxLength(50);
            entity.Property(e => e.ProviderCode).HasMaxLength(50);
            entity.Property(e => e.ReceiverUserId).HasMaxLength(50);
            entity.Property(e => e.ReceiverName).HasMaxLength(100);
            entity.Property(e => e.ReceiverPhone).HasMaxLength(20);
            entity.Property(e => e.QrImageUrl).HasMaxLength(255);
            entity.Property(e => e.TransferContentTemplate).HasMaxLength(255);
        });

        modelBuilder.Entity<WithdrawRequestEntity>(entity =>
        {
            entity.ToTable("WithdrawRequests");
            entity.HasKey(e => e.WithdrawRequestId);
            entity.Property(e => e.Amount).HasColumnType("decimal(12,2)");
            entity.Property(e => e.FeePercent).HasColumnType("decimal(5,2)");
            entity.Property(e => e.FeeAmount).HasColumnType("decimal(12,2)");
            entity.Property(e => e.NetAmount).HasColumnType("decimal(12,2)");
            entity.Property(e => e.RequestStatus).HasMaxLength(30);
        });

        modelBuilder.Entity<Gift>(entity =>
        {
            entity.ToTable("Gifts");
            entity.HasKey(e => e.GiftId);
            entity.Property(e => e.PriceAmount).HasColumnType("decimal(12,2)");
        });

        modelBuilder.Entity<Donation>(entity =>
        {
            entity.ToTable("Donations");
            entity.HasKey(e => e.DonationId);
            entity.Property(e => e.Amount).HasColumnType("decimal(12,2)");
        });

        modelBuilder.Entity<ContentPurchase>(entity =>
        {
            entity.ToTable("ContentPurchases");
            entity.HasKey(e => e.PurchaseId);
            entity.Property(e => e.PriceAmount).HasColumnType("decimal(12,2)");
        });

        modelBuilder.Entity<LiveAccessTicket>(entity =>
        {
            entity.ToTable("LiveAccessTickets");
            entity.HasKey(e => e.TicketId);
        });

        modelBuilder.Entity<PaidContent>(entity =>
        {
            entity.ToTable("PaidContents");
            entity.HasKey(e => e.ContentId);
            entity.Property(e => e.PriceAmount).HasColumnType("decimal(12,2)");
        });

        modelBuilder.Entity<Room>(entity =>
        {
            entity.ToTable("Rooms");
            entity.HasKey(e => e.RoomId);
            entity.Property(e => e.PriceAmount).HasColumnType("decimal(18,2)");
        });

        modelBuilder.Entity<UserRole>(entity =>
        {
            entity.ToTable("UserRoles");
            entity.HasKey(e => new { e.UserId, e.RoleId });
        });

        modelBuilder.Entity<PaymentUser>(entity =>
        {
            entity.ToTable("Users");
            entity.HasKey(e => e.UserId);
            entity.Property(e => e.UserId).HasMaxLength(50);
        });

        modelBuilder.Entity<Notification>(entity =>
        {
            entity.ToTable("Notifications");
            entity.HasKey(e => e.NotificationId);
            entity.Property(e => e.NotificationId).HasMaxLength(50);
            entity.Property(e => e.UserId).HasMaxLength(50);
            entity.Property(e => e.Title).HasMaxLength(150);
            entity.Property(e => e.BodyText).HasMaxLength(255);
            entity.Property(e => e.NotificationType).HasMaxLength(50);
            entity.Property(e => e.RefType).HasMaxLength(50);
        });
    }
}
