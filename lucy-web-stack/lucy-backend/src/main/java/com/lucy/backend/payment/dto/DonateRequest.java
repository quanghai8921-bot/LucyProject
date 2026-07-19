package com.lucy.backend.payment.dto;

import lombok.Data;
import java.math.BigDecimal;

@Data
public class DonateRequest {
    private String toUserId;
    private BigDecimal amount;
    private String roomId;
    private String messageText;
    private String giftId;
    private Integer quantity;
}
