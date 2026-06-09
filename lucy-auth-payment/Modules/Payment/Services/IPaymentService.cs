using System.Threading.Tasks;
using lucy_auth_payment.Modules.Payment.Models;

namespace lucy_auth_payment.Modules.Payment.Services
{
    public interface IPaymentService
    {
        Task<Wallet?> GetWalletByUserIdAsync(string userId);
        Task<bool> DepositAsync(string userId, decimal amount);
        Task<bool> TransferMoneyAsync(string fromUserId, string toUserId, decimal amount, string transferType, bool isReceiverContentCreator);
        Task<bool> WithdrawAsync(string userId, lucy_auth_payment.Modules.Payment.DTOs.WithdrawRequest request);
        Task<bool> ApproveWithdrawAsync(string transactionId);
        Task<bool> RejectWithdrawAsync(string transactionId);
        Task<bool> SendGiftAsync(string fromUserId, string toUserId, string giftId, string? message, bool isReceiverContentCreator);

        // CRUD Gift
        Task<System.Collections.Generic.List<Gift>> GetAllGiftsAsync();
        Task<Gift?> CreateGiftAsync(lucy_auth_payment.Modules.Payment.DTOs.CreateGiftAdminRequest request);
        Task<Gift?> UpdateGiftAsync(string giftId, lucy_auth_payment.Modules.Payment.DTOs.UpdateGiftAdminRequest request);
        Task<bool> DeleteGiftAsync(string giftId);

        // CRUD Bank Account
        Task<UserBankAccount?> AddBankAccountAsync(string userId, lucy_auth_payment.Modules.Payment.DTOs.CreateBankAccountRequest request);
        Task<System.Collections.Generic.List<UserBankAccount>> GetUserBankAccountsAsync(string userId);
        Task<bool> DeleteBankAccountAsync(string userId, string bankAccountId);
    }
}
