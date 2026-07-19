package com.lucy.backend.payment.entity;

import jakarta.persistence.*;
import lombok.Data;
import java.math.BigDecimal;
import java.time.LocalDateTime;

@Entity
@Table(name = "WalletTransactions")
@Data
public class WalletTransaction {
    @Id
    @Column(name = "WalletTransactionId", length = 50)
    private String walletTransactionId;

    @Column(name = "WalletId", length = 50, nullable = false)
    private String walletId;

    @Column(name = "UserId", length = 50, nullable = false)
    private String userId;

    @Column(name = "RelatedUserId", length = 50)
    private String relatedUserId;

    @Column(name = "TransactionType", length = 50, nullable = false)
    private String transactionType;

    @Column(name = "Direction", length = 10, nullable = false)
    private String direction;

    @Column(name = "Amount", precision = 12, scale = 2, nullable = false)
    private BigDecimal amount;

    @Column(name = "BalanceBefore", precision = 12, scale = 2, nullable = false)
    private BigDecimal balanceBefore = BigDecimal.ZERO;

    @Column(name = "BalanceAfter", precision = 12, scale = 2, nullable = false)
    private BigDecimal balanceAfter = BigDecimal.ZERO;

    @Column(name = "RelatedRefType", length = 50)
    private String relatedRefType;

    @Column(name = "RelatedRefId", length = 50)
    private String relatedRefId;

    @Column(name = "DescriptionText", length = 255)
    private String descriptionText;

    @Column(name = "TransactionStatus", length = 30, nullable = false)
    private String transactionStatus = "SUCCESS";

    @Column(name = "CreatedAt", updatable = false)
    private LocalDateTime createdAt = LocalDateTime.now();
}
