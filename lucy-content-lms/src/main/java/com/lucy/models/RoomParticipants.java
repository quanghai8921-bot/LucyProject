package com.lucy.models;

import java.util.Date;

public class RoomParticipants {
    private String RoomParticipantId;
    private String RoomId;
    private String UserId;
    private Date JoinedAt;
    private Date LeftAt;
    private String MicStatus;
    private int HandRaised;
    private String ParticipantStatus;

    public RoomParticipants() {
    }

    public RoomParticipants(String RoomParticipantId, String RoomId, String UserId, Date JoinedAt, Date LeftAt,
            String MicStatus, int HandRaised, String ParticipantStatus) {
        this.RoomParticipantId = RoomParticipantId;
        this.RoomId = RoomId;
        this.UserId = UserId;
        this.JoinedAt = JoinedAt;
        this.LeftAt = LeftAt;
        this.MicStatus = MicStatus;
        this.HandRaised = HandRaised;
        this.ParticipantStatus = ParticipantStatus;
    }

    public String getRoomParticipantId() {
        return this.RoomParticipantId;
    }

    public void setRoomParticipantId(String RoomParticipantId) {
        this.RoomParticipantId = RoomParticipantId;
    }

    public String getRoomId() {
        return this.RoomId;
    }

    public void setRoomId(String RoomId) {
        this.RoomId = RoomId;
    }

    public String getUserId() {
        return this.UserId;
    }

    public void setUserId(String UserId) {
        this.UserId = UserId;
    }

    public Date getJoinedAt() {
        return this.JoinedAt;
    }

    public void setJoinedAt(Date JoinedAt) {
        this.JoinedAt = JoinedAt;
    }

    public Date getLeftAt() {
        return this.LeftAt;
    }

    public void setLeftAt(Date LeftAt) {
        this.LeftAt = LeftAt;
    }

    public String getMicStatus() {
        return this.MicStatus;
    }

    public void setMicStatus(String MicStatus) {
        this.MicStatus = MicStatus;
    }

    public int getHandRaised() {
        return this.HandRaised;
    }

    public void setHandRaised(int HandRaised) {
        this.HandRaised = HandRaised;
    }

    public String getParticipantStatus() {
        return this.ParticipantStatus;
    }

    public void setParticipantStatus(String ParticipantStatus) {
        this.ParticipantStatus = ParticipantStatus;
    }
}