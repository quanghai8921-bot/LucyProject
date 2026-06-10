package com.lucy.lms.mentor.dto;

import java.time.LocalDateTime;
import java.math.BigDecimal;

public class CreateMentorRoomRequest {

    private String hostUserId;
    private String languageId;
    private String levelId;
    private Integer levelNumber;
    private String importedDocxFileId;
    private String roomTitle;
    private LocalDateTime scheduledStartAt;
    private Integer maxParticipants;
    private String roomStatus;
    private String hostRole;
    private String accessType;
    private BigDecimal priceAmount;

    public String getHostUserId() {
        return hostUserId;
    }

    public String getLanguageId() {
        return languageId;
    }

    public String getLevelId() {
        return levelId;
    }

    public Integer getLevelNumber() {
        return levelNumber;
    }

    public String getImportedDocxFileId() {
        return importedDocxFileId;
    }

    public String getRoomTitle() {
        return roomTitle;
    }

    public LocalDateTime getScheduledStartAt() {
        return scheduledStartAt;
    }

    public Integer getMaxParticipants() {
        return maxParticipants;
    }

    public String getRoomStatus() {
        return roomStatus;
    }

    public String getHostRole() {
        return hostRole;
    }

    public String getAccessType() {
        return accessType;
    }

    public BigDecimal getPriceAmount() {
        return priceAmount;
    }
}
