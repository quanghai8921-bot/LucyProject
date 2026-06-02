using System.Threading.Tasks;
using lucy_auth_payment.Modules.Payment.Models;

namespace lucy_auth_payment.Modules.Payment.Services
{
    public interface IPaymentService
    {
        Task<Wallet?> GetWalletByUserIdAsync(string userId);
        Task<bool> DepositAsync(string userId, decimal amount);
        Task<bool> TransferMoneyAsync(string fromUserId, string toUserId, decimal amount, string transferType);
        Task<bool> WithdrawAsync(string userId, decimal amount);
        Task<bool> ApproveWithdrawAsync(string transactionId);
        Task<bool> RejectWithdrawAsync(string transactionId);
    }
}
