package com.lucy.lms.creator.dto;

import java.math.BigDecimal;
import java.time.LocalDateTime;

public class CreatePaidContentRequest {

    private String creatorUserId;
    private String roomId;
    private String recordingId;
    private String contentType;
    private String title;
    private String descriptionText;
    private String thumbnailUrl;
    private String audioUrl;
    private BigDecimal priceAmount;
    private String contentStatus;
    private LocalDateTime publishedAt;

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
}
