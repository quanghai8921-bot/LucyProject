using System.Threading.Tasks;
using lucy_auth_payment.Common;
using lucy_auth_payment.Modules.Payment.DTOs;
using lucy_auth_payment.Modules.Payment.Services;
using Microsoft.AspNetCore.Mvc;

namespace lucy_auth_payment.Modules.Payment.Controllers
{
    [ApiController]
    [Route("api/payment")]
    public class PaymentController : ControllerBase
    {
        private readonly IPaymentService _paymentService;

        public PaymentController(IPaymentService paymentService)
        {
            _paymentService = paymentService;
        }

        // Lấy User ID hiện tại từ Header X-User-Id, mặc định là U-LINH-001 nếu không có
        private string GetCurrentUserId()
        {
            if (Request.Headers.TryGetValue("X-User-Id", out var userId))
            {
                return userId.ToString();
            }
            return "U-LINH-001";
        }

        /// <summary>
        /// Xem thông tin ví tiền của người dùng
        /// </summary>
        [HttpGet("wallet")]
        public async Task<IActionResult> GetWallet()
        {
            var userId = GetCurrentUserId();
            var wallet = await _paymentService.GetWalletByUserIdAsync(userId);
            if (wallet == null)
            {
                return NotFound(new { Message = $"Không tìm thấy ví cho người dùng {userId}." });
            }
            return Ok(wallet);
        }

        /// <summary>
        /// Nạp tiền (cộng xu) vào ví
        /// </summary>
        [HttpPost("deposit")]
        public async Task<IActionResult> Deposit([FromBody] DepositRequest request)
        {
            var userId = GetCurrentUserId();
            var result = await _paymentService.DepositAsync(userId, request.Amount);
            if (!result)
            {
                return BadRequest(new { Message = "Nạp tiền thất bại. Vui lòng kiểm tra lại số tiền hợp lệ." });
            }
            return Ok(new { Message = $"Nạp tiền thành công {request.Amount} xu vào ví của user {userId}." });
        }

        /// <summary>
        /// Chuyển tiền (donate, thanh toán, chuyển xu) sang ví khác
        /// </summary>
        [HttpPost("transfer")]
        public async Task<IActionResult> Transfer([FromBody] TransferRequest request)
        {
            var fromUserId = GetCurrentUserId();
            var result = await _paymentService.TransferMoneyAsync(fromUserId, request.ToUserId, request.Amount, request.TransferType);
            if (!result)
            {
                return BadRequest(new { Message = "Chuyển tiền thất bại. Hãy đảm bảo số dư ví đủ và thông tin tài khoản hợp lệ." });
            }
            return Ok(new { Message = $"Đã chuyển thành công {request.Amount} xu từ {fromUserId} đến {request.ToUserId} (Loại: {request.TransferType})." });
        }

        /// <summary>
        /// Đăng ký rút tiền mặt (khởi tạo giao dịch Withdraw ở trạng thái Pending)
        /// </summary>
        [HttpPost("withdraw")]
        public async Task<IActionResult> Withdraw([FromBody] DepositRequest request) // Tận dụng DepositRequest vì chỉ cần truyền Amount
        {
            var userId = GetCurrentUserId();
            var result = await _paymentService.WithdrawAsync(userId, request.Amount);
            if (!result)
            {
                return BadRequest(new { Message = "Yêu cầu rút tiền thất bại. Hãy kiểm tra xem số dư ví có đủ không." });
            }
            return Ok(new { Message = $"Yêu cầu rút {request.Amount} xu thành công. Giao dịch đang chờ Admin duyệt." });
        }

        /// <summary>
        /// Admin duyệt yêu cầu rút tiền
        /// </summary>
        [HttpPost("admin/withdraw/approve/{transactionId}")]
        public async Task<IActionResult> ApproveWithdraw(string transactionId)
        {
            var result = await _paymentService.ApproveWithdrawAsync(transactionId);
            if (!result)
            {
                return BadRequest(new { Message = "Phê duyệt rút tiền thất bại. Giao dịch không tồn tại hoặc không ở trạng thái Pending." });
            }
            return Ok(new { Message = "Đã phê duyệt yêu cầu rút tiền thành công." });
        }

        /// <summary>
        /// Admin từ chối yêu cầu rút tiền (hoàn xu lại ví cho user)
        /// </summary>
        [HttpPost("admin/withdraw/reject/{transactionId}")]
        public async Task<IActionResult> RejectWithdraw(string transactionId)
        {
            var result = await _paymentService.RejectWithdrawAsync(transactionId);
            if (!result)
            {
                return BadRequest(new { Message = "Từ chối rút tiền thất bại. Giao dịch không tồn tại hoặc không ở trạng thái Pending." });
            }
            return Ok(new { Message = "Từ chối yêu cầu rút tiền thành công. Tiền ảo đã được hoàn trả về ví người dùng." });
        }
    }
}
