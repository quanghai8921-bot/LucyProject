using Lucy.Payment.Api.Services;
using Microsoft.AspNetCore.Mvc;

namespace Lucy.Payment.Api.Controllers;

[ApiController]
[Route("api/wallets")]
public sealed class WalletController(WalletService walletService) : ControllerBase
{
    [HttpGet("{userId:guid}")]
    public IActionResult GetWallet(Guid userId)
    {
        return Ok(walletService.GetOrCreateWallet(userId));
    }
}
