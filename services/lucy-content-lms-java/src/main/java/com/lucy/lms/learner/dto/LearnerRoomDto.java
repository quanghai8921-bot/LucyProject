package com.lucy.lms.learner.dto;

import com.lucy.lms.mentor.entity.Room;

import java.math.BigDecimal;
import java.time.LocalDateTime;

public class LearnerRoomDto {

    private final String roomId;
    private final String hostUserId;
    private final String hostRole;
    private final String levelId;
    private final String languageId;
    private final String importedDocxFileId;
    private final String roomTitle;
    private final String roomType;
    private final String accessType;
    private final BigDecimal priceAmount;
    private final LocalDateTime scheduledStartAt;
    private final String roomStatus;
    private final Integer maxParticipants;
    private final Integer participantCount;

    private String hostUserName;

    public LearnerRoomDto(Room room, Integer participantCount) {
        this.roomId = room.getRoomId();
        this.hostUserId = room.getHostUserId();
        this.hostRole = room.getHostRole();
        this.levelId = room.getLevelId();
        this.languageId = room.getLanguageId();
        this.importedDocxFileId = room.getImportedDocxFileId();
        this.roomTitle = room.getRoomTitle();
        this.roomType = room.getRoomType();
        this.accessType = room.getAccessType();
        this.priceAmount = room.getPriceAmount();
        this.scheduledStartAt = room.getScheduledStartAt();
        this.roomStatus = room.getRoomStatus();
        this.maxParticipants = room.getMaxParticipants();
        this.participantCount = participantCount;
        this.hostUserName = room.getHostUserName();
    }

    public String getRoomId() {
        return roomId;
    }

    public String getHostUserId() {
        return hostUserId;
    }

    public String getHostRole() {
        return hostRole;
    }

    public String getLevelId() {
        return levelId;
    }

    public String getLanguageId() {
        return languageId;
    }

    public String getImportedDocxFileId() {
        return importedDocxFileId;
    }

    public String getRoomTitle() {
        return roomTitle;
    }

    public String getRoomType() {
        return roomType;
    }

    public String getAccessType() {
        return accessType;
    }

    public BigDecimal getPriceAmount() {
        return priceAmount;
    }

    public LocalDateTime getScheduledStartAt() {
        return scheduledStartAt;
    }

    public String getRoomStatus() {
        return roomStatus;
    }

    public Integer getMaxParticipants() {
        return maxParticipants;
    }

    public Integer getParticipantCount() {
        return participantCount;
    }

    public String getHostUserName() {
        return hostUserName;
    }

    public void setHostUserName(String hostUserName) {
        this.hostUserName = hostUserName;
    }
}
