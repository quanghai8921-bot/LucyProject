using Lucy.Payment.Api.Services;
using Microsoft.AspNetCore.Mvc;

namespace Lucy.Payment.Api.Controllers;

[ApiController]
[Route("api/gifts")]
public sealed class GiftController(GiftService giftService) : ControllerBase
{
    [HttpGet]
    public IActionResult GetGifts()
    {
        return Ok(giftService.GetGifts());
    }
}
