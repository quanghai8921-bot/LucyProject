package com.lucy.backend.content.learner.entity;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.Table;

import java.time.LocalDateTime;

@Entity
@Table(name = "RoomParticipants")
public class RoomParticipant {

    @Id
    @Column(name = "ParticipantId", length = 50)
    private String participantId;

    @Column(name = "RoomId", length = 50, nullable = false)
    private String roomId;

    @Column(name = "UserId", length = 50, nullable = false)
    private String userId;

    @Column(name = "JoinedAt")
    private LocalDateTime joinedAt;

    @Column(name = "LastSeenAt")
    private LocalDateTime lastSeenAt;

    @Column(name = "LeftAt")
    private LocalDateTime leftAt;

    @Column(name = "TotalActiveSeconds", nullable = false)
    private Integer totalActiveSeconds;

    @Column(name = "MicStatus", length = 20, nullable = false)
    private String micStatus;

    @Column(name = "HandRaiseStatus", length = 30, nullable = false)
    private String handRaiseStatus;

    @Column(name = "ParticipantStatus", length = 30, nullable = false)
    private String participantStatus;

    protected RoomParticipant() {
    }

    public RoomParticipant(String participantId, String roomId, String userId, LocalDateTime joinedAt) {
        this.participantId = participantId;
        this.roomId = roomId;
        this.userId = userId;
        this.joinedAt = joinedAt;
        this.lastSeenAt = joinedAt;
        this.totalActiveSeconds = 0;
        this.micStatus = "OFF";
        this.handRaiseStatus = "NONE";
        this.participantStatus = "JOINED";
    }

    public void markSeen(LocalDateTime seenAt) {
        this.lastSeenAt = seenAt;
    }

    public void leave(LocalDateTime leftAt) {
        this.lastSeenAt = leftAt;
        this.leftAt = leftAt;
        this.participantStatus = "LEFT";
        this.micStatus = "OFF";
        this.handRaiseStatus = "NONE";
    }

    public void rejoin(LocalDateTime joinedAt) {
        this.joinedAt = joinedAt;
        this.lastSeenAt = joinedAt;
        this.participantStatus = "JOINED";
        this.leftAt = null;
    }

    public void setMicStatus(String micStatus, LocalDateTime updatedAt) {
        this.micStatus = micStatus;
        this.lastSeenAt = updatedAt;
    }

    public void setHandRaiseStatus(String handRaiseStatus, LocalDateTime updatedAt) {
        this.handRaiseStatus = handRaiseStatus;
        this.lastSeenAt = updatedAt;
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
