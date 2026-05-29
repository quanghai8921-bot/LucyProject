using Lucy.Payment.Api.Services;
using Microsoft.AspNetCore.Mvc;

namespace Lucy.Payment.Api.Controllers;

[ApiController]
[Route("api/donations")]
public sealed class DonationController(DonationService donationService) : ControllerBase
{
    [HttpPost]
    public IActionResult Donate(Guid fromUserId, Guid toUserId, decimal amount)
    {
        return Ok(donationService.CreateDonation(fromUserId, toUserId, amount));
    }
}
