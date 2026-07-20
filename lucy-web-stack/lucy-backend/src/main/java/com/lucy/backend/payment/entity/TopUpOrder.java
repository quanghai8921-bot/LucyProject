package com.lucy.backend.payment.entity;

import jakarta.persistence.*;
import lombok.Data;
import java.math.BigDecimal;
import java.time.LocalDateTime;

@Entity
@Table(name = "TopUpOrders")
@Data
public class TopUpOrder {
    @Id
    @Column(name = "TopUpOrderId", length = 50)
    private String topUpOrderId;

    @Column(name = "UserId", length = 50, nullable = false)
    private String userId;

    @Column(name = "WalletId", length = 50, nullable = false)
    private String walletId;

    @Column(name = "Amount", nullable = false)
    private BigDecimal amount;

    @Column(name = "PaymentProvider", length = 50)
    private String paymentProvider;

    @Column(name = "OrderStatus", length = 30, nullable = false)
    private String orderStatus = "PENDING";

    @Column(name = "CreatedAt", nullable = false)
    private LocalDateTime createdAt = LocalDateTime.now();

    @Column(name = "PaidAt")
    private LocalDateTime paidAt;
}
