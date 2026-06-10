package com.lucy.lms.creator.entity;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.Table;

import java.math.BigDecimal;
import java.time.LocalDateTime;

@Entity
@Table(name = "PaidContents")
public class PaidContent {

    @Id
    @Column(name = "ContentId", length = 50)
    private String contentId;

    @Column(name = "CreatorUserId", length = 50, nullable = false)
    private String creatorUserId;

    @Column(name = "RoomId", length = 50)
    private String roomId;

    @Column(name = "RecordingId", length = 50)
    private String recordingId;

    @Column(name = "ContentType", length = 30, nullable = false)
    private String contentType;

    @Column(name = "Title", length = 150, nullable = false)
    private String title;

    @Column(name = "DescriptionText")
    private String descriptionText;

    @Column(name = "ThumbnailUrl", length = 255)
    private String thumbnailUrl;

    @Column(name = "AudioUrl", length = 255)
    private String audioUrl;

    @Column(name = "PriceAmount", nullable = false)
    private BigDecimal priceAmount;

    @Column(name = "ContentStatus", length = 30, nullable = false)
    private String contentStatus;

    @Column(name = "PublishedAt")
    private LocalDateTime publishedAt;

    protected PaidContent() {
    }

    public PaidContent(String contentId, String creatorUserId, String contentType, String title,
            String descriptionText, String mediaUrl, BigDecimal priceAmount, String contentStatus,
            LocalDateTime publishedAt) {
        this.contentId = contentId;
        this.creatorUserId = creatorUserId;
        this.contentType = contentType;
        this.title = title;
        this.descriptionText = descriptionText;
        this.audioUrl = mediaUrl;
        this.priceAmount = priceAmount;
        this.contentStatus = contentStatus;
        this.publishedAt = publishedAt;
    }

    public String getContentId() {
        return contentId;
    }

    public String getCreatorUserId() {
        return creatorUserId;
    }

    public String getContentType() {
        return contentType;
    }

    public String getTitle() {
        return title;
    }

    public void setTitle(String title) {
        this.title = title;
    }

    public String getDescriptionText() {
        return descriptionText;
    }

    public void setDescriptionText(String descriptionText) {
        this.descriptionText = descriptionText;
    }

    public String getMediaUrl() {
        return audioUrl;
    }

    public void setMediaUrl(String mediaUrl) {
        this.audioUrl = mediaUrl;
    }

    public BigDecimal getPriceAmount() {
        return priceAmount;
    }

    public void setPriceAmount(BigDecimal priceAmount) {
        this.priceAmount = priceAmount;
    }

    public String getContentStatus() {
        return contentStatus;
    }

    public void setContentStatus(String contentStatus) {
        this.contentStatus = contentStatus;
    }

    public LocalDateTime getPublishedAt() {
        return publishedAt;
    }
}
