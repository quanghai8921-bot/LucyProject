package com.lucy.lms.mentor.dto;

import java.math.BigDecimal;

public class SendGiftRequest {

    private String senderId;
    private String toUserId;
    private BigDecimal amount;
    private String messageText;
    private String giftName;
    private String giftType;
    private String senderDisplayName;

    public String getSenderId() {
        return senderId;
    }

    public String getToUserId() {
        return toUserId;
    }

    public BigDecimal getAmount() {
        return amount;
    }

    public String getMessageText() {
        return messageText;
    }

    public String getGiftName() {
        return giftName;
    }

    public String getGiftType() {
        return giftType;
    }

    public String getSenderDisplayName() {
        return senderDisplayName;
    }
}
