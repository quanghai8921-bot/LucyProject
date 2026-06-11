using lucy_auth_payment.Modules.Payment.DTOs;
using lucy_auth_payment.Modules.Payment.Models;

namespace lucy_auth_payment.Modules.Payment.Services;

public interface IPaymentService
{
    Task<Wallet> GetOrCreateWalletAsync(string userId);
    Task<List<WalletTransaction>> GetTransactionsAsync(string userId);
    Task<TopUpOrderResponse> DepositAsync(string userId, DepositRequest request);
    Task<PaymentSetting?> GetMomoSettingAsync();
    Task<PaymentSetting> SaveMomoSettingAsync(SavePaymentSettingRequest request);
    Task<PaymentSetting> UploadMomoQrAsync(IFormFile file);
    Task<List<TopUpOrderResponse>> GetTopUpOrdersAsync(string? status);
    Task<TopUpOrderResponse> ApproveTopUpOrderAsync(string topUpOrderId);
    Task<TopUpOrderResponse> RejectTopUpOrderAsync(string topUpOrderId, string? reason);
    Task<ContentPurchase> PurchaseContentAsync(string buyerUserId, PurchaseContentRequest request);
    Task<LiveAccessTicket> PurchaseLiveAsync(string buyerUserId, PurchaseLiveRequest request);
    Task<Donation> DonateAsync(string fromUserId, DonateRequest request);
    Task<List<WithdrawRequestEntity>> GetWithdrawRequestsAsync(string? status);
    Task<WithdrawRequestEntity> WithdrawAsync(string userId, WithdrawRequest request);
    Task<WithdrawRequestEntity> ApproveWithdrawAsync(string withdrawRequestId);
    Task<WithdrawRequestEntity> RejectWithdrawAsync(string withdrawRequestId, string? rejectReason);
    Task<List<Gift>> GetGiftsAsync();
}
