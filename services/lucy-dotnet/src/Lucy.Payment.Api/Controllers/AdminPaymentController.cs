using Lucy.Payment.Api.Data;
using Microsoft.AspNetCore.Mvc;

namespace Lucy.Payment.Api.Controllers;

[ApiController]
[Route("api/admin/payments")]
public sealed class AdminPaymentController(PaymentDbContext dbContext) : ControllerBase
{
    [HttpGet("withdrawals")]
    public IActionResult GetWithdrawRequests()
    {
        return Ok(dbContext.WithdrawRequests);
    }

    [HttpGet("transactions")]
    public IActionResult GetTransactions()
    {
        return Ok(dbContext.WalletTransactions);
    }
}
