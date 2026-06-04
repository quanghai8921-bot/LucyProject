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
    private String userId;

    @Column(name = "Title", length = 150, nullable = false)
    private String title;

    @Column(name = "BodyText", length = 255, nullable = false)
    private String bodyText;

    @Column(name = "NotificationType", length = 50, nullable = false)
    private String notificationType;

    @Column(name = "RefType", length = 50)
    private String refType;

    @Column(name = "IsRead", nullable = false)
    private Integer isRead;

    @Column(name = "CreatedAt")
    private LocalDateTime createdAt;

    protected Notification() {
    }

    public Notification(String notificationId, String userId, String title, String bodyText,
                        String notificationType, String refType, Integer isRead, LocalDateTime createdAt) {
        this.notificationId = notificationId;
        this.userId = userId;
        this.title = title;
        this.bodyText = bodyText;
        this.notificationType = notificationType;
        this.refType = refType;
        this.isRead = isRead;
        this.createdAt = createdAt;
    }

    public String getNotificationId() {
        return notificationId;
    }

    public String getUserId() {
        return userId;
    }

    public String getTitle() {
        return title;
    }

    public String getBodyText() {
        return bodyText;
    }

    public String getNotificationType() {
        return notificationType;
    }

    public String getRefType() {
        return refType;
    }

    public Integer getIsRead() {
        return isRead;
    }

    public LocalDateTime getCreatedAt() {
        return createdAt;
    }
}
