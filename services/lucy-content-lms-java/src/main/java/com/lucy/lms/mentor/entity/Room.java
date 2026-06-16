package com.lucy.lms.mentor.entity;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.Table;

import java.math.BigDecimal;
import java.time.LocalDateTime;

@Entity
@Table(name = "Rooms")
public class Room {

    @Id
    @Column(name = "RoomId", length = 50)
    private String roomId;

    @Column(name = "HostUserId", length = 50, nullable = false)
    private String hostUserId;

    @Column(name = "HostRole", length = 30, nullable = false)
    private String hostRole;

    @Column(name = "LevelId", length = 50)
    private String levelId;

    @Column(name = "LanguageId", length = 50)
    private String languageId;

    @Column(name = "ImportedDocxFileId", length = 50)
    private String importedDocxFileId;

    @Column(name = "RoomTitle", length = 100, nullable = false)
    private String roomTitle;

    @Column(name = "RoomType", length = 100)
    private String roomType;

    @Column(name = "AccessType", length = 100)
    private String accessType;

    @Column(name = "PriceAmount")
    private BigDecimal priceAmount;

    @Column(name = "ScheduledStartAt", nullable = false)
    private LocalDateTime scheduledStartAt;

    @Column(name = "StudyStartedAt")
    private LocalDateTime studyStartedAt;

    @Column(name = "EndedAt")
    private LocalDateTime endedAt;

    @Column(name = "RoomStatus", length = 30, nullable = false)
    private String roomStatus;

    @Column(name = "MaxParticipants")
    private Integer maxParticipants;

    @Column(name = "CreatedAt")
    private LocalDateTime createdAt;

    @jakarta.persistence.Transient
    private String hostUserName;

    @jakarta.persistence.Transient
    private Integer participantCount;

    @jakarta.persistence.Transient
    private Integer levelNumber;

    protected Room() {
    }

    public Room(String roomId, String hostUserId, String hostRole, String levelId, String languageId,
            String importedDocxFileId,
            String roomTitle, String roomType, String accessType, BigDecimal priceAmount,
            LocalDateTime scheduledStartAt, String roomStatus, Integer maxParticipants,
            LocalDateTime createdAt) {
        this.roomId = roomId;
        this.hostUserId = hostUserId;
        this.hostRole = hostRole;
        this.levelId = levelId;
        this.languageId = languageId;
        this.importedDocxFileId = importedDocxFileId;
        this.roomTitle = roomTitle;
        this.roomType = roomType;
        this.accessType = accessType;
        this.priceAmount = priceAmount;
        this.scheduledStartAt = scheduledStartAt;
        this.roomStatus = roomStatus;
        this.maxParticipants = maxParticipants;
        this.createdAt = createdAt;
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

    public LocalDateTime getStudyStartedAt() {
        return studyStartedAt;
    }

    public void setStudyStartedAt(LocalDateTime studyStartedAt) {
        this.studyStartedAt = studyStartedAt;
    }

    public LocalDateTime getEndedAt() {
        return endedAt;
    }

    public String getRoomStatus() {
        return roomStatus;
    }

    public void setRoomStatus(String roomStatus) {
        this.roomStatus = roomStatus;
    }

    public void setEndedAt(LocalDateTime endedAt) {
        this.endedAt = endedAt;
    }

    public Integer getMaxParticipants() {
        return maxParticipants;
    }

    public LocalDateTime getCreatedAt() {
        return createdAt;
    }

    public String getHostUserName() {
        return hostUserName;
    }

    public void setHostUserName(String hostUserName) {
        this.hostUserName = hostUserName;
    }

    public Integer getParticipantCount() {
        return participantCount;
    }

    public void setParticipantCount(Integer participantCount) {
        this.participantCount = participantCount;
    }

    public Integer getLevelNumber() {
        return levelNumber;
    }

    public void setLevelNumber(Integer levelNumber) {
        this.levelNumber = levelNumber;
    }
}
