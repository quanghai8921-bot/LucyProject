using System;
using System.Threading.Tasks;
using lucy_auth_payment.Data;
using lucy_auth_payment.Modules.Payment.Models;
using lucy_auth_payment.Modules.Payment.DTOs;
using Microsoft.EntityFrameworkCore;
using System.Collections.Generic;
using System.Linq;

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

        public async Task<bool> TransferMoneyAsync(string fromUserId, string toUserId, decimal amount, string transferType, bool isReceiverContentCreator)
        {
            if (amount <= 0 || fromUserId == toUserId) return false;

            using var transaction = await _context.Database.BeginTransactionAsync();
            try
            {
                // 1. Kiểm tra ví người gửi
                var senderWallet = await _context.Wallets.FirstOrDefaultAsync(w => w.UserId == fromUserId);
                if (senderWallet == null || senderWallet.Balance < amount) return false;

                // 2. Phân bổ hoa hồng (Commission Split) dựa trên loại giao dịch
                decimal feePercentage = 0;
                string typeLower = transferType.ToLower();

                if (typeLower == "buypodcast")
                {
                    // Chặn nếu người nhận không phải Content Creator
                    if (!isReceiverContentCreator) return false;
                    
                    feePercentage = 0.10m; // Content Creator 90%, Admin 10%
                }
                else if (typeLower == "paylive")
                {
                    feePercentage = isReceiverContentCreator ? 0.10m : 0.15m; // Content Creator 10%, Mentor Thường 15%
                }
                else if (typeLower == "donate")
                {
                    feePercentage = isReceiverContentCreator ? 0.10m : 0.20m; // Content Creator 10%, Mentor Thường 20%
                }
                else
                {
                    // Loại giao dịch không được phép
                    return false;
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

        public async Task<bool> SendGiftAsync(string fromUserId, string toUserId, string giftId, string? message, bool isReceiverContentCreator)
        {
            if (fromUserId == toUserId) return false;

            if (!Guid.TryParse(giftId, out Guid parsedGiftId))
                return false;

            using var transaction = await _context.Database.BeginTransactionAsync();
            try
            {
                var gift = await _context.Gifts.FirstOrDefaultAsync(g => g.Id == parsedGiftId);
                if (gift == null || gift.Price <= 0) return false;

                var amount = gift.Price;

                // 1. Kiểm tra ví người gửi
                var senderWallet = await _context.Wallets.FirstOrDefaultAsync(w => w.UserId == fromUserId);
                if (senderWallet == null || senderWallet.Balance < amount) return false;

                // 2. Phân bổ hoa hồng cho Donate (Gift): Content Creator 10%, Thường 20%
                decimal feePercentage = isReceiverContentCreator ? 0.10m : 0.20m;
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

                // 5. Lấy hoặc tạo ví Admin
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

                // 6. Thực hiện chuyển tiền (Xu)
                senderWallet.Balance -= amount;
                senderWallet.UpdatedAt = DateTime.Now;

                receiverWallet.Balance += netAmount;
                receiverWallet.UpdatedAt = DateTime.Now;

                if (feeAmount > 0)
                {
                    adminWallet.Balance += feeAmount;
                    adminWallet.UpdatedAt = DateTime.Now;
                }

                string note = $"Tặng quà: {gift.Name}" + (string.IsNullOrEmpty(message) ? "" : $" - Lời nhắn: {message}");

                // 7. Ghi nhận giao dịch
                var senderTx = new Transaction
                {
                    TransactionId = Guid.NewGuid().ToString(),
                    WalletId = senderWallet.WalletId,
                    Amount = -amount,
                    TransactionType = "SendGift",
                    Status = "Success",
                    CreatedAt = DateTime.Now,
                    Fee = 0,
                    Note = note
                };
                _context.Transactions.Add(senderTx);

                var receiverTx = new Transaction
                {
                    TransactionId = Guid.NewGuid().ToString(),
                    WalletId = receiverWallet.WalletId,
                    Amount = netAmount,
                    TransactionType = "ReceiveGift",
                    Status = "Success",
                    CreatedAt = DateTime.Now,
                    Fee = feeAmount,
                    Note = note
                };
                _context.Transactions.Add(receiverTx);

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
                        Fee = 0,
                        Note = $"Phí hoa hồng từ quà {gift.Name}"
                    };
                    _context.Transactions.Add(adminTx);
                }

                await _context.SaveChangesAsync();
                await transaction.CommitAsync();

                // TODO: Bắn Event WebSocket/SignalR ra ngoài Frontend ở đây
                
                return true;
            }
            catch
            {
                await transaction.RollbackAsync();
                return false;
            }
        }

        public async Task<bool> WithdrawAsync(string userId, WithdrawRequest request)
        {
            if (request.Amount <= 0) return false;

            using var transaction = await _context.Database.BeginTransactionAsync();
            try
            {
                var wallet = await _context.Wallets.FirstOrDefaultAsync(w => w.UserId == userId);
                if (wallet == null || wallet.Balance < request.Amount) return false;

                var bankAccount = await _context.UserBankAccounts.FirstOrDefaultAsync(b => b.Id == request.BankAccountId && b.UserId == userId);
                if (bankAccount == null) return false;

                wallet.Balance -= request.Amount;
                wallet.UpdatedAt = DateTime.Now;

                var tx = new Transaction
                {
                    TransactionId = Guid.NewGuid().ToString(),
                    WalletId = wallet.WalletId,
                    Amount = -request.Amount, // Lưu số âm biểu thị tiền bị trừ/đóng băng
                    TransactionType = "Withdraw",
                    Status = "Pending", // Trạng thái ban đầu chờ duyệt
                    CreatedAt = DateTime.Now,
                    Fee = 0,
                    RecipientBankAccountId = bankAccount.Id,
                    Note = $"{bankAccount.BankName} - {bankAccount.AccountNumber} - {bankAccount.AccountName}"
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

        // CRUD Bank Account
        public async Task<UserBankAccount?> AddBankAccountAsync(string userId, CreateBankAccountRequest request)
        {
            var newAccount = new UserBankAccount
            {
                UserId = userId,
                BankCode = request.BankCode,
                BankName = request.BankName,
                AccountNumber = request.AccountNumber,
                AccountName = request.AccountName,
                IsDefault = request.IsDefault,
                CreatedAt = DateTime.Now
            };

            // Nếu set thẻ này là mặc định, bỏ mặc định các thẻ cũ
            if (request.IsDefault)
            {
                var existingAccounts = await _context.UserBankAccounts.Where(b => b.UserId == userId).ToListAsync();
                foreach (var acc in existingAccounts)
                {
                    acc.IsDefault = false;
                }
            }

            _context.UserBankAccounts.Add(newAccount);
            await _context.SaveChangesAsync();
            return newAccount;
        }

        public async Task<List<UserBankAccount>> GetUserBankAccountsAsync(string userId)
        {
            return await _context.UserBankAccounts.Where(b => b.UserId == userId).ToListAsync();
        }

        public async Task<bool> DeleteBankAccountAsync(string userId, string bankAccountId)
        {
            var account = await _context.UserBankAccounts.FirstOrDefaultAsync(b => b.Id == bankAccountId && b.UserId == userId);
            if (account == null) return false;

            _context.UserBankAccounts.Remove(account);
            await _context.SaveChangesAsync();
            return true;
        }

        // CRUD Gift
        public async Task<List<Gift>> GetAllGiftsAsync()
        {
            return await _context.Gifts.ToListAsync();
        }

        public async Task<Gift?> CreateGiftAsync(CreateGiftAdminRequest request)
        {
            var gift = new Gift
            {
                Id = Guid.NewGuid(),
                Name = request.Name,
                Price = request.Price,
                ImageUrl = request.ImageUrl,
                AnimationUrl = request.AnimationUrl
            };

            _context.Gifts.Add(gift);
            await _context.SaveChangesAsync();
            return gift;
        }

        public async Task<Gift?> UpdateGiftAsync(string giftId, UpdateGiftAdminRequest request)
        {
            if (!Guid.TryParse(giftId, out Guid parsedId)) return null;

            var gift = await _context.Gifts.FirstOrDefaultAsync(g => g.Id == parsedId);
            if (gift == null) return null;

            gift.Name = request.Name;
            gift.Price = request.Price;
            gift.ImageUrl = request.ImageUrl;
            gift.AnimationUrl = request.AnimationUrl;

            await _context.SaveChangesAsync();
            return gift;
        }

        public async Task<bool> DeleteGiftAsync(string giftId)
        {
            if (!Guid.TryParse(giftId, out Guid parsedId)) return false;

            var gift = await _context.Gifts.FirstOrDefaultAsync(g => g.Id == parsedId);
            if (gift == null) return false;

            _context.Gifts.Remove(gift);
            await _context.SaveChangesAsync();
            return true;
        }
    }
}
