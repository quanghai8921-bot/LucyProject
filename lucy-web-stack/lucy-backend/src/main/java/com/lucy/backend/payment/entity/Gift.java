package com.lucy.backend.payment.entity;

import jakarta.persistence.*;
import lombok.Data;
import java.math.BigDecimal;
import java.time.LocalDateTime;

@Entity
@Table(name = "Gifts")
@Data
public class Gift {
    @Id
    @Column(name = "GiftId", length = 50)
    private String giftId;

    @Column(name = "GiftName", length = 100, nullable = false)
    private String giftName;

    @Column(name = "PriceAmount", precision = 12, scale = 2, nullable = false)
    private BigDecimal priceAmount;

    @Column(name = "IconUrl", length = 255)
    private String iconUrl;

    @Column(name = "IsActive", nullable = false)
    private Integer isActive = 1;

    @Column(name = "CreatedAt", updatable = false)
    private LocalDateTime createdAt = LocalDateTime.now();
}
