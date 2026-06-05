using Lucy.Payment.Api.Entities;

namespace Lucy.Payment.Api.Data;

public sealed class PaymentDbContext
{
    public PaymentDbContext(IConfiguration configuration)
    {
        DefaultConnection = configuration.GetConnectionString("DefaultConnection")
            ?? throw new InvalidOperationException("Connection string 'DefaultConnection' is missing.");
    }

    public string DefaultConnection { get; }

    public List<Wallet> Wallets { get; } = [];
    public List<WalletTransaction> WalletTransactions { get; } = [];
    public List<TopUpOrder> TopUpOrders { get; } = [];
    public List<WithdrawRequest> WithdrawRequests { get; } = [];
    public List<Gift> Gifts { get; } = [];
    public List<Donation> Donations { get; } = [];
    public List<GiftTransaction> GiftTransactions { get; } = [];
    public List<ContentPurchase> ContentPurchases { get; } = [];
    public List<LiveAccessTicket> LiveAccessTickets { get; } = [];
}
