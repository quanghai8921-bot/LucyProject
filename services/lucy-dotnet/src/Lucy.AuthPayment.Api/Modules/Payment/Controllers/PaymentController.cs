using lucy_auth_payment.Modules.Payment.DTOs;
using lucy_auth_payment.Modules.Payment.Services;
using Microsoft.AspNetCore.Mvc;

namespace lucy_auth_payment.Modules.Payment.Controllers;

[ApiController]
[Route("api/payment")]
public class PaymentController : ControllerBase
{
    private readonly IPaymentService _paymentService;

    public PaymentController(IPaymentService paymentService)
    {
        _paymentService = paymentService;
    }

    [HttpGet("wallet")]
    public async Task<IActionResult> GetWallet()
    {
        return Ok(await _paymentService.GetOrCreateWalletAsync(GetCurrentUserId()));
    }

    [HttpGet("transactions")]
    public async Task<IActionResult> GetTransactions()
    {
        return Ok(await _paymentService.GetTransactionsAsync(GetCurrentUserId()));
    }

    [HttpPost("deposit")]
    public async Task<IActionResult> Deposit([FromBody] DepositRequest request)
    {
        return Ok(await _paymentService.DepositAsync(GetCurrentUserId(), request));
    }

    [HttpPost("purchase/content")]
    public async Task<IActionResult> PurchaseContent([FromBody] PurchaseContentRequest request)
    {
        return Ok(await _paymentService.PurchaseContentAsync(GetCurrentUserId(), request));
    }

    [HttpPost("purchase/live")]
    public async Task<IActionResult> PurchaseLive([FromBody] PurchaseLiveRequest request)
    {
        return Ok(await _paymentService.PurchaseLiveAsync(GetCurrentUserId(), request));
    }

    [HttpPost("donate")]
    public async Task<IActionResult> Donate([FromBody] DonateRequest request)
    {
        return Ok(await _paymentService.DonateAsync(GetCurrentUserId(), request));
    }

    [HttpPost("transfer")]
    public async Task<IActionResult> Transfer([FromBody] TransferRequest request)
    {
        var type = request.TransferType.Trim().ToLowerInvariant();
        if (type == "buypodcast")
        {
            return Ok(await _paymentService.PurchaseContentAsync(GetCurrentUserId(), new PurchaseContentRequest
            {
                ContentId = request.RefId ?? request.ToUserId ?? string.Empty
            }));
        }
        if (type == "paylive")
        {
            return Ok(await _paymentService.PurchaseLiveAsync(GetCurrentUserId(), new PurchaseLiveRequest
            {
                RoomId = request.RefId ?? request.ToUserId ?? string.Empty
            }));
        }
        if (string.IsNullOrWhiteSpace(request.ToUserId))
        {
            throw new InvalidOperationException("ToUserId is required for donate transfer.");
        }
        return Ok(await _paymentService.DonateAsync(GetCurrentUserId(), new DonateRequest
        {
            ToUserId = request.ToUserId,
            Amount = request.Amount,
            RoomId = request.RefId,
            MessageText = request.MessageText
        }));
    }

    [HttpPost("withdraw")]
    public async Task<IActionResult> Withdraw([FromBody] WithdrawRequest request)
    {
        return Ok(await _paymentService.WithdrawAsync(GetCurrentUserId(), request));
    }

    [HttpGet("admin/settings/momo")]
    public async Task<IActionResult> GetMomoSetting()
    {
        EnsureAdmin();
        return Ok(await _paymentService.GetMomoSettingAsync());
    }

    [HttpPost("admin/settings/momo")]
    public async Task<IActionResult> SaveMomoSetting([FromBody] SavePaymentSettingRequest request)
    {
        EnsureAdmin();
        return Ok(await _paymentService.SaveMomoSettingAsync(request));
    }

    [HttpPost("admin/settings/momo/qr")]
    public async Task<IActionResult> UploadMomoQr([FromForm] IFormFile file)
    {
        EnsureAdmin();
        return Ok(await _paymentService.UploadMomoQrAsync(file));
    }

    [HttpGet("admin/topup-orders")]
    public async Task<IActionResult> GetTopUpOrders([FromQuery] string? status)
    {
        EnsureAdmin();
        return Ok(await _paymentService.GetTopUpOrdersAsync(status));
    }

    [HttpPost("admin/topup-orders/{topUpOrderId}/approve")]
    public async Task<IActionResult> ApproveTopUpOrder(string topUpOrderId)
    {
        EnsureAdmin();
        return Ok(await _paymentService.ApproveTopUpOrderAsync(topUpOrderId));
    }

    [HttpPost("admin/topup-orders/{topUpOrderId}/reject")]
    public async Task<IActionResult> RejectTopUpOrder(string topUpOrderId, [FromBody] RejectTopUpRequest? request)
    {
        EnsureAdmin();
        return Ok(await _paymentService.RejectTopUpOrderAsync(topUpOrderId, request?.Reason));
    }

    [HttpGet("admin/withdraw-requests")]
    public async Task<IActionResult> GetWithdrawRequests([FromQuery] string? status)
    {
        EnsureAdmin();
        return Ok(await _paymentService.GetWithdrawRequestsAsync(status));
    }

    [HttpPost("admin/withdraw/approve/{withdrawRequestId}")]
    public async Task<IActionResult> ApproveWithdraw(string withdrawRequestId)
    {
        EnsureAdmin();
        return Ok(await _paymentService.ApproveWithdrawAsync(withdrawRequestId));
    }

    [HttpPost("admin/withdraw/reject/{withdrawRequestId}")]
    public async Task<IActionResult> RejectWithdraw(string withdrawRequestId, [FromBody] RejectWithdrawRequest? request)
    {
        EnsureAdmin();
        return Ok(await _paymentService.RejectWithdrawAsync(withdrawRequestId, request?.RejectReason));
    }

    private string GetCurrentUserId()
    {
        if (Request.Headers.TryGetValue("X-User-Id", out var userId) && !string.IsNullOrWhiteSpace(userId))
        {
            return userId.ToString();
        }
        throw new InvalidOperationException("Missing X-User-Id header.");
    }

    private void EnsureAdmin()
    {
        if (!string.Equals(GetCurrentUserId(), "Uadmin", StringComparison.OrdinalIgnoreCase))
        {
            throw new InvalidOperationException("Admin permission is required.");
        }
    }
}
