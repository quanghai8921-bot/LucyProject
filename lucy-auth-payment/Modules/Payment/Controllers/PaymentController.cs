using lucy_auth_payment.Common;
using lucy_auth_payment.Modules.Payment.DTOs;
using lucy_auth_payment.Modules.Payment.Services;
using Microsoft.AspNetCore.Mvc;

namespace lucy_auth_payment.Modules.Payment.Controllers;

[ApiController]
[Route(Constants.PaymentRoute)]
public class PaymentController : ControllerBase
{
    private readonly PaymentService _paymentService;

    public PaymentController(PaymentService paymentService)
    {
        _paymentService = paymentService;
    }

    [HttpPost]
    public IActionResult CreatePayment(CreatePaymentRequest request)
    {
        return Ok(_paymentService.CreatePayment(request));
    }

    [HttpPost("gift")]
    public IActionResult CreateGift(CreateGiftRequest request)
    {
        return Ok(_paymentService.CreateGift(request));
    }
}
