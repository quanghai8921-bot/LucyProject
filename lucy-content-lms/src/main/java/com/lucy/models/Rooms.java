package com.lucy.models;

import java.util.Date;

public class Rooms {
    private String RoomId;
    private String MentorId;
    private String LevelId;
    private String RoomTitle;
    private String RoomStatus;
    private Date StartedAt;
    private Date EndedAt;
    private Integer MaxParticipants;
    private int IsAnonymous;

    public Rooms() {
    }

    public Rooms(String RoomId, String MentorId, String LevelId, String RoomTitle, String RoomStatus, Date StartedAt,
            Date EndedAt, Integer MaxParticipants, int IsAnonymous) {
        this.RoomId = RoomId;
        this.MentorId = MentorId;
        this.LevelId = LevelId;
        this.RoomTitle = RoomTitle;
        this.RoomStatus = RoomStatus;
        this.StartedAt = StartedAt;
        this.EndedAt = EndedAt;
        this.MaxParticipants = MaxParticipants;
        this.IsAnonymous = IsAnonymous;
    }

    public String getRoomId() {
        return this.RoomId;
    }

    public void setRoomId(String RoomId) {
        this.RoomId = RoomId;
    }

    public String getMentorId() {
        return this.MentorId;
    }

    public void setMentorId(String MentorId) {
        this.MentorId = MentorId;
    }

    public String getLevelId() {
        return this.LevelId;
    }

    public void setLevelId(String LevelId) {
        this.LevelId = LevelId;
    }

    public String getRoomTitle() {
        return this.RoomTitle;
    }

    public void setRoomTitle(String RoomTitle) {
        this.RoomTitle = RoomTitle;
    }

    public String getRoomStatus() {
        return this.RoomStatus;
    }

    public void setRoomStatus(String RoomStatus) {
        this.RoomStatus = RoomStatus;
    }

    public Date getStartedAt() {
        return this.StartedAt;
    }

    public void setStartedAt(Date StartedAt) {
        this.StartedAt = StartedAt;
    }

    public Date getEndedAt() {
        return this.EndedAt;
    }

    public void setEndedAt(Date EndedAt) {
        this.EndedAt = EndedAt;
    }

    public Integer getMaxParticipants() {
        return this.MaxParticipants;
    }

    public void setMaxParticipants(Integer MaxParticipants) {
        this.MaxParticipants = MaxParticipants;
    }

    public int getIsAnonymous() {
        return this.IsAnonymous;
    }

    public void setIsAnonymous(int IsAnonymous) {
        this.IsAnonymous = IsAnonymous;
    }
}