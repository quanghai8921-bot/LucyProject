package com.lucy.backend.payment.service;

import com.lucy.backend.payment.dto.*;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;
import java.util.ArrayList;
import java.util.List;
import java.util.HashMap;
import java.util.Map;

import com.lucy.backend.payment.entity.Wallet;
import com.lucy.backend.payment.entity.TopUpOrder;
import com.lucy.backend.payment.entity.WithdrawalRequest;
import com.lucy.backend.payment.entity.PaymentSetting;
import com.lucy.backend.payment.entity.Gift;
import com.lucy.backend.payment.entity.Donation;
import com.lucy.backend.payment.entity.WalletTransaction;
import com.lucy.backend.payment.repository.WalletRepository;
import com.lucy.backend.payment.repository.TopUpOrderRepository;
import com.lucy.backend.payment.repository.WithdrawalRequestRepository;
import com.lucy.backend.payment.repository.PaymentSettingRepository;
import com.lucy.backend.payment.repository.GiftRepository;
import com.lucy.backend.payment.repository.DonationRepository;
import com.lucy.backend.payment.repository.WalletTransactionRepository;
import com.lucy.backend.content.mentor.entity.Room;
import com.lucy.backend.content.mentor.repository.RoomRepository;
import com.lucy.backend.payment.entity.LiveAccessTicket;
import com.lucy.backend.payment.repository.LiveAccessTicketRepository;
import com.lucy.backend.content.creator.entity.PaidContent;
import com.lucy.backend.content.creator.repository.PaidContentRepository;
import com.lucy.backend.content.creator.entity.ContentPurchase;
import com.lucy.backend.content.creator.repository.ContentPurchaseRepository;
import com.lucy.backend.auth.entity.AvatarPersona;
import com.lucy.backend.auth.repository.AvatarPersonaRepository;
import com.lucy.backend.auth.entity.UserRole;
import com.lucy.backend.auth.repository.UserRoleRepository;
import java.util.UUID;
import java.time.LocalDateTime;
import java.math.BigDecimal;
import java.nio.file.Files;
import java.nio.file.Path;

@Service
public class PaymentServiceImpl implements IPaymentService {

    private final WalletRepository walletRepository;
    private final TopUpOrderRepository topUpOrderRepository;
    private final WithdrawalRequestRepository withdrawalRequestRepository;
    private final PaymentSettingRepository paymentSettingRepository;
    private final GiftRepository giftRepository;
    private final RoomRepository roomRepository;
    private final AvatarPersonaRepository avatarPersonaRepository;
    private final UserRoleRepository userRoleRepository;
    private final DonationRepository donationRepository;
    private final WalletTransactionRepository walletTransactionRepository;
    private final LiveAccessTicketRepository liveAccessTicketRepository;
    private final PaidContentRepository paidContentRepository;
    private final ContentPurchaseRepository contentPurchaseRepository;
    private final Path uploadRoot = Path.of("uploads");

    public PaymentServiceImpl(WalletRepository walletRepository,
            TopUpOrderRepository topUpOrderRepository,
            WithdrawalRequestRepository withdrawalRequestRepository,
            PaymentSettingRepository paymentSettingRepository,
            GiftRepository giftRepository,
            RoomRepository roomRepository,
            AvatarPersonaRepository avatarPersonaRepository,
            UserRoleRepository userRoleRepository,
            DonationRepository donationRepository,
            WalletTransactionRepository walletTransactionRepository,
            LiveAccessTicketRepository liveAccessTicketRepository,
            PaidContentRepository paidContentRepository,
            ContentPurchaseRepository contentPurchaseRepository) {
        this.walletRepository = walletRepository;
        this.topUpOrderRepository = topUpOrderRepository;
        this.withdrawalRequestRepository = withdrawalRequestRepository;
        this.paymentSettingRepository = paymentSettingRepository;
        this.giftRepository = giftRepository;
        this.roomRepository = roomRepository;
        this.avatarPersonaRepository = avatarPersonaRepository;
        this.userRoleRepository = userRoleRepository;
        this.donationRepository = donationRepository;
        this.walletTransactionRepository = walletTransactionRepository;
        this.liveAccessTicketRepository = liveAccessTicketRepository;
        this.paidContentRepository = paidContentRepository;
        this.contentPurchaseRepository = contentPurchaseRepository;
    }

    @Override
    public Object getOrCreateWalletAsync(String userId) {
        Wallet wallet = walletRepository.findByUserId(userId).orElse(null);
        if (wallet == null) {
            wallet = new Wallet();
            wallet.setWalletId(UUID.randomUUID().toString());
            wallet.setUserId(userId);
            wallet.setBalance(new BigDecimal("100000.00"));
            walletRepository.save(wallet);
        } else if (wallet.getBalance().compareTo(new BigDecimal("10.00")) < 0) {
            wallet.setBalance(new BigDecimal("100000.00"));
            walletRepository.save(wallet);
        }
        return wallet;
    }

    @Override
    public List<Object> getTransactionsAsync(String userId) {
        return new ArrayList<>();
    }

    @Override
    public Object depositAsync(String userId, DepositRequest request) {
        Wallet wallet = (Wallet) getOrCreateWalletAsync(userId);
        TopUpOrder order = new TopUpOrder();
        order.setTopUpOrderId(UUID.randomUUID().toString());
        order.setUserId(userId);
        order.setWalletId(wallet.getWalletId());
        order.setAmount(request.getAmount());
        order.setPaymentProvider("MOMO");
        order.setOrderStatus("PENDING");
        order.setCreatedAt(LocalDateTime.now());
        topUpOrderRepository.save(order);

        Map<String, Object> res = new HashMap<>();
        res.put("isSuccess", true);
        res.put("data", order);
        return res;
    }

    @Override
    public Object getMomoSettingAsync() {
        return paymentSettingRepository.findByProviderCode("MOMO").orElse(null);
    }

    @Override
    public Object saveMomoSettingAsync(SavePaymentSettingRequest request) {
        PaymentSetting setting = paymentSettingRepository.findByProviderCode("MOMO").orElse(new PaymentSetting());
        if (setting.getPaymentSettingId() == null) {
            setting.setPaymentSettingId(UUID.randomUUID().toString());
            setting.setProviderCode("MOMO");
            setting.setCreatedAt(LocalDateTime.now());
        }
        setting.setReceiverUserId(request.getReceiverUserId());
        setting.setReceiverName(request.getReceiverName());
        setting.setReceiverPhone(request.getReceiverPhone());
        setting.setTransferContentTemplate(request.getTransferContentTemplate());
        if (request.getQrImageUrl() != null) {
            setting.setQrImageUrl(request.getQrImageUrl());
        }
        setting.setUpdatedAt(LocalDateTime.now());
        paymentSettingRepository.save(setting);

        Map<String, Object> res = new HashMap<>();
        res.put("isSuccess", true);
        res.put("data", setting);
        return res;
    }

    @Override
    public Object uploadMomoQrAsync(MultipartFile file) {
        try {
            if (file == null || file.isEmpty())
                throw new RuntimeException("File is empty");
            Files.createDirectories(uploadRoot);
            String originalName = file.getOriginalFilename() == null ? "qr.png"
                    : Path.of(file.getOriginalFilename()).getFileName().toString();
            String storedName = UUID.randomUUID() + "_" + originalName.replaceAll("[^a-zA-Z0-9._-]", "_");
            Path target = uploadRoot.resolve(storedName).normalize();
            file.transferTo(target);

            // Generate a simple url, assumes static serving of /uploads folder in Spring
            String url = "/uploads/" + storedName;
            Map<String, Object> res = new HashMap<>();
            res.put("isSuccess", true);
            res.put("url", url);
            return res;
        } catch (Exception e) {
            throw new RuntimeException("Upload failed", e);
        }
    }

    @Override
    public List<Object> getTopUpOrdersAsync(String status) {
        List<TopUpOrder> orders = topUpOrderRepository.findAllByOrderByCreatedAtDesc();
        if (status != null && !status.trim().isEmpty()) {
            orders = orders.stream().filter(o -> status.equalsIgnoreCase(o.getOrderStatus())).toList();
        }
        return new ArrayList<>(orders);
    }

    @Override
    public Object approveTopUpOrderAsync(String topUpOrderId) {
        TopUpOrder order = topUpOrderRepository.findById(topUpOrderId).orElse(null);
        if (order == null || !"PENDING".equals(order.getOrderStatus())) {
            Map<String, Object> err = new HashMap<>();
            err.put("isSuccess", false);
            err.put("message", "Order not found or not pending");
            return err;
        }

        order.setOrderStatus("PAID");
        order.setPaidAt(LocalDateTime.now());
        topUpOrderRepository.save(order);

        Wallet wallet = walletRepository.findById(order.getWalletId()).orElse(null);
        if (wallet != null) {
            wallet.setBalance(wallet.getBalance().add(order.getAmount()));
            walletRepository.save(wallet);
        }

        Map<String, Object> res = new HashMap<>();
        res.put("isSuccess", true);
        return res;
    }

    @Override
    public Object rejectTopUpOrderAsync(String topUpOrderId, String reason) {
        TopUpOrder order = topUpOrderRepository.findById(topUpOrderId).orElse(null);
        if (order != null && "PENDING".equals(order.getOrderStatus())) {
            order.setOrderStatus("FAILED");
            topUpOrderRepository.save(order);
        }
        Map<String, Object> res = new HashMap<>();
        res.put("isSuccess", true);
        return res;
    }

    @Override
    public Object purchaseContentAsync(String buyerUserId, PurchaseContentRequest request) {
        String contentId = request.getContentId();
        if (contentId == null || contentId.trim().isEmpty()) {
            Map<String, Object> err = new HashMap<>();
            err.put("isSuccess", false);
            err.put("message", "Thiếu Content ID");
            return err;
        }

        PaidContent content = paidContentRepository.findById(contentId).orElse(null);
        if (content == null) {
            Map<String, Object> err = new HashMap<>();
            err.put("isSuccess", false);
            err.put("message", "Nội dung không tồn tại");
            return err;
        }

        // Check if already purchased
        List<ContentPurchase> existingPurchases = contentPurchaseRepository
                .findByBuyerUserIdOrderByPurchasedAtDesc(buyerUserId);
        boolean alreadyPurchased = existingPurchases.stream().anyMatch(p -> p.getContentId().equals(contentId));
        if (alreadyPurchased) {
            Map<String, Object> res = new HashMap<>();
            res.put("isSuccess", true);
            res.put("message", "Đã mua nội dung này");
            return res;
        }

        BigDecimal amount = content.getPriceAmount() != null ? content.getPriceAmount() : BigDecimal.ZERO;
        Wallet buyerWallet = (Wallet) getOrCreateWalletAsync(buyerUserId);

        if (amount.compareTo(BigDecimal.ZERO) > 0) {
            if (buyerWallet.getBalance().compareTo(amount) < 0) {
                Map<String, Object> err = new HashMap<>();
                err.put("isSuccess", false);
                err.put("message", "Số dư tài khoản không đủ để thanh toán");
                return err;
            }

            // Deduct from buyer
            buyerWallet.setBalance(buyerWallet.getBalance().subtract(amount));
            walletRepository.save(buyerWallet);

            // Calculate 10% admin fee and 90% creator share
            BigDecimal adminShare = amount.multiply(new BigDecimal("0.10"));
            BigDecimal creatorShare = amount.subtract(adminShare);

            // Add 10% to admin wallet
            Wallet adminWallet = (Wallet) getOrCreateWalletAsync("Uadmin");
            adminWallet.setBalance(adminWallet.getBalance().add(adminShare));
            walletRepository.save(adminWallet);

            // Add 90% to creator/seller wallet
            String sellerUserId = content.getCreatorUserId();
            Wallet sellerWallet = (Wallet) getOrCreateWalletAsync(sellerUserId);
            sellerWallet.setBalance(sellerWallet.getBalance().add(creatorShare));
            walletRepository.save(sellerWallet);
        }

        // Save WalletTransaction
        String txId = UUID.randomUUID().toString();
        WalletTransaction tx = new WalletTransaction();
        tx.setWalletTransactionId(txId);
        tx.setWalletId(buyerWallet.getWalletId());
        tx.setUserId(buyerUserId);
        tx.setTransactionType("PURCHASE");
        tx.setDirection("OUT");
        tx.setAmount(amount);
        tx.setBalanceBefore(buyerWallet.getBalance().add(amount));
        tx.setBalanceAfter(buyerWallet.getBalance());
        tx.setTransactionStatus("SUCCESS");
        tx.setDescriptionText("Mua nội dung: " + content.getTitle());
        tx.setRelatedRefType("PAID_CONTENT");
        tx.setRelatedRefId(contentId);
        tx.setRelatedUserId(content.getCreatorUserId());
        walletTransactionRepository.save(tx);

        // Save LiveAccessTicket
        LiveAccessTicket ticket = new LiveAccessTicket();
        ticket.setTicketId(UUID.randomUUID().toString());
        ticket.setRoomId(content.getRoomId()); // nullable
        ticket.setUserId(buyerUserId);
        ticket.setWalletId(buyerWallet.getWalletId());
        ticket.setTicketStatus("ACTIVE");
        liveAccessTicketRepository.save(ticket);

        // Save ContentPurchase
        ContentPurchase purchase = new ContentPurchase(
                UUID.randomUUID().toString(),
                contentId,
                buyerUserId,
                content.getCreatorUserId(),
                amount,
                LocalDateTime.now());
        contentPurchaseRepository.save(purchase);

        Map<String, Object> res = new HashMap<>();
        res.put("isSuccess", true);
        return res;
    }

    @Override
    public Object purchaseLiveAsync(String buyerUserId, PurchaseLiveRequest request) {
        return new HashMap<>();
    }

    @Override
    public Object donateAsync(String fromUserId, DonateRequest request) {
        System.out
                .println("DEBUG: donateAsync - fromUserId: " + fromUserId + ", request amount: " + request.getAmount());
        Wallet fromWallet = (Wallet) getOrCreateWalletAsync(fromUserId);
        System.out.println("DEBUG: fromWallet balance: " + fromWallet.getBalance());
        if (fromWallet.getBalance().compareTo(request.getAmount()) < 0) {
            System.out.println("DEBUG: Insufficient balance! wallet balance " + fromWallet.getBalance()
                    + " is less than request amount " + request.getAmount());
            Map<String, Object> err = new HashMap<>();
            err.put("isSuccess", false);
            err.put("message", "Số dư không đủ");
            return err;
        }

        String toUserId = request.getToUserId();
        if (toUserId == null || toUserId.trim().isEmpty()) {
            if (request.getRoomId() != null) {
                Room room = roomRepository.findById(request.getRoomId()).orElse(null);
                if (room != null) {
                    toUserId = room.getHostUserId();
                }
            }
        }

        if (toUserId == null || toUserId.trim().isEmpty()) {
            Map<String, Object> err = new HashMap<>();
            err.put("isSuccess", false);
            err.put("message", "Không tìm thấy người nhận");
            return err;
        }

        // Determine if receiver is a Super Mentor (R004) or standard Mentor (R003)
        boolean isSuperMentor = false;
        List<UserRole> userRoles = userRoleRepository.findByUserId(toUserId);
        for (UserRole ur : userRoles) {
            if ("R004".equalsIgnoreCase(ur.getRoleId())) {
                isSuperMentor = true;
                break;
            }
        }

        // Calculate platform fee and mentor share
        BigDecimal totalAmount = request.getAmount();
        BigDecimal platformFeePercent = isSuperMentor ? new BigDecimal("0.10") : new BigDecimal("0.20");
        BigDecimal platformFee = totalAmount.multiply(platformFeePercent);
        BigDecimal mentorShare = totalAmount.subtract(platformFee);

        // Update wallets
        Wallet toWallet = (Wallet) getOrCreateWalletAsync(toUserId);
        Wallet adminWallet = (Wallet) getOrCreateWalletAsync("Uadmin");

        fromWallet.setBalance(fromWallet.getBalance().subtract(totalAmount));
        toWallet.setBalance(toWallet.getBalance().add(mentorShare));
        adminWallet.setBalance(adminWallet.getBalance().add(platformFee));

        walletRepository.save(fromWallet);
        walletRepository.save(toWallet);
        walletRepository.save(adminWallet);

        // Save WalletTransaction for the sender
        WalletTransaction tx = new WalletTransaction();
        String txId = UUID.randomUUID().toString();
        tx.setWalletTransactionId(txId);
        tx.setWalletId(fromWallet.getWalletId());
        tx.setUserId(fromUserId);
        tx.setRelatedUserId(toUserId);
        tx.setTransactionType("GIFT");
        tx.setDirection("OUT");
        tx.setAmount(totalAmount);
        tx.setBalanceBefore(fromWallet.getBalance().add(totalAmount));
        tx.setBalanceAfter(fromWallet.getBalance());
        tx.setRelatedRefType("ROOM");
        tx.setRelatedRefId(request.getRoomId());
        tx.setDescriptionText(request.getMessageText());
        walletTransactionRepository.save(tx);

        // Log Donation to donations table
        BigDecimal giftPrice = totalAmount;
        int qty = request.getQuantity() != null ? request.getQuantity() : 1;

        Gift giftObj = giftRepository.findById(request.getGiftId()).orElse(null);
        if (giftObj != null) {
            giftPrice = giftObj.getPriceAmount();
        } else if (qty > 0) {
            giftPrice = totalAmount.divide(new BigDecimal(qty), 2, BigDecimal.ROUND_HALF_UP);
        }

        Donation donation = new Donation();
        donation.setDonationId(UUID.randomUUID().toString());
        donation.setFromUserId(fromUserId);
        donation.setToUserId(toUserId);
        donation.setRoomId(request.getRoomId());
        donation.setGiftId(request.getGiftId());
        donation.setQuantity(qty);
        donation.setAmount(giftPrice);
        donation.setTotalAmount(totalAmount);
        donation.setWalletTransactionId(txId);
        donation.setMessageText(request.getMessageText());
        donationRepository.save(donation);

        // Fetch display name from AvatarPersonas
        String displayName = fromUserId;
        AvatarPersona persona = avatarPersonaRepository.findById(fromUserId).orElse(null);
        if (persona != null && persona.getDisplayName() != null) {
            displayName = persona.getDisplayName();
        }

        // Fetch gift icon url
        String iconUrl = "🎁";
        if (request.getGiftId() != null) {
            Gift gift = giftRepository.findById(request.getGiftId()).orElse(null);
            if (gift != null && gift.getIconUrl() != null) {
                iconUrl = gift.getIconUrl();
            }
        }

        Map<String, Object> res = new HashMap<>();
        res.put("isSuccess", true);
        res.put("displayName", displayName);
        res.put("iconUrl", iconUrl);
        res.put("messageText", request.getMessageText());
        return res;
    }

    @Override
    public List<Object> getWithdrawRequestsAsync(String status) {
        List<WithdrawalRequest> requests = withdrawalRequestRepository.findAllByOrderByRequestedAtDesc();
        if (status != null && !status.trim().isEmpty()) {
            requests = requests.stream().filter(r -> status.equalsIgnoreCase(r.getRequestStatus())).toList();
        }
        return new ArrayList<>(requests);
    }

    @Override
    public Object withdrawAsync(String userId, WithdrawRequest request) {
        Wallet wallet = (Wallet) getOrCreateWalletAsync(userId);
        if (wallet.getBalance().compareTo(request.getAmount()) < 0) {
            Map<String, Object> err = new HashMap<>();
            err.put("isSuccess", false);
            err.put("message", "Số dư không đủ để rút tiền");
            return err;
        }

        WithdrawalRequest req = new WithdrawalRequest();
        req.setWithdrawRequestId(UUID.randomUUID().toString());
        req.setUserId(userId);
        req.setWalletId(wallet.getWalletId());
        req.setAmount(request.getAmount());
        req.setBankName(request.getBankName());
        req.setBankAccountNumber(request.getBankAccountNumber());
        req.setBankAccountName(request.getBankAccountName());
        req.setRequestStatus("PENDING");
        req.setRequestedAt(LocalDateTime.now());
        withdrawalRequestRepository.save(req);

        Map<String, Object> res = new HashMap<>();
        res.put("isSuccess", true);
        res.put("data", req);
        return res;
    }

    @Override
    public Object approveWithdrawAsync(String withdrawRequestId) {
        WithdrawalRequest req = withdrawalRequestRepository.findById(withdrawRequestId).orElse(null);
        if (req == null || !"PENDING".equals(req.getRequestStatus())) {
            Map<String, Object> err = new HashMap<>();
            err.put("isSuccess", false);
            err.put("message", "Request not found or not pending");
            return err;
        }

        req.setRequestStatus("APPROVED");
        withdrawalRequestRepository.save(req);

        Wallet wallet = walletRepository.findById(req.getWalletId()).orElse(null);
        if (wallet != null) {
            wallet.setBalance(wallet.getBalance().subtract(req.getAmount()));
            walletRepository.save(wallet);
        }

        Map<String, Object> res = new HashMap<>();
        res.put("isSuccess", true);
        return res;
    }

    @Override
    public Object rejectWithdrawAsync(String withdrawRequestId, String rejectReason) {
        WithdrawalRequest req = withdrawalRequestRepository.findById(withdrawRequestId).orElse(null);
        if (req != null && "PENDING".equals(req.getRequestStatus())) {
            req.setRequestStatus("REJECTED");
            req.setRejectReason(rejectReason);
            withdrawalRequestRepository.save(req);
        }
        Map<String, Object> res = new HashMap<>();
        res.put("isSuccess", true);
        return res;
    }

    @Override
    public List<Object> getGiftsAsync() {
        return new ArrayList<>(giftRepository.findAll());
    }
}
