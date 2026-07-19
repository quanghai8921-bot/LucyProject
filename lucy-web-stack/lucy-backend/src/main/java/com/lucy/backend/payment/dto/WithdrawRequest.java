package com.lucy.backend.payment.dto;

import lombok.Data;
import java.math.BigDecimal;

@Data
public class WithdrawRequest {
    private BigDecimal amount;
    private String bankName;
    private String bankAccountName;
    private String bankAccountNumber;
}
