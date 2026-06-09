using System.Threading.Tasks;
using lucy_auth_payment.Modules.Payment.DTOs;
using lucy_auth_payment.Modules.Payment.Services;
using Microsoft.AspNetCore.Mvc;

namespace lucy_auth_payment.Modules.Payment.Controllers
{
    [ApiController]
    [Route("api/admin/gifts")]
    // [Authorize(Roles = "Admin")] // TODO: Bỏ comment khi tích hợp xác thực Auth
    public class GiftAdminController : ControllerBase
    {
        private readonly IPaymentService _paymentService;

        public GiftAdminController(IPaymentService paymentService)
        {
            _paymentService = paymentService;
        }

        /// <summary>
        /// Xem danh sách tất cả quà tặng
        /// </summary>
        [HttpGet]
        public async Task<IActionResult> GetAllGifts()
        {
            var gifts = await _paymentService.GetAllGiftsAsync();
            return Ok(gifts);
        }

        /// <summary>
        /// Tạo mới quà tặng
        /// </summary>
        [HttpPost]
        public async Task<IActionResult> CreateGift([FromBody] CreateGiftAdminRequest request)
        {
            var gift = await _paymentService.CreateGiftAsync(request);
            return Ok(new { Message = "Tạo mới quà tặng thành công.", Data = gift });
        }

        /// <summary>
        /// Cập nhật quà tặng (giá, tên, ảnh)
        /// </summary>
        [HttpPut("{id}")]
        public async Task<IActionResult> UpdateGift(string id, [FromBody] UpdateGiftAdminRequest request)
        {
            var gift = await _paymentService.UpdateGiftAsync(id, request);
            if (gift == null)
            {
                return NotFound(new { Message = "Không tìm thấy quà tặng này." });
            }
            return Ok(new { Message = "Cập nhật quà tặng thành công.", Data = gift });
        }

        /// <summary>
        /// Xóa quà tặng
        /// </summary>
        [HttpDelete("{id}")]
        public async Task<IActionResult> DeleteGift(string id)
        {
            var result = await _paymentService.DeleteGiftAsync(id);
            if (!result)
            {
                return NotFound(new { Message = "Không tìm thấy quà tặng để xóa." });
            }
            return Ok(new { Message = "Đã xóa quà tặng." });
        }
    }
}
