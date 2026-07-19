package com.lucy.backend.payment.entity;

import jakarta.persistence.*;
import lombok.Data;
import java.math.BigDecimal;
import java.time.LocalDateTime;

@Entity
@Table(name = "wallets")
@Data
public class Wallet {
    @Id
    @Column(name = "WalletId", length = 36)
    private String walletId;

    @Column(name = "UserId", length = 36, nullable = false)
    private String userId;

    @Column(name = "Balance", precision = 18, scale = 2, nullable = false)
    private BigDecimal balance = BigDecimal.ZERO;

    @Column(name = "CurrencyCode", length = 10, nullable = false)
    private String currencyCode = "XU";

    @Column(name = "WalletStatus", length = 20)
    private String walletStatus = "ACTIVE";

    @Column(name = "CreatedAt", updatable = false)
    private LocalDateTime createdAt = LocalDateTime.now();
}
