package com.lucy.backend.payment.service;

import com.lucy.backend.payment.dto.*;
import org.springframework.web.multipart.MultipartFile;
import java.util.List;

public interface IPaymentService {
    Object getOrCreateWalletAsync(String userId);
    List<Object> getTransactionsAsync(String userId);
    Object depositAsync(String userId, DepositRequest request);
    Object getMomoSettingAsync();
    Object saveMomoSettingAsync(SavePaymentSettingRequest request);
    Object uploadMomoQrAsync(MultipartFile file);
    List<Object> getTopUpOrdersAsync(String status);
    Object approveTopUpOrderAsync(String topUpOrderId);
    Object rejectTopUpOrderAsync(String topUpOrderId, String reason);
    Object purchaseContentAsync(String buyerUserId, PurchaseContentRequest request);
    Object purchaseLiveAsync(String buyerUserId, PurchaseLiveRequest request);
    Object donateAsync(String fromUserId, DonateRequest request);
    List<Object> getWithdrawRequestsAsync(String status);
    Object withdrawAsync(String userId, WithdrawRequest request);
    Object approveWithdrawAsync(String withdrawRequestId);
    Object rejectWithdrawAsync(String withdrawRequestId, String rejectReason);
    List<Object> getGiftsAsync();
}
