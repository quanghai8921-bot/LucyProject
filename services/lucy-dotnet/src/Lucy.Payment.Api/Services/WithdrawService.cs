using Lucy.Payment.Api.Data;
using Lucy.Payment.Api.Entities;

namespace Lucy.Payment.Api.Services;

public sealed class WithdrawService(PaymentDbContext dbContext)
{
    public WithdrawRequest CreateRequest(Guid userId, decimal amount)
    {
        var request = new WithdrawRequest { UserId = userId, Amount = amount };
        dbContext.WithdrawRequests.Add(request);
        return request;
    }
}
