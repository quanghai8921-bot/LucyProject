package com.lucy.backend.payment.entity;

import jakarta.persistence.*;
import lombok.Data;
import java.time.LocalDateTime;

@Entity
@Table(name = "PaymentSettings")
@Data
public class PaymentSetting {
    @Id
    @Column(name = "PaymentSettingId", length = 50)
    private String paymentSettingId;

    @Column(name = "ProviderCode", length = 50, nullable = false)
    private String providerCode;

    @Column(name = "ReceiverUserId", length = 50, nullable = false)
    private String receiverUserId;

    @Column(name = "ReceiverName", length = 100, nullable = false)
    private String receiverName;

    @Column(name = "ReceiverPhone", length = 20, nullable = false)
    private String receiverPhone;

    @Column(name = "QrImageUrl", length = 255)
    private String qrImageUrl;

    @Column(name = "TransferContentTemplate", length = 255, nullable = false)
    private String transferContentTemplate;

    @Column(name = "IsActive", nullable = false)
    private Integer isActive = 1;

    @Column(name = "CreatedAt", nullable = false)
    private LocalDateTime createdAt = LocalDateTime.now();

    @Column(name = "UpdatedAt")
    private LocalDateTime updatedAt;
}
