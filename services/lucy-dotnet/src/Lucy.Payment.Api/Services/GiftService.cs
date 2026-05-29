using Lucy.Payment.Api.Data;
using Lucy.Payment.Api.Entities;

namespace Lucy.Payment.Api.Services;

public sealed class GiftService(PaymentDbContext dbContext)
{
    public IReadOnlyCollection<Gift> GetGifts()
    {
        return dbContext.Gifts;
    }
}
