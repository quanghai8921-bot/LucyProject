using Lucy.Payment.Api.Services;
using Microsoft.AspNetCore.Mvc;

namespace Lucy.Payment.Api.Controllers;

[ApiController]
[Route("api/top-ups")]
public sealed class TopUpController(TopUpService topUpService) : ControllerBase
{
    [HttpPost]
    public IActionResult CreateTopUp(Guid userId, decimal amount)
    {
        return Ok(topUpService.CreateOrder(userId, amount));
    }
}
