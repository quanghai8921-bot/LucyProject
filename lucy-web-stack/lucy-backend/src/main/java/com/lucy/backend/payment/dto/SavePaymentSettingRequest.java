package com.lucy.backend.payment.dto;

import lombok.Data;

@Data
public class SavePaymentSettingRequest {
    private String receiverUserId;
    private String receiverName;
    private String receiverPhone;
    private String transferContentTemplate;
    private String qrImageUrl;
}
