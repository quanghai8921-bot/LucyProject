using Lucy.Payment.Api.Data;
using Lucy.Payment.Api.Entities;

namespace Lucy.Payment.Api.Services;

public sealed class TopUpService(PaymentDbContext dbContext)
{
    public TopUpOrder CreateOrder(Guid userId, decimal amount)
    {
        var order = new TopUpOrder { UserId = userId, Amount = amount };
        dbContext.TopUpOrders.Add(order);
        return order;
    }
}
