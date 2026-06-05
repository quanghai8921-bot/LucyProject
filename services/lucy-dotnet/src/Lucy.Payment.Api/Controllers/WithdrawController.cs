using Lucy.Payment.Api.Services;
using Microsoft.AspNetCore.Mvc;

namespace Lucy.Payment.Api.Controllers;

[ApiController]
[Route("api/withdrawals")]
public sealed class WithdrawController(WithdrawService withdrawService) : ControllerBase
{
    [HttpPost]
    public IActionResult RequestWithdraw(Guid userId, decimal amount)
    {
        return Ok(withdrawService.CreateRequest(userId, amount));
    }
}
