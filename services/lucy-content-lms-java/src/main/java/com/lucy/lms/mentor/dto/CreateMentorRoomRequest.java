package com.lucy.lms.mentor.dto;

import java.time.LocalDateTime;

public class CreateMentorRoomRequest {

    private String hostUserId;
    private String languageId;
    private String levelId;
    private String roomTitle;
    private LocalDateTime scheduledStartAt;
    private Integer maxParticipants;
    private String roomStatus;

    public String getHostUserId() {
        return hostUserId;
    }

    public String getLanguageId() {
        return languageId;
    }

    public String getLevelId() {
        return levelId;
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
}