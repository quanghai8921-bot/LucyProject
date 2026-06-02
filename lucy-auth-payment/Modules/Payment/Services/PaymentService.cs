using System;
using System.Threading.Tasks;
using lucy_auth_payment.Data;
using lucy_auth_payment.Modules.Payment.Models;
using Microsoft.EntityFrameworkCore;

namespace lucy_auth_payment.Modules.Payment.Services
{
    public class PaymentService : IPaymentService
    {
        private readonly AppDbContext _context;

        public PaymentService(AppDbContext context)
        {
            _context = context;
        }

        public async Task<Wallet?> GetWalletByUserIdAsync(string userId)
        {
            return await _context.Wallets.FirstOrDefaultAsync(w => w.UserId == userId);
        }

        public async Task<bool> DepositAsync(string userId, decimal amount)
        {
            if (amount <= 0) return false;

            using var transaction = await _context.Database.BeginTransactionAsync();
            try
            {
                var wallet = await _context.Wallets.FirstOrDefaultAsync(w => w.UserId == userId);
                if (wallet == null)
                {
                    wallet = new Wallet
                    {
                        WalletId = Guid.NewGuid().ToString(),
                        UserId = userId,
                        Balance = 0,
                        CreatedAt = DateTime.Now,
                        UpdatedAt = DateTime.Now
                    };
                    _context.Wallets.Add(wallet);
                }

                wallet.Balance += amount;
                wallet.UpdatedAt = DateTime.Now;

                var tx = new Transaction
                {
                    TransactionId = Guid.NewGuid().ToString(),
                    WalletId = wallet.WalletId,
                    Amount = amount,
                    TransactionType = "Deposit",
                    Status = "Success",
                    CreatedAt = DateTime.Now,
                    Fee = 0
                };
                _context.Transactions.Add(tx);

                await _context.SaveChangesAsync();
                await transaction.CommitAsync();
                return true;
            }
            catch
            {
                await transaction.RollbackAsync();
                return false;
            }
        }

        public async Task<bool> TransferMoneyAsync(string fromUserId, string toUserId, decimal amount, string transferType)
        {
            if (amount <= 0 || fromUserId == toUserId) return false;

            using var transaction = await _context.Database.BeginTransactionAsync();
            try
            {
                // 1. Kiểm tra ví người gửi
                var senderWallet = await _context.Wallets.FirstOrDefaultAsync(w => w.UserId == fromUserId);
                if (senderWallet == null || senderWallet.Balance < amount) return false;

                // 2. Tự động kiểm tra cấp bậc Super của người nhận qua mã User (chứa chữ "SUPER")
                bool isSuper = toUserId.Contains("SUPER", StringComparison.OrdinalIgnoreCase);

                // 3. Phân bổ hoa hồng (Commission Split) dựa trên loại giao dịch
                decimal feePercentage = 0;
                string typeLower = transferType.ToLower();

                if (typeLower == "buypodcast")
                {
                    feePercentage = 0.10m; // Creator 90%, Admin 10%
                }
                else if (typeLower == "paylive")
                {
                    feePercentage = isSuper ? 0.10m : 0.15m; // Super Mentor 10%, Thường 15%
                }
                else if (typeLower == "donate")
                {
                    feePercentage = isSuper ? 0.10m : 0.20m; // Super Mentor 10%, Thường 20%
                }

                decimal feeAmount = amount * feePercentage;
                decimal netAmount = amount - feeAmount;

                // 4. Lấy hoặc tạo ví người nhận
                var receiverWallet = await _context.Wallets.FirstOrDefaultAsync(w => w.UserId == toUserId);
                if (receiverWallet == null)
                {
                    receiverWallet = new Wallet
                    {
                        WalletId = Guid.NewGuid().ToString(),
                        UserId = toUserId,
                        Balance = 0,
                        CreatedAt = DateTime.Now,
                        UpdatedAt = DateTime.Now
                    };
                    _context.Wallets.Add(receiverWallet);
                }

                // 5. Lấy hoặc tạo ví Admin để thu phí hoa hồng
                var adminWallet = await _context.Wallets.FirstOrDefaultAsync(w => w.WalletId == "W-ADMIN-001");
                if (adminWallet == null)
                {
                    adminWallet = new Wallet
                    {
                        WalletId = "W-ADMIN-001",
                        UserId = "U-ADMIN-001",
                        Balance = 0,
                        CreatedAt = DateTime.Now,
                        UpdatedAt = DateTime.Now
                    };
                    _context.Wallets.Add(adminWallet);
                }

                // 6. Thực hiện chuyển tiền
                senderWallet.Balance -= amount;
                senderWallet.UpdatedAt = DateTime.Now;

                receiverWallet.Balance += netAmount;
                receiverWallet.UpdatedAt = DateTime.Now;

                if (feeAmount > 0)
                {
                    adminWallet.Balance += feeAmount;
                    adminWallet.UpdatedAt = DateTime.Now;
                }

                // 7. Ghi nhận giao dịch của người gửi
                var senderTx = new Transaction
                {
                    TransactionId = Guid.NewGuid().ToString(),
                    WalletId = senderWallet.WalletId,
                    Amount = -amount,
                    TransactionType = transferType,
                    Status = "Success",
                    CreatedAt = DateTime.Now,
                    Fee = 0
                };
                _context.Transactions.Add(senderTx);

                // Ghi nhận giao dịch của người nhận
                var receiverTx = new Transaction
                {
                    TransactionId = Guid.NewGuid().ToString(),
                    WalletId = receiverWallet.WalletId,
                    Amount = netAmount,
                    TransactionType = transferType,
                    Status = "Success",
                    CreatedAt = DateTime.Now,
                    Fee = feeAmount
                };
                _context.Transactions.Add(receiverTx);

                // Ghi nhận giao dịch hoa hồng của Admin (nếu có)
                if (feeAmount > 0)
                {
                    var adminTx = new Transaction
                    {
                        TransactionId = Guid.NewGuid().ToString(),
                        WalletId = adminWallet.WalletId,
                        Amount = feeAmount,
                        TransactionType = "Commission",
                        Status = "Success",
                        CreatedAt = DateTime.Now,
                        Fee = 0
                    };
                    _context.Transactions.Add(adminTx);
                }

                await _context.SaveChangesAsync();
                await transaction.CommitAsync();
                return true;
            }
            catch
            {
                await transaction.RollbackAsync();
                return false;
            }
        }

        public async Task<bool> WithdrawAsync(string userId, decimal amount)
        {
            if (amount <= 0) return false;

            using var transaction = await _context.Database.BeginTransactionAsync();
            try
            {
                var wallet = await _context.Wallets.FirstOrDefaultAsync(w => w.UserId == userId);
                if (wallet == null || wallet.Balance < amount) return false;

                wallet.Balance -= amount;
                wallet.UpdatedAt = DateTime.Now;

                var tx = new Transaction
                {
                    TransactionId = Guid.NewGuid().ToString(),
                    WalletId = wallet.WalletId,
                    Amount = -amount, // Lưu số âm biểu thị tiền bị trừ/đóng băng
                    TransactionType = "Withdraw",
                    Status = "Pending", // Trạng thái ban đầu chờ duyệt
                    CreatedAt = DateTime.Now,
                    Fee = 0
                };
                _context.Transactions.Add(tx);

                await _context.SaveChangesAsync();
                await transaction.CommitAsync();
                return true;
            }
            catch
            {
                await transaction.RollbackAsync();
                return false;
            }
        }

        public async Task<bool> ApproveWithdrawAsync(string transactionId)
        {
            var tx = await _context.Transactions.FirstOrDefaultAsync(t => t.TransactionId == transactionId);
            if (tx == null || tx.TransactionType != "Withdraw" || tx.Status != "Pending")
            {
                return false;
            }

            tx.Status = "Success";
            await _context.SaveChangesAsync();
            return true;
        }

        public async Task<bool> RejectWithdrawAsync(string transactionId)
        {
            using var transaction = await _context.Database.BeginTransactionAsync();
            try
            {
                var tx = await _context.Transactions.FirstOrDefaultAsync(t => t.TransactionId == transactionId);
                if (tx == null || tx.TransactionType != "Withdraw" || tx.Status != "Pending")
                {
                    return false;
                }

                var wallet = await _context.Wallets.FirstOrDefaultAsync(w => w.WalletId == tx.WalletId);
                if (wallet == null) return false;

                // Hoàn lại số xu đã bị khóa (giá trị tx.Amount lưu âm nên chúng ta lấy trị tuyệt đối cộng lại)
                wallet.Balance += Math.Abs(tx.Amount);
                wallet.UpdatedAt = DateTime.Now;

                tx.Status = "Failed";

                await _context.SaveChangesAsync();
                await transaction.CommitAsync();
                return true;
            }
            catch
            {
                await transaction.RollbackAsync();
                return false;
            }
        }
    }
}
