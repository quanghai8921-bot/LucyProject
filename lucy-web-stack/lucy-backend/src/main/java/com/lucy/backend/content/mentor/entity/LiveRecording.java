package com.lucy.backend.content.mentor.entity;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.Table;

import java.time.LocalDateTime;

@Entity
@Table(name = "LiveRecordings")
public class LiveRecording {

    @Id
    @Column(name = "RecordingId", length = 50)
    private String recordingId;

    @Column(name = "RoomId", length = 50, nullable = false)
    private String roomId;

    @Column(name = "CreatorUserId", length = 50, nullable = false)
    private String creatorUserId;

    @Column(name = "AudioUrl", length = 255)
    private String audioUrl;

    @Column(name = "DurationMinutes", nullable = false)
    private Integer durationMinutes;

    @Column(name = "RecordingStatus", length = 30, nullable = false)
    private String recordingStatus;

    @Column(name = "CreatedAt", nullable = false)
    private LocalDateTime createdAt;

    @Column(name = "CompletedAt")
    private LocalDateTime completedAt;

    protected LiveRecording() {
    }

    public LiveRecording(String recordingId, String roomId, String creatorUserId,
                         String recordingStatus, LocalDateTime createdAt) {
        this.recordingId = recordingId;
        this.roomId = roomId;
        this.creatorUserId = creatorUserId;
        this.recordingStatus = recordingStatus;
        this.createdAt = createdAt;
        this.durationMinutes = 0;
    }

    public String getRecordingId() {
        return recordingId;
    }

    public String getRoomId() {
        return roomId;
    }

    public String getCreatorUserId() {
        return creatorUserId;
    }

    public String getAudioUrl() {
        return audioUrl;
    }

    public void setAudioUrl(String audioUrl) {
        this.audioUrl = audioUrl;
    }

    public Integer getDurationMinutes() {
        return durationMinutes;
    }

    public void setDurationMinutes(Integer durationMinutes) {
        this.durationMinutes = durationMinutes;
    }

    public String getRecordingStatus() {
        return recordingStatus;
    }

    public void setRecordingStatus(String recordingStatus) {
        this.recordingStatus = recordingStatus;
    }

    public LocalDateTime getCreatedAt() {
        return createdAt;
    }

    public LocalDateTime getCompletedAt() {
        return completedAt;
    }

    public void setCompletedAt(LocalDateTime completedAt) {
        this.completedAt = completedAt;
    }
}
