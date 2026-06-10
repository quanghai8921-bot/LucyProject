package com.lucy.lms.learner.dto;

import com.lucy.lms.learner.entity.RoomParticipant;

import java.time.LocalDateTime;

public class RoomParticipantDto {

    private final String participantId;
    private final String roomId;
    private final String userId;
    private final LocalDateTime joinedAt;
    private final LocalDateTime lastSeenAt;
    private final LocalDateTime leftAt;
    private final Integer totalActiveSeconds;
    private final String micStatus;
    private final String handRaiseStatus;
    private final String participantStatus;

    public RoomParticipantDto(RoomParticipant participant) {
        this.participantId = participant.getParticipantId();
        this.roomId = participant.getRoomId();
        this.userId = participant.getUserId();
        this.joinedAt = participant.getJoinedAt();
        this.lastSeenAt = participant.getLastSeenAt();
        this.leftAt = participant.getLeftAt();
        this.totalActiveSeconds = participant.getTotalActiveSeconds();
        this.micStatus = participant.getMicStatus();
        this.handRaiseStatus = participant.getHandRaiseStatus();
        this.participantStatus = participant.getParticipantStatus();
    }

    public String getParticipantId() {
        return participantId;
    }

    public String getRoomId() {
        return roomId;
    }

    public String getUserId() {
        return userId;
    }

    public LocalDateTime getJoinedAt() {
        return joinedAt;
    }

    public LocalDateTime getLastSeenAt() {
        return lastSeenAt;
    }

    public LocalDateTime getLeftAt() {
        return leftAt;
    }

    public Integer getTotalActiveSeconds() {
        return totalActiveSeconds;
    }

    public String getMicStatus() {
        return micStatus;
    }

    public String getHandRaiseStatus() {
        return handRaiseStatus;
    }

    public String getParticipantStatus() {
        return participantStatus;
    }
}
