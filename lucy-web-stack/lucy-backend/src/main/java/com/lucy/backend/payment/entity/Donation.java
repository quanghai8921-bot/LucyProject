package com.lucy.backend.payment.entity;

import jakarta.persistence.*;
import lombok.Data;
import java.math.BigDecimal;
import java.time.LocalDateTime;

@Entity
@Table(name = "Donations")
@Data
public class Donation {
    @Id
    @Column(name = "DonationId", length = 50)
    private String donationId;

    @Column(name = "GiftId", length = 50, nullable = false)
    private String giftId;

    @Column(name = "FromUserId", length = 50, nullable = false)
    private String fromUserId;

    @Column(name = "ToUserId", length = 50, nullable = false)
    private String toUserId;

    @Column(name = "RoomId", length = 50, nullable = false)
    private String roomId;

    @Column(name = "Quantity", nullable = false)
    private Integer quantity = 1;

    @Column(name = "Amount", precision = 12, scale = 2, nullable = false)
    private BigDecimal amount;

    @Column(name = "TotalAmount", precision = 12, scale = 2, nullable = false)
    private BigDecimal totalAmount;

    @Column(name = "WalletTransactionId", length = 50, nullable = false)
    private String walletTransactionId;

    @Column(name = "MessageText", length = 255)
    private String messageText;

    @Column(name = "CreatedAt", updatable = false)
    private LocalDateTime createdAt = LocalDateTime.now();
}
