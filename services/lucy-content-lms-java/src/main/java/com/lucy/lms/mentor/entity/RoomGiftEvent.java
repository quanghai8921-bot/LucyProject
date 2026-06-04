package com.lucy.lms.mentor.entity;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import jakarta.persistence.Transient;

import java.math.BigDecimal;
import java.time.LocalDateTime;

/**
 * Sự kiện tặng quà / donate từ learner cho mentor trong phòng Live.
 * Được ánh xạ vào bảng Donations trong database.
 */
@Entity
@Table(name = "Donations")
public class RoomGiftEvent {

    @Id
    @Column(name = "DonationId", length = 50)
    private String giftEventId;

    @Column(name = "RoomId", length = 50)
    private String roomId;

    @Column(name = "FromUserId", length = 50, nullable = false)
    private String senderId;

    @Column(name = "ToUserId", length = 50, nullable = false)
    private String toUserId;

    @Column(name = "Amount", nullable = false)
    private BigDecimal creditValue;

    @Column(name = "MessageText", length = 255)
    private String messageText;

    @Column(name = "FromWalletTransactionId", length = 50)
    private String fromWalletTransactionId;

    @Column(name = "ToWalletTransactionId", length = 50)
    private String toWalletTransactionId;

    @Column(name = "CreatedAt", nullable = false)
    private LocalDateTime sentAt;

    /** Trường phụ không map xuống database. */
    @Transient
    private String senderDisplayName;

    @Transient
    private String giftType; // GIFT | DONATE

    @Transient
    private String giftName;

    protected RoomGiftEvent() {
    }

    public RoomGiftEvent(String giftEventId, String roomId, String senderId, String toUserId,
                         BigDecimal creditValue, String messageText, LocalDateTime sentAt) {
        this.giftEventId = giftEventId;
        this.roomId = roomId;
        this.senderId = senderId;
        this.toUserId = toUserId;
        this.creditValue = creditValue;
        this.messageText = messageText;
        this.sentAt = sentAt;
    }

    public String getGiftEventId() { return giftEventId; }
    public String getRoomId() { return roomId; }
    public String getSenderId() { return senderId; }
    public String getToUserId() { return toUserId; }
    public BigDecimal getCreditValue() { return creditValue; }
    public String getMessageText() { return messageText; }
    public String getFromWalletTransactionId() { return fromWalletTransactionId; }
    public String getToWalletTransactionId() { return toWalletTransactionId; }
    public LocalDateTime getSentAt() { return sentAt; }

    public String getSenderDisplayName() { return senderDisplayName; }
    public void setSenderDisplayName(String senderDisplayName) { this.senderDisplayName = senderDisplayName; }

    public String getGiftType() { return giftType; }
    public void setGiftType(String giftType) { this.giftType = giftType; }

    public String getGiftName() { return giftName; }
    public void setGiftName(String giftName) { this.giftName = giftName; }
}
