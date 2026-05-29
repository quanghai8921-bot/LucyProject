using Lucy.Payment.Api.Data;
using Lucy.Payment.Api.Entities;

namespace Lucy.Payment.Api.Services;

public sealed class DonationService(PaymentDbContext dbContext)
{
    public Donation CreateDonation(Guid fromUserId, Guid toUserId, decimal amount)
    {
        var donation = new Donation
        {
            FromUserId = fromUserId,
            ToUserId = toUserId,
            Amount = amount
        };

        dbContext.Donations.Add(donation);
        return donation;
    }
}
