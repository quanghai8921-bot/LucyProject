package com.lucy.models;

import java.util.Date;

public class PodcastRecords {
    private String PodcastId;
    private String RoomId;
    private String CreatorId;
    private String Title;
    private String AudioUrl;
    private Integer DurationSeconds;
    private int IsPremium;
    private Date CreatedAt;
    private int IsStatus;

    public PodcastRecords() {
    }

    public PodcastRecords(String PodcastId, String RoomId, String CreatorId, String Title, String AudioUrl,
            Integer DurationSeconds, int IsPremium, Date CreatedAt, int IsStatus) {
        this.PodcastId = PodcastId;
        this.RoomId = RoomId;
        this.CreatorId = CreatorId;
        this.Title = Title;
        this.AudioUrl = AudioUrl;
        this.DurationSeconds = DurationSeconds;
        this.IsPremium = IsPremium;
        this.CreatedAt = CreatedAt;
        this.IsStatus = IsStatus;
    }

    public String getPodcastId() {
        return this.PodcastId;
    }

    public void setPodcastId(String PodcastId) {
        this.PodcastId = PodcastId;
    }

    public String getRoomId() {
        return this.RoomId;
    }

    public void setRoomId(String RoomId) {
        this.RoomId = RoomId;
    }

    public String getCreatorId() {
        return this.CreatorId;
    }

    public void setCreatorId(String CreatorId) {
        this.CreatorId = CreatorId;
    }

    public String getTitle() {
        return this.Title;
    }

    public void setTitle(String Title) {
        this.Title = Title;
    }

    public String getAudioUrl() {
        return this.AudioUrl;
    }

    public void setAudioUrl(String AudioUrl) {
        this.AudioUrl = AudioUrl;
    }

    public Integer getDurationSeconds() {
        return this.DurationSeconds;
    }

    public void setDurationSeconds(Integer DurationSeconds) {
        this.DurationSeconds = DurationSeconds;
    }

    public int getIsPremium() {
        return this.IsPremium;
    }

    public void setIsPremium(int IsPremium) {
        this.IsPremium = IsPremium;
    }

    public Date getCreatedAt() {
        return this.CreatedAt;
    }

    public void setCreatedAt(Date CreatedAt) {
        this.CreatedAt = CreatedAt;
    }

    public int getIsStatus() {
        return this.IsStatus;
    }

    public void setIsStatus(int IsStatus) {
        this.IsStatus = IsStatus;
    }
}