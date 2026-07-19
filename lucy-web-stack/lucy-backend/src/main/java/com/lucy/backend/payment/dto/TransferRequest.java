package com.lucy.backend.payment.dto;

import lombok.Data;
import java.math.BigDecimal;

@Data
public class TransferRequest {
    private String transferType;
    private String toUserId;
    private BigDecimal amount;
    private String refId;
    private String messageText;
}
