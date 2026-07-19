package com.lucy.backend.payment.controller;

import com.lucy.backend.payment.dto.*;
import com.lucy.backend.payment.service.IPaymentService;
import jakarta.servlet.http.HttpServletRequest;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

@RestController
@RequestMapping("/api/payment")
@CrossOrigin(originPatterns = "*")
public class PaymentController {

    private final IPaymentService paymentService;

    public PaymentController(IPaymentService paymentService) {
        this.paymentService = paymentService;
    }

    private String getCurrentUserId(HttpServletRequest request) {
        String userId = null;
        if (org.springframework.security.core.context.SecurityContextHolder.getContext().getAuthentication() != null) {
            userId = org.springframework.security.core.context.SecurityContextHolder.getContext().getAuthentication().getName();
        }
        if (userId == null || userId.trim().isEmpty() || "anonymousUser".equals(userId)) {
            userId = request.getHeader("X-User-Id");
        }
        if (userId == null || userId.trim().isEmpty()) {
            throw new RuntimeException("Missing X-User-Id header.");
        }
        return userId;
    }

    private void ensureAdmin(HttpServletRequest request) {
        if (!"Uadmin".equalsIgnoreCase(getCurrentUserId(request))) {
            throw new RuntimeException("Admin permission is required.");
        }
    }

    @GetMapping("/wallet")
    public ResponseEntity<?> getWallet(HttpServletRequest request) {
        return ResponseEntity.ok(paymentService.getOrCreateWalletAsync(getCurrentUserId(request)));
    }

    @GetMapping("/transactions")
    public ResponseEntity<?> getTransactions(HttpServletRequest request) {
        return ResponseEntity.ok(paymentService.getTransactionsAsync(getCurrentUserId(request)));
    }

    @GetMapping("/gifts")
    public ResponseEntity<?> getGifts() {
        return ResponseEntity.ok(paymentService.getGiftsAsync());
    }

    @PostMapping("/deposit")
    public ResponseEntity<?> deposit(HttpServletRequest request, @RequestBody DepositRequest depositRequest) {
        return ResponseEntity.ok(paymentService.depositAsync(getCurrentUserId(request), depositRequest));
    }

    @PostMapping("/purchase/content")
    public ResponseEntity<?> purchaseContent(HttpServletRequest request, @RequestBody PurchaseContentRequest purchaseRequest) {
        return ResponseEntity.ok(paymentService.purchaseContentAsync(getCurrentUserId(request), purchaseRequest));
    }

    @PostMapping("/purchase/live")
    public ResponseEntity<?> purchaseLive(HttpServletRequest request, @RequestBody PurchaseLiveRequest purchaseRequest) {
        return ResponseEntity.ok(paymentService.purchaseLiveAsync(getCurrentUserId(request), purchaseRequest));
    }

    @PostMapping("/donate")
    public ResponseEntity<?> donate(HttpServletRequest request, @RequestBody DonateRequest donateRequest) {
        return ResponseEntity.ok(paymentService.donateAsync(getCurrentUserId(request), donateRequest));
    }

    @PostMapping("/transfer")
    public ResponseEntity<?> transfer(HttpServletRequest request, @RequestBody TransferRequest transferRequest) {
        String type = transferRequest.getTransferType() != null ? transferRequest.getTransferType().trim().toLowerCase() : "";
        if ("buypodcast".equals(type)) {
            PurchaseContentRequest pcr = new PurchaseContentRequest();
            pcr.setContentId(transferRequest.getRefId() != null ? transferRequest.getRefId() : transferRequest.getToUserId());
            return ResponseEntity.ok(paymentService.purchaseContentAsync(getCurrentUserId(request), pcr));
        }
        if ("paylive".equals(type)) {
            PurchaseLiveRequest plr = new PurchaseLiveRequest();
            plr.setRoomId(transferRequest.getRefId() != null ? transferRequest.getRefId() : transferRequest.getToUserId());
            return ResponseEntity.ok(paymentService.purchaseLiveAsync(getCurrentUserId(request), plr));
        }
        if (transferRequest.getToUserId() == null || transferRequest.getToUserId().trim().isEmpty()) {
            throw new RuntimeException("ToUserId is required for donate transfer.");
        }
        DonateRequest dr = new DonateRequest();
        dr.setToUserId(transferRequest.getToUserId());
        dr.setAmount(transferRequest.getAmount());
        dr.setRoomId(transferRequest.getRefId());
        dr.setMessageText(transferRequest.getMessageText());
        return ResponseEntity.ok(paymentService.donateAsync(getCurrentUserId(request), dr));
    }

    @PostMapping("/withdraw")
    public ResponseEntity<?> withdraw(HttpServletRequest request, @RequestBody WithdrawRequest withdrawRequest) {
        return ResponseEntity.ok(paymentService.withdrawAsync(getCurrentUserId(request), withdrawRequest));
    }

    @GetMapping("/admin/settings/momo")
    public ResponseEntity<?> getMomoSetting(HttpServletRequest request) {
        ensureAdmin(request);
        return ResponseEntity.ok(paymentService.getMomoSettingAsync());
    }

    @GetMapping("/settings/momo")
    public ResponseEntity<?> getMomoSettingPublic(HttpServletRequest request) {
        return ResponseEntity.ok(paymentService.getMomoSettingAsync());
    }

    @PostMapping("/admin/settings/momo")
    public ResponseEntity<?> saveMomoSetting(HttpServletRequest request, @RequestBody SavePaymentSettingRequest saveRequest) {
        ensureAdmin(request);
        return ResponseEntity.ok(paymentService.saveMomoSettingAsync(saveRequest));
    }

    @PostMapping("/admin/settings/momo/qr")
    public ResponseEntity<?> uploadMomoQr(HttpServletRequest request, @RequestParam("file") MultipartFile file) {
        ensureAdmin(request);
        return ResponseEntity.ok(paymentService.uploadMomoQrAsync(file));
    }

    @GetMapping("/admin/topup-orders")
    public ResponseEntity<?> getTopUpOrders(HttpServletRequest request, @RequestParam(value = "status", required = false) String status) {
        ensureAdmin(request);
        return ResponseEntity.ok(paymentService.getTopUpOrdersAsync(status));
    }

    @PostMapping("/admin/topup-orders/{topUpOrderId}/approve")
    public ResponseEntity<?> approveTopUpOrder(HttpServletRequest request, @PathVariable String topUpOrderId) {
        ensureAdmin(request);
        return ResponseEntity.ok(paymentService.approveTopUpOrderAsync(topUpOrderId));
    }

    @PostMapping("/admin/topup-orders/{topUpOrderId}/reject")
    public ResponseEntity<?> rejectTopUpOrder(HttpServletRequest request, @PathVariable String topUpOrderId, @RequestBody(required = false) RejectTopUpRequest rejectRequest) {
        ensureAdmin(request);
        String reason = rejectRequest != null ? rejectRequest.getReason() : null;
        return ResponseEntity.ok(paymentService.rejectTopUpOrderAsync(topUpOrderId, reason));
    }

    @GetMapping("/admin/withdraw-requests")
    public ResponseEntity<?> getWithdrawRequests(HttpServletRequest request, @RequestParam(value = "status", required = false) String status) {
        ensureAdmin(request);
        return ResponseEntity.ok(paymentService.getWithdrawRequestsAsync(status));
    }

    @PostMapping("/admin/withdraw/approve/{withdrawRequestId}")
    public ResponseEntity<?> approveWithdraw(HttpServletRequest request, @PathVariable String withdrawRequestId) {
        ensureAdmin(request);
        return ResponseEntity.ok(paymentService.approveWithdrawAsync(withdrawRequestId));
    }

    @PostMapping("/admin/withdraw/reject/{withdrawRequestId}")
    public ResponseEntity<?> rejectWithdraw(HttpServletRequest request, @PathVariable String withdrawRequestId, @RequestBody(required = false) RejectWithdrawRequest rejectRequest) {
        ensureAdmin(request);
        String reason = rejectRequest != null ? rejectRequest.getRejectReason() : null;
        return ResponseEntity.ok(paymentService.rejectWithdrawAsync(withdrawRequestId, reason));
    }
}
