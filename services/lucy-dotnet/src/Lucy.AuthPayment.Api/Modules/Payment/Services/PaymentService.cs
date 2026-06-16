using lucy_auth_payment.Data;
using lucy_auth_payment.Modules.Payment.DTOs;
using lucy_auth_payment.Modules.Payment.Models;
using Microsoft.EntityFrameworkCore;
using System.Net.Http.Json;

namespace lucy_auth_payment.Modules.Payment.Services;

public class PaymentService : IPaymentService
{
    private const string AdminWalletId = "W-ADMIN-001";
    private const string AdminUserId = "Uadmin";
    private const string MomoSettingId = "PAY-MOMO-ADMIN";
    private const string MomoProvider = "MOMO";
    private const decimal VndPerCoin = 1000m;

    private readonly AppDbContext _context;
    private readonly IWebHostEnvironment _environment;
    private readonly IHttpClientFactory _httpClientFactory;
    private readonly IConfiguration _configuration;
    private readonly ILogger<PaymentService> _logger;

    public PaymentService(
        AppDbContext context,
        IWebHostEnvironment environment,
        IHttpClientFactory httpClientFactory,
        IConfiguration configuration,
        ILogger<PaymentService> logger)
    {
        _context = context;
        _environment = environment;
        _httpClientFactory = httpClientFactory;
        _configuration = configuration;
        _logger = logger;
    }

    public Task<Wallet> GetOrCreateWalletAsync(string userId) => GetOrCreateWalletInternalAsync(userId);

    public Task<List<WalletTransaction>> GetTransactionsAsync(string userId)
    {
        return _context.WalletTransactions
            .Where(tx => tx.UserId == userId)
            .OrderByDescending(tx => tx.CreatedAt)
            .Take(100)
            .ToListAsync();
    }

    public async Task<TopUpOrderResponse> DepositAsync(string userId, DepositRequest request)
    {
        if (request.Amount <= 0) throw new InvalidOperationException("Amount must be greater than 0.");

        var wallet = await GetOrCreateWalletInternalAsync(userId);
        var coins = Math.Floor(request.Amount / VndPerCoin);
        if (coins <= 0) throw new InvalidOperationException("Minimum top-up is 1,000 VND.");
        var setting = await GetActiveMomoSettingAsync();

        var order = new TopUpOrder
        {
            TopUpOrderId = NewId(),
            UserId = userId,
            WalletId = wallet.WalletId,
            Amount = request.Amount,
            PaymentProvider = MomoProvider,
            ExternalTransactionCode = request.ExternalTransactionCode,
            OrderStatus = "PENDING",
            CreatedAt = DateTime.Now,
            PaidAt = null
        };
        _context.TopUpOrders.Add(order);

        await _context.SaveChangesAsync();
        return TopUpOrderResponse.From(order, coins, setting);
    }

    public Task<PaymentSetting?> GetMomoSettingAsync()
    {
        return _context.PaymentSettings
            .Where(item => item.ProviderCode == MomoProvider)
            .OrderByDescending(item => item.IsActive)
            .ThenByDescending(item => item.UpdatedAt ?? item.CreatedAt)
            .FirstOrDefaultAsync();
    }

    public async Task<PaymentSetting> SaveMomoSettingAsync(SavePaymentSettingRequest request)
    {
        if (string.IsNullOrWhiteSpace(request.ReceiverName)) throw new InvalidOperationException("Receiver name is required.");
        if (string.IsNullOrWhiteSpace(request.ReceiverPhone)) throw new InvalidOperationException("Receiver phone is required.");

        var setting = await _context.PaymentSettings.FirstOrDefaultAsync(item => item.PaymentSettingId == MomoSettingId);
        if (setting == null)
        {
            setting = new PaymentSetting
            {
                PaymentSettingId = MomoSettingId,
                ProviderCode = MomoProvider,
                ReceiverUserId = AdminUserId,
                CreatedAt = DateTime.Now
            };
            _context.PaymentSettings.Add(setting);
        }

        setting.ReceiverName = request.ReceiverName.Trim();
        setting.ReceiverPhone = request.ReceiverPhone.Trim();
        setting.QrImageUrl = string.IsNullOrWhiteSpace(request.QrImageUrl) ? null : request.QrImageUrl.Trim();
        setting.TransferContentTemplate = NormalizeTransferTemplate(request.TransferContentTemplate);
        setting.IsActive = request.IsActive;
        setting.UpdatedAt = DateTime.Now;

        await _context.SaveChangesAsync();
        return setting;
    }

    public async Task<PaymentSetting> UploadMomoQrAsync(IFormFile file)
    {
        if (file.Length <= 0) throw new InvalidOperationException("QR image is required.");

        var extension = Path.GetExtension(file.FileName).ToLowerInvariant();
        var allowedExtensions = new[] { ".png", ".jpg", ".jpeg", ".webp" };
        if (!allowedExtensions.Contains(extension))
        {
            throw new InvalidOperationException("QR image must be PNG, JPG, JPEG, or WEBP.");
        }

        var setting = await _context.PaymentSettings.FirstOrDefaultAsync(item => item.PaymentSettingId == MomoSettingId)
            ?? throw new InvalidOperationException("Please save MoMo setting before uploading QR image.");

        var webRoot = string.IsNullOrWhiteSpace(_environment.WebRootPath)
            ? Path.Combine(_environment.ContentRootPath, "wwwroot")
            : _environment.WebRootPath;
        var uploadFolder = Path.Combine(webRoot, "uploads", "payment");
        Directory.CreateDirectory(uploadFolder);

        DeleteOldLocalQr(setting.QrImageUrl, uploadFolder);

        var fileName = $"momo-admin-qr-{DateTime.Now:yyyyMMddHHmmss}{extension}";
        var filePath = Path.Combine(uploadFolder, fileName);
        await using (var stream = File.Create(filePath))
        {
            await file.CopyToAsync(stream);
        }

        setting.QrImageUrl = $"/uploads/payment/{fileName}";
        setting.UpdatedAt = DateTime.Now;
        await _context.SaveChangesAsync();
        return setting;
    }

    public async Task<List<TopUpOrderResponse>> GetTopUpOrdersAsync(string? status)
    {
        var query = _context.TopUpOrders.AsQueryable();
        if (!string.IsNullOrWhiteSpace(status))
        {
            query = query.Where(order => order.OrderStatus == status);
        }
        var setting = await GetMomoSettingAsync();
        var orders = await query.OrderByDescending(order => order.CreatedAt).Take(200).ToListAsync();
        return orders.Select(order => TopUpOrderResponse.From(order, Math.Floor(order.Amount / VndPerCoin), setting)).ToList();
    }

    public async Task<TopUpOrderResponse> ApproveTopUpOrderAsync(string topUpOrderId)
    {
        await using var dbTransaction = await _context.Database.BeginTransactionAsync();
        var order = await _context.TopUpOrders.FirstOrDefaultAsync(item => item.TopUpOrderId == topUpOrderId)
            ?? throw new InvalidOperationException("Top-up order not found.");
        if (!string.Equals(order.OrderStatus, "PENDING", StringComparison.OrdinalIgnoreCase))
        {
            throw new InvalidOperationException("Top-up order is not pending.");
        }

        var wallet = await _context.Wallets.FirstOrDefaultAsync(item => item.WalletId == order.WalletId)
            ?? throw new InvalidOperationException("Wallet not found.");
        var coins = Math.Floor(order.Amount / VndPerCoin);
        if (coins <= 0) throw new InvalidOperationException("Top-up amount is lower than 1 Xu.");

        AddBalance(wallet, coins, "Deposit", relatedRefType: "TOP_UP_ORDER", relatedRefId: order.TopUpOrderId,
            description: $"MoMo top up {order.Amount:0} VND => {coins:0} Xu");
        order.OrderStatus = "PAID";
        order.PaidAt = DateTime.Now;

        await _context.SaveChangesAsync();
        await dbTransaction.CommitAsync();
        return TopUpOrderResponse.From(order, coins, await GetMomoSettingAsync());
    }

    public async Task<TopUpOrderResponse> RejectTopUpOrderAsync(string topUpOrderId, string? reason)
    {
        var order = await _context.TopUpOrders.FirstOrDefaultAsync(item => item.TopUpOrderId == topUpOrderId)
            ?? throw new InvalidOperationException("Top-up order not found.");
        if (!string.Equals(order.OrderStatus, "PENDING", StringComparison.OrdinalIgnoreCase))
        {
            throw new InvalidOperationException("Top-up order is not pending.");
        }

        order.OrderStatus = "FAILED";
        order.ExternalTransactionCode = string.IsNullOrWhiteSpace(reason) ? order.ExternalTransactionCode : reason.Trim();
        await _context.SaveChangesAsync();
        return TopUpOrderResponse.From(order, Math.Floor(order.Amount / VndPerCoin), await GetMomoSettingAsync());
    }

    public async Task<ContentPurchase> PurchaseContentAsync(string buyerUserId, PurchaseContentRequest request)
    {
        var content = await _context.PaidContents.FirstOrDefaultAsync(item => item.ContentId == request.ContentId)
            ?? throw new InvalidOperationException("Paid content not found.");
        if (!string.Equals(content.ContentStatus, "PUBLISHED", StringComparison.OrdinalIgnoreCase))
        {
            throw new InvalidOperationException("Content is not published.");
        }

        if (!await IsSuperUserAsync(content.CreatorUserId, null))
        {
            throw new InvalidOperationException("Chưa đủ điều kiện bán nội dung số.");
        }

        var existingPurchase = await _context.ContentPurchases
            .FirstOrDefaultAsync(item => item.ContentId == content.ContentId && item.BuyerUserId == buyerUserId);
        if (existingPurchase != null) return existingPurchase;

        var buyerUser = await _context.Users.FirstOrDefaultAsync(u => u.UserId == buyerUserId);
        var buyerAvatar = await _context.AvatarPersonas.FirstOrDefaultAsync(a => a.UserId == buyerUserId);
        var buyerDisplayName = !string.IsNullOrWhiteSpace(buyerAvatar?.DisplayName) 
            ? buyerAvatar.DisplayName 
            : (buyerUser?.FullName ?? buyerUserId);

        await using var dbTransaction = await _context.Database.BeginTransactionAsync();
        var buyerWallet = await GetOrCreateWalletInternalAsync(buyerUserId);
        var sellerWallet = await GetOrCreateWalletInternalAsync(content.CreatorUserId);
        var adminWallet = await GetOrCreateWalletInternalAsync(AdminUserId, AdminWalletId);
        var amount = content.PriceAmount;
        EnsureEnoughBalance(buyerWallet, amount);

        var purchase = new ContentPurchase
        {
            PurchaseId = NewId(),
            ContentId = content.ContentId,
            BuyerUserId = buyerUserId,
            SellerUserId = content.CreatorUserId,
            PriceAmount = amount,
            PurchasedAt = DateTime.Now
        };

        var split = Split(amount, 0.10m);
        purchase.BuyerWalletTransactionId = AddBalance(buyerWallet, -amount, "BuyPodcast", content.CreatorUserId,
            "PAID_CONTENT", content.ContentId, $"Buy content {content.Title}");
        purchase.SellerWalletTransactionId = AddBalance(sellerWallet, split.NetAmount, "BuyPodcast", buyerUserId,
            "CONTENT_PURCHASE", purchase.PurchaseId, $"Content revenue from {buyerUserId}");
        if (split.FeeAmount > 0)
        {
            AddBalance(adminWallet, split.FeeAmount, "Commission", buyerUserId, "CONTENT_PURCHASE",
                purchase.PurchaseId, "10% podcast/content commission");
        }

        await _context.SaveChangesAsync();

        _context.ContentPurchases.Add(purchase);
        await _context.SaveChangesAsync();
        await dbTransaction.CommitAsync();
        await CreatePaymentNotificationAsync(
            content.CreatorUserId,
            "Co nguoi mua noi dung",
            $"{buyerDisplayName} vua mua {content.Title} voi {amount:0.##} Xu. Ban nhan {split.NetAmount:0.##} Xu.",
            "CONTENT_PURCHASE",
            "CONTENT_PURCHASE",
            purchase.PurchaseId,
            amount,
            split.FeeAmount,
            split.NetAmount,
            buyerUserId,
            fromDisplayName: buyerDisplayName);
        return purchase;
    }

    public async Task<LiveAccessTicket> PurchaseLiveAsync(string buyerUserId, PurchaseLiveRequest request)
    {
        var room = await _context.Rooms.FirstOrDefaultAsync(item => item.RoomId == request.RoomId)
            ?? throw new InvalidOperationException("Room not found.");
        var existingTicket = await _context.LiveAccessTickets
            .FirstOrDefaultAsync(ticket => ticket.RoomId == room.RoomId && ticket.UserId == buyerUserId && ticket.TicketStatus == "ACTIVE");
        if (existingTicket != null) return existingTicket;

        var amount = room.PriceAmount ?? 0;
        if (amount <= 0)
        {
            return await EnsureLiveTicketAsync(room.RoomId, buyerUserId, null);
        }

        var buyerUser = await _context.Users.FirstOrDefaultAsync(u => u.UserId == buyerUserId);
        var buyerAvatar = await _context.AvatarPersonas.FirstOrDefaultAsync(a => a.UserId == buyerUserId);
        var buyerDisplayName = !string.IsNullOrWhiteSpace(buyerAvatar?.DisplayName) 
            ? buyerAvatar.DisplayName 
            : (buyerUser?.FullName ?? buyerUserId);

        await using var dbTransaction = await _context.Database.BeginTransactionAsync();
        var buyerWallet = await GetOrCreateWalletInternalAsync(buyerUserId);
        var hostWallet = await GetOrCreateWalletInternalAsync(room.HostUserId);
        var adminWallet = await GetOrCreateWalletInternalAsync(AdminUserId, AdminWalletId);
        var liveContent = await GetOrCreateLivePaidContentAsync(room);
        EnsureEnoughBalance(buyerWallet, amount);

        var purchase = new ContentPurchase
        {
            PurchaseId = NewId(),
            ContentId = liveContent.ContentId,
            BuyerUserId = buyerUserId,
            SellerUserId = room.HostUserId,
            PriceAmount = amount,
            PurchasedAt = DateTime.Now
        };

        var feeRate = await IsSuperUserAsync(room.HostUserId, room.HostRole) ? 0.10m : 0.15m;
        var split = Split(amount, feeRate);
        purchase.BuyerWalletTransactionId = AddBalance(buyerWallet, -amount, "PayLive", room.HostUserId,
            "ROOM", room.RoomId, $"Buy live ticket: {room.RoomTitle}");
        purchase.SellerWalletTransactionId = AddBalance(hostWallet, split.NetAmount, "PayLive", buyerUserId,
            "LIVE_TICKET", purchase.PurchaseId, $"Live ticket revenue from {buyerUserId}");
        if (split.FeeAmount > 0)
        {
            AddBalance(adminWallet, split.FeeAmount, "Commission", buyerUserId, "LIVE_TICKET",
                purchase.PurchaseId, $"{feeRate:P0} live commission");
        }

        await _context.SaveChangesAsync();

        _context.ContentPurchases.Add(purchase);
        var ticket = new LiveAccessTicket
        {
            TicketId = NewId(),
            RoomId = room.RoomId,
            UserId = buyerUserId,
            PurchaseId = purchase.PurchaseId,
            TicketStatus = "ACTIVE",
            CreatedAt = DateTime.Now
        };
        _context.LiveAccessTickets.Add(ticket);

        await _context.SaveChangesAsync();
        await dbTransaction.CommitAsync();
        await CreatePaymentNotificationAsync(
            room.HostUserId,
            "Co hoc vien mua khoa/live",
            $"{buyerDisplayName} vua mua ve {room.RoomTitle} voi {amount:0.##} Xu. Ban nhan {split.NetAmount:0.##} Xu.",
            "LIVE_PURCHASE",
            "ROOM",
            room.RoomId,
            amount,
            split.FeeAmount,
            split.NetAmount,
            buyerUserId,
            room.RoomId,
            fromDisplayName: buyerDisplayName);
        return ticket;
    }

    public async Task<Donation> DonateAsync(string fromUserId, DonateRequest request)
    {
        Gift? gift = null;
        var quantity = request.Quantity.GetValueOrDefault(1);
        if (quantity <= 0) throw new InvalidOperationException("Gift quantity must be greater than 0.");

        var amount = request.Amount;
        var giftImageUrl = request.GiftImageUrl;
        string? giftName = null;
        string? giftId = null;
        if (!string.IsNullOrWhiteSpace(request.GiftId))
        {
            gift = await _context.Gifts.FirstOrDefaultAsync(item => item.GiftId == request.GiftId && item.IsActive)
                ?? throw new InvalidOperationException("Gift not found or inactive.");
            giftId = gift.GiftId;
            giftName = gift.GiftName;
            giftImageUrl = gift.IconUrl;
            amount = gift.PriceAmount * quantity * 10m;
        }

        if (amount <= 0) throw new InvalidOperationException("Amount must be greater than 0.");

        var fromUser = await _context.Users.FirstOrDefaultAsync(u => u.UserId == fromUserId);
        var fromAvatar = await _context.AvatarPersonas.FirstOrDefaultAsync(a => a.UserId == fromUserId);
        var fromDisplayName = !string.IsNullOrWhiteSpace(fromAvatar?.DisplayName) 
            ? fromAvatar.DisplayName 
            : (!string.IsNullOrWhiteSpace(fromUser?.FullName) ? fromUser.FullName : "Học viên");

        await using var dbTransaction = await _context.Database.BeginTransactionAsync();
        var fromWallet = await GetOrCreateWalletInternalAsync(fromUserId);
        var toWallet = await GetOrCreateWalletInternalAsync(request.ToUserId);
        var adminWallet = await GetOrCreateWalletInternalAsync(AdminUserId, AdminWalletId);
        EnsureEnoughBalance(fromWallet, amount);

        var feeRate = await IsSuperUserAsync(request.ToUserId, null) ? 0.10m : 0.20m;
        var split = Split(amount, feeRate);
        var messageText = request.MessageText;
        if (gift != null)
        {
            messageText = string.IsNullOrWhiteSpace(messageText)
                ? $"Tang {quantity} x {gift.GiftName}"
                : messageText;
        }
        var donation = new Donation
        {
            DonationId = NewId(),
            FromUserId = fromUserId,
            ToUserId = request.ToUserId,
            RoomId = request.RoomId,
            Amount = amount,
            MessageText = messageText,
            CreatedAt = DateTime.Now
        };

        donation.FromWalletTransactionId = AddBalance(fromWallet, -amount, "Donate", request.ToUserId,
            "DONATION", donation.DonationId, messageText);
        donation.ToWalletTransactionId = AddBalance(toWallet, split.NetAmount, "Donate", fromUserId,
            "DONATION", donation.DonationId, messageText);
        if (split.FeeAmount > 0)
        {
            AddBalance(adminWallet, split.FeeAmount, "Commission", fromUserId, "DONATION", donation.DonationId,
                $"{feeRate:P0} donation commission");
        }

        await _context.SaveChangesAsync();

        _context.Donations.Add(donation);
        await _context.SaveChangesAsync();
        await dbTransaction.CommitAsync();
        await CreatePaymentNotificationAsync(
            request.ToUserId,
            "Ban nhan duoc donate",
            $"{fromDisplayName} vua donate {amount:0.##} Xu. Ban nhan {split.NetAmount:0.##} Xu.",
            "DONATION",
            "DONATION",
            donation.DonationId,
            amount,
            split.FeeAmount,
            split.NetAmount,
            fromUserId,
            request.RoomId,
            giftImageUrl,
            giftId,
            giftName,
            quantity,
            fromDisplayName);
        return donation;
    }

    public async Task<List<WithdrawRequestEntity>> GetWithdrawRequestsAsync(string? status)
    {
        var query = _context.WithdrawRequests.AsQueryable();
        if (!string.IsNullOrWhiteSpace(status))
        {
            query = query.Where(request => request.RequestStatus == status);
        }

        return await query
            .OrderByDescending(request => request.RequestedAt)
            .Take(200)
            .ToListAsync();
    }

    public async Task<WithdrawRequestEntity> WithdrawAsync(string userId, WithdrawRequest request)
    {
        if (request.Amount <= 0) throw new InvalidOperationException("Amount must be greater than 0.");

        await using var dbTransaction = await _context.Database.BeginTransactionAsync();
        var wallet = await GetOrCreateWalletInternalAsync(userId);
        var configuredFeePercent = _configuration.GetValue<decimal?>("Payment:WithdrawFeePercent");
        var feePercent = NormalizePercent(configuredFeePercent ?? request.FeePercent ?? 0);
        var split = Split(request.Amount, feePercent / 100m);
        EnsureEnoughBalance(wallet, request.Amount);
        var withdraw = new WithdrawRequestEntity
        {
            WithdrawRequestId = NewId(),
            UserId = userId,
            WalletId = wallet.WalletId,
            Amount = request.Amount,
            FeePercent = feePercent,
            FeeAmount = split.FeeAmount,
            NetAmount = split.NetAmount,
            BankName = request.BankName,
            BankAccountNumber = request.BankAccountNumber,
            BankAccountName = request.BankAccountName,
            RequestStatus = "PENDING",
            RequestedAt = DateTime.Now
        };

        _context.WithdrawRequests.Add(withdraw);
        AddBalance(wallet, -request.Amount, "Withdraw", relatedRefType: "WITHDRAW_REQUEST",
            relatedRefId: withdraw.WithdrawRequestId, description: "Withdraw request locked coins",
            status: "PENDING");

        await _context.SaveChangesAsync();
        await dbTransaction.CommitAsync();
        return withdraw;
    }

    public async Task<WithdrawRequestEntity> ApproveWithdrawAsync(string withdrawRequestId)
    {
        await using var dbTransaction = await _context.Database.BeginTransactionAsync();
        var withdraw = await _context.WithdrawRequests.FirstOrDefaultAsync(item => item.WithdrawRequestId == withdrawRequestId)
            ?? throw new InvalidOperationException("Withdraw request not found.");
        if (!string.Equals(withdraw.RequestStatus, "PENDING", StringComparison.OrdinalIgnoreCase))
        {
            throw new InvalidOperationException("Withdraw request is not pending.");
        }
        if (withdraw.FeeAmount > 0)
        {
            var adminWallet = await GetOrCreateWalletInternalAsync(AdminUserId, AdminWalletId);
            AddBalance(adminWallet, withdraw.FeeAmount, "WithdrawFee", withdraw.UserId,
                "WITHDRAW_REQUEST", withdraw.WithdrawRequestId,
                $"Withdraw fee {withdraw.FeePercent:0.##}% from {withdraw.Amount:0.##} Xu");
        }
        withdraw.RequestStatus = "SUCCESS";
        withdraw.ReviewedAt = DateTime.Now;
        await SetRelatedTransactionsStatusAsync("WITHDRAW_REQUEST", withdraw.WithdrawRequestId, "SUCCESS");
        await _context.SaveChangesAsync();
        await dbTransaction.CommitAsync();
        return withdraw;
    }

    public async Task<WithdrawRequestEntity> RejectWithdrawAsync(string withdrawRequestId, string? rejectReason)
    {
        await using var dbTransaction = await _context.Database.BeginTransactionAsync();
        var withdraw = await _context.WithdrawRequests.FirstOrDefaultAsync(item => item.WithdrawRequestId == withdrawRequestId)
            ?? throw new InvalidOperationException("Withdraw request not found.");
        if (!string.Equals(withdraw.RequestStatus, "PENDING", StringComparison.OrdinalIgnoreCase))
        {
            throw new InvalidOperationException("Withdraw request is not pending.");
        }

        var wallet = await GetOrCreateWalletInternalAsync(withdraw.UserId);
        AddBalance(wallet, withdraw.Amount, "WithdrawRefund", relatedRefType: "WITHDRAW_REQUEST",
            relatedRefId: withdraw.WithdrawRequestId, description: "Withdraw request rejected refund");
        withdraw.RequestStatus = "FAILED";
        withdraw.RejectReason = rejectReason;
        withdraw.ReviewedAt = DateTime.Now;
        await SetRelatedTransactionsStatusAsync("WITHDRAW_REQUEST", withdraw.WithdrawRequestId, "FAILED");

        await _context.SaveChangesAsync();
        await dbTransaction.CommitAsync();
        return withdraw;
    }

    private async Task<LiveAccessTicket> EnsureLiveTicketAsync(string roomId, string userId, string? purchaseId)
    {
        var existing = await _context.LiveAccessTickets
            .FirstOrDefaultAsync(ticket => ticket.RoomId == roomId && ticket.UserId == userId && ticket.TicketStatus == "ACTIVE");
        if (existing != null) return existing;

        var ticket = new LiveAccessTicket
        {
            TicketId = NewId(),
            RoomId = roomId,
            UserId = userId,
            PurchaseId = purchaseId,
            TicketStatus = "ACTIVE",
            CreatedAt = DateTime.Now
        };
        _context.LiveAccessTickets.Add(ticket);
        await _context.SaveChangesAsync();
        return ticket;
    }

    private async Task<PaidContent> GetOrCreateLivePaidContentAsync(Room room)
    {
        var content = await _context.PaidContents.FirstOrDefaultAsync(item => item.RoomId == room.RoomId && item.ContentType == "PAID_LIVE");
        if (content != null) return content;

        content = new PaidContent
        {
            ContentId = NewId(),
            CreatorUserId = room.HostUserId,
            RoomId = room.RoomId,
            ContentType = "PAID_LIVE",
            Title = room.RoomTitle,
            PriceAmount = room.PriceAmount ?? 0,
            ContentStatus = "PUBLISHED",
            PublishedAt = DateTime.Now
        };
        _context.PaidContents.Add(content);
        return content;
    }

    private async Task<Wallet> GetOrCreateWalletInternalAsync(string userId, string? fixedWalletId = null)
    {
        var wallet = await _context.Wallets.FirstOrDefaultAsync(item => item.UserId == userId || item.WalletId == fixedWalletId);
        if (wallet != null) return wallet;

        if (!await _context.Users.AnyAsync(user => user.UserId == userId))
        {
            throw new InvalidOperationException($"User {userId} does not exist in database.");
        }

        wallet = new Wallet
        {
            WalletId = fixedWalletId ?? NewId(),
            UserId = userId,
            Balance = 0,
            CurrencyCode = "XU",
            WalletStatus = "ACTIVE",
            CreatedAt = DateTime.Now
        };
        _context.Wallets.Add(wallet);
        await _context.SaveChangesAsync();
        return wallet;
    }

    private async Task<PaymentSetting> GetActiveMomoSettingAsync()
    {
        return await _context.PaymentSettings
            .FirstOrDefaultAsync(item => item.ProviderCode == MomoProvider && item.IsActive == 1)
            ?? throw new InvalidOperationException("MoMo payment setting is not configured.");
    }

    private static string NormalizeTransferTemplate(string? template)
    {
        var value = string.IsNullOrWhiteSpace(template) ? "LUCY NAP TIEN {ORDER_CODE}" : template.Trim();
        return value.Contains("{ORDER_CODE}", StringComparison.OrdinalIgnoreCase)
            ? value
            : $"{value} {{ORDER_CODE}}";
    }

    private static void DeleteOldLocalQr(string? qrImageUrl, string uploadFolder)
    {
        if (string.IsNullOrWhiteSpace(qrImageUrl)) return;

        var pathPart = qrImageUrl.Trim();
        if (Uri.TryCreate(pathPart, UriKind.Absolute, out var uri))
        {
            pathPart = uri.AbsolutePath;
        }
        if (!pathPart.StartsWith("/uploads/payment/", StringComparison.OrdinalIgnoreCase)) return;

        var oldFile = Path.Combine(uploadFolder, Path.GetFileName(pathPart));
        if (File.Exists(oldFile))
        {
            File.Delete(oldFile);
        }
    }

    private string AddBalance(
        Wallet wallet,
        decimal delta,
        string transactionType,
        string? relatedUserId = null,
        string? relatedRefType = null,
        string? relatedRefId = null,
        string? description = null,
        string status = "SUCCESS")
    {
        var before = wallet.Balance;
        var after = before + delta;
        if (after < 0) throw new InvalidOperationException("Wallet balance is not enough.");
        wallet.Balance = after;

        var tx = new WalletTransaction
        {
            WalletTransactionId = NewId(),
            WalletId = wallet.WalletId,
            UserId = wallet.UserId,
            RelatedUserId = relatedUserId,
            TransactionType = transactionType,
            Direction = delta >= 0 ? "IN" : "OUT",
            Amount = Math.Abs(delta),
            BalanceBefore = before,
            BalanceAfter = after,
            RelatedRefType = relatedRefType,
            RelatedRefId = relatedRefId,
            DescriptionText = description,
            TransactionStatus = status,
            CreatedAt = DateTime.Now
        };
        _context.WalletTransactions.Add(tx);
        return tx.WalletTransactionId;
    }

    private async Task SetRelatedTransactionsStatusAsync(string relatedRefType, string relatedRefId, string status)
    {
        var transactions = await _context.WalletTransactions
            .Where(tx => tx.RelatedRefType == relatedRefType && tx.RelatedRefId == relatedRefId)
            .ToListAsync();
        foreach (var tx in transactions)
        {
            tx.TransactionStatus = status;
        }
    }

    private async Task CreatePaymentNotificationAsync(
        string userId,
        string title,
        string bodyText,
        string notificationType,
        string refType,
        string refId,
        decimal grossAmount,
        decimal feeAmount,
        decimal netAmount,
        string? fromUserId = null,
        string? roomId = null,
        string? giftImageUrl = null,
        string? giftId = null,
        string? giftName = null,
        int? giftQuantity = null,
        string? fromDisplayName = null)
    {
        var notification = new Notification
        {
            NotificationId = NewId(),
            UserId = userId,
            Title = title,
            BodyText = bodyText,
            NotificationType = notificationType,
            RefType = refType,
            IsRead = 0,
            CreatedAt = DateTime.Now
        };

        _context.Notifications.Add(notification);
        await _context.SaveChangesAsync();
        await DispatchRealtimeNotificationAsync(notification, refId, grossAmount, feeAmount, netAmount, fromUserId,
            roomId, giftImageUrl, giftId, giftName, giftQuantity, fromDisplayName);
    }

    private async Task DispatchRealtimeNotificationAsync(
        Notification notification,
        string refId,
        decimal grossAmount,
        decimal feeAmount,
        decimal netAmount,
        string? fromUserId,
        string? roomId,
        string? giftImageUrl = null,
        string? giftId = null,
        string? giftName = null,
        int? giftQuantity = null,
        string? fromDisplayName = null)
    {
        var baseUrl = _configuration["Realtime:InternalBaseUrl"];
        if (string.IsNullOrWhiteSpace(baseUrl)) return;

        try
        {
            var client = _httpClientFactory.CreateClient();
            client.BaseAddress = new Uri(baseUrl.TrimEnd('/') + "/");
            await client.PostAsJsonAsync("internal/payment-notifications", new
            {
                notification.NotificationId,
                notification.UserId,
                notification.Title,
                notification.BodyText,
                notification.NotificationType,
                notification.RefType,
                RefId = refId,
                FromUserId = fromUserId,
                RoomId = roomId,
                GrossAmount = grossAmount,
                FeeAmount = feeAmount,
                NetAmount = netAmount,
                GiftImageUrl = giftImageUrl,
                GiftId = giftId,
                GiftName = giftName,
                GiftQuantity = giftQuantity,
                FromDisplayName = fromDisplayName,
                notification.CreatedAt
            });
        }
        catch (Exception ex)
        {
            _logger.LogWarning(ex, "Could not dispatch realtime payment notification {NotificationId}.", notification.NotificationId);
        }
    }

    private async Task<bool> IsSuperUserAsync(string userId, string? hostRole)
    {
        if (string.Equals(hostRole, "CREATOR", StringComparison.OrdinalIgnoreCase)) return true;
        if (userId.Contains("SUPER", StringComparison.OrdinalIgnoreCase)) return true;
        return await _context.UserRoles.AnyAsync(role => role.UserId == userId && role.RoleId == "R004");
    }

    private static void EnsureEnoughBalance(Wallet wallet, decimal amount)
    {
        if (wallet.Balance < amount) throw new InvalidOperationException("Wallet balance is not enough.");
    }

    private static decimal NormalizePercent(decimal percent)
    {
        if (percent < 0 || percent > 100) throw new InvalidOperationException("Fee percent must be between 0 and 100.");
        return percent;
    }

    public Task<List<Gift>> GetGiftsAsync()
    {
        return _context.Gifts.OrderBy(g => g.PriceAmount).ToListAsync();
    }

    private static (decimal FeeAmount, decimal NetAmount) Split(decimal amount, decimal feeRate)
    {
        var fee = Math.Round(amount * feeRate, 2, MidpointRounding.AwayFromZero);
        return (fee, amount - fee);
    }

    private static string NewId() => Guid.NewGuid().ToString();
}