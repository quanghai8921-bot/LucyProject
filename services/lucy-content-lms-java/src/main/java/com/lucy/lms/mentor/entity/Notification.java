package com.lucy.lms.mentor.entity;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.Table;

import java.time.LocalDateTime;

@Entity
@Table(name = "Notifications")
public class Notification {

    @Id
    @Column(name = "NotificationId", length = 50)
    private String notificationId;

    @Column(name = "UserId", length = 50, nullable = false)
    private String recipientUserId;

    @Column(name = "Title", length = 255, nullable = false)
    private String title;

    @Column(name = "BodyText", length = 1000)
    private String bodyText;

    @Column(name = "SenderId", length = 50)
    private String senderUserId;

    @Column(name = "Reference", length = 200)
    private String reference;

    @Column(name = "IsRead", nullable = false)
    private Integer isRead;

    @Column(name = "CreatedAt", nullable = false)
    private LocalDateTime createdAt;

    protected Notification() {
    }

    public Notification(String notificationId, String recipientUserId, String title, String bodyText,
                        String senderUserId, String reference, Integer isRead, LocalDateTime createdAt) {
        this.notificationId = notificationId;
        this.recipientUserId = recipientUserId;
        this.title = title;
        this.bodyText = bodyText;
        this.senderUserId = senderUserId;
        this.reference = reference;
        this.isRead = isRead;
        this.createdAt = createdAt;
    }

    public String getNotificationId() {
        return notificationId;
    }

    public String getRecipientUserId() {
        return recipientUserId;
    }

    public String getTitle() {
        return title;
    }

    public String getBodyText() {
        return bodyText;
    }

    public String getSenderUserId() {
        return senderUserId;
    }

    public String getReference() {
        return reference;
    }

    public Integer getIsRead() {
        return isRead;
    }

    public LocalDateTime getCreatedAt() {
        return createdAt;
    }
}
