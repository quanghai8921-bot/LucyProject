using Lucy.Payment.Api.Data;
using Lucy.Payment.Api.Entities;
using Microsoft.AspNetCore.Mvc;

namespace Lucy.Payment.Api.Controllers;

[ApiController]
[Route("api/purchases")]
public sealed class PurchaseController(PaymentDbContext dbContext) : ControllerBase
{
    [HttpPost("content")]
    public IActionResult PurchaseContent(Guid buyerUserId, Guid contentId, decimal amount)
    {
        var purchase = new ContentPurchase
        {
            BuyerUserId = buyerUserId,
            ContentId = contentId,
            Amount = amount
        };

        dbContext.ContentPurchases.Add(purchase);
        return Ok(purchase);
    }
}
