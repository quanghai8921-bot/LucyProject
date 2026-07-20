package com.lucy.backend.payment.entity;

import jakarta.persistence.*;
import lombok.Data;
import java.math.BigDecimal;
import java.time.LocalDateTime;

@Entity
@Table(name = "WithdrawRequests")
@Data
public class WithdrawalRequest {
    @Id
    @Column(name = "WithdrawRequestId", length = 50)
    private String withdrawRequestId;

    @Column(name = "UserId", length = 50, nullable = false)
    private String userId;

    @Column(name = "WalletId", length = 50, nullable = false)
    private String walletId;

    @Column(name = "Amount", nullable = false)
    private BigDecimal amount;

    @Column(name = "BankName", length = 100, nullable = false)
    private String bankName;

    @Column(name = "BankAccountNumber", length = 50, nullable = false)
    private String bankAccountNumber;

    @Column(name = "BankAccountName", length = 100, nullable = false)
    private String bankAccountName;

    @Column(name = "RequestStatus", length = 30, nullable = false)
    private String requestStatus = "PENDING";

    @Column(name = "RejectReason", length = 255)
    private String rejectReason;

    @Column(name = "RequestedAt", updatable = false)
    private LocalDateTime requestedAt = LocalDateTime.now();

}
