using Lucy.Payment.Api.Data;
using Lucy.Payment.Api.Entities;

namespace Lucy.Payment.Api.Services;

public sealed class WalletService(PaymentDbContext dbContext)
{
    public Wallet GetOrCreateWallet(Guid userId)
    {
        var wallet = dbContext.Wallets.FirstOrDefault(x => x.UserId == userId);
        if (wallet is not null)
        {
            return wallet;
        }

        wallet = new Wallet { UserId = userId };
        dbContext.Wallets.Add(wallet);
        return wallet;
    }
}
