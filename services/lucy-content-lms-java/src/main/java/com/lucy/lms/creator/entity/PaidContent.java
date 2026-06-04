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
    private String contentType; // PODCAST | PAID_LIVE | COURSE

    @Column(name = "Title", length = 150, nullable = false)
    private String title;

    @Column(name = "DescriptionText", columnDefinition = "TEXT")
    private String descriptionText;

    @Column(name = "ThumbnailUrl", length = 255)
    private String thumbnailUrl;

    @Column(name = "AudioUrl", length = 255)
    private String audioUrl;

    @Column(name = "PriceAmount", nullable = false)
    private BigDecimal priceAmount;

    @Column(name = "ContentStatus", length = 30, nullable = false)
    private String contentStatus; // DRAFT | PUBLISHED

    @Column(name = "PublishedAt")
    private LocalDateTime publishedAt;

    protected PaidContent() {
    }

    public PaidContent(String contentId, String creatorUserId, String roomId, String recordingId,
                       String contentType, String title, String descriptionText, String thumbnailUrl,
                       String audioUrl, BigDecimal priceAmount, String contentStatus, LocalDateTime publishedAt) {
        this.contentId = contentId;
        this.creatorUserId = creatorUserId;
        this.roomId = roomId;
        this.recordingId = recordingId;
        this.contentType = contentType;
        this.title = title;
        this.descriptionText = descriptionText;
        this.thumbnailUrl = thumbnailUrl;
        this.audioUrl = audioUrl;
        this.priceAmount = priceAmount != null ? priceAmount : BigDecimal.ZERO;
        this.contentStatus = contentStatus != null ? contentStatus : "DRAFT";
        this.publishedAt = publishedAt;
    }

    public String getContentId() {
        return contentId;
    }

    public String getCreatorUserId() {
        return creatorUserId;
    }

    public String getRoomId() {
        return roomId;
    }

    public String getRecordingId() {
        return recordingId;
    }

    public String getContentType() {
        return contentType;
    }

    public String getTitle() {
        return title;
    }

    public String getDescriptionText() {
        return descriptionText;
    }

    public String getThumbnailUrl() {
        return thumbnailUrl;
    }

    public String getAudioUrl() {
        return audioUrl;
    }

    public BigDecimal getPriceAmount() {
        return priceAmount;
    }

    public String getContentStatus() {
        return contentStatus;
    }

    public LocalDateTime getPublishedAt() {
        return publishedAt;
    }

    public void setContentStatus(String contentStatus) {
        this.contentStatus = contentStatus;
    }

    public void setPriceAmount(BigDecimal priceAmount) {
        this.priceAmount = priceAmount;
    }

    public void setPublishedAt(LocalDateTime publishedAt) {
        this.publishedAt = publishedAt;
    }
}
