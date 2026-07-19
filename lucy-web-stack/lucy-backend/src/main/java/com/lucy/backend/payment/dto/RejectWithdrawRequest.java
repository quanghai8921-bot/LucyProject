package com.lucy.backend.payment.dto;

import lombok.Data;

@Data
public class RejectWithdrawRequest {
    private String rejectReason;
}
