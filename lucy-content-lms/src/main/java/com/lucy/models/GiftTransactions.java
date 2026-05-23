package com.lucy.models;

import java.math.BigDecimal;
import java.util.Date;

public class GiftTransactions {
    private String GiftTransactionId;
    private String SenderId;
    private String ReceiverId;
    private String RoomId;
    private String GiftTypeId;
    private int Quantity;
    private BigDecimal TotalAmount;
    private Date CreatedAt;

    public GiftTransactions() {
    }

    public GiftTransactions(String GiftTransactionId, String SenderId, String ReceiverId, String RoomId,
            String GiftTypeId, int Quantity, BigDecimal TotalAmount, Date CreatedAt) {
        this.GiftTransactionId = GiftTransactionId;
        this.SenderId = SenderId;
        this.ReceiverId = ReceiverId;
        this.RoomId = RoomId;
        this.GiftTypeId = GiftTypeId;
        this.Quantity = Quantity;
        this.TotalAmount = TotalAmount;
        this.CreatedAt = CreatedAt;
    }

    public String getGiftTransactionId() {
        return this.GiftTransactionId;
    }

    public void setGiftTransactionId(String GiftTransactionId) {
        this.GiftTransactionId = GiftTransactionId;
    }

    public String getSenderId() {
        return this.SenderId;
    }

    public void setSenderId(String SenderId) {
        this.SenderId = SenderId;
    }

    public String getReceiverId() {
        return this.ReceiverId;
    }

    public void setReceiverId(String ReceiverId) {
        this.ReceiverId = ReceiverId;
    }

    public String getRoomId() {
        return this.RoomId;
    }

    public void setRoomId(String RoomId) {
        this.RoomId = RoomId;
    }

    public String getGiftTypeId() {
        return this.GiftTypeId;
    }

    public void setGiftTypeId(String GiftTypeId) {
        this.GiftTypeId = GiftTypeId;
    }

    public int getQuantity() {
        return this.Quantity;
    }

    public void setQuantity(int Quantity) {
        this.Quantity = Quantity;
    }

    public BigDecimal getTotalAmount() {
        return this.TotalAmount;
    }

    public void setTotalAmount(BigDecimal TotalAmount) {
        this.TotalAmount = TotalAmount;
    }

    public Date getCreatedAt() {
        return this.CreatedAt;
    }

    public void setCreatedAt(Date CreatedAt) {
        this.CreatedAt = CreatedAt;
    }
}