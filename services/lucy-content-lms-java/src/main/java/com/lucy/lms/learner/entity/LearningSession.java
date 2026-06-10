package com.lucy.lms.learner.entity;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.Table;

import java.time.LocalDateTime;

@Entity
@Table(name = "LearningSessions")
public class LearningSession {
    @Id
    @Column(name = "LearningSessionId", length = 50)
    private String learningSessionId;

    @Column(name = "UserId", length = 50, nullable = false)
    private String userId;

    @Column(name = "RoomId", length = 50, nullable = false)
    private String roomId;

    @Column(name = "LevelId", length = 50, nullable = false)
    private String levelId;

    @Column(name = "SubLevelId", length = 50, nullable = false)
    private String subLevelId;

    @Column(name = "StartedAt", nullable = false)
    private LocalDateTime startedAt;

    @Column(name = "EndedAt")
    private LocalDateTime endedAt;

    @Column(name = "DurationSeconds", nullable = false)
    private Integer durationSeconds;

    @Column(name = "ValidLearningMinutes", nullable = false)
    private Integer validLearningMinutes;

    @Column(name = "RequiredMinutes", nullable = false)
    private Integer requiredMinutes;

    @Column(name = "AttendanceConfirmCount", nullable = false)
    private Integer attendanceConfirmCount;

    @Column(name = "AttendanceAskedCount", nullable = false)
    private Integer attendanceAskedCount;

    @Column(name = "IsPassed", nullable = false)
    private Boolean isPassed;

    @Column(name = "SessionStatus", length = 30, nullable = false)
    private String sessionStatus;

    protected LearningSession() {
    }

    public LearningSession(String learningSessionId, String userId, String roomId, String levelId, String subLevelId) {
        this.learningSessionId = learningSessionId;
        this.userId = userId;
        this.roomId = roomId;
        this.levelId = levelId;
        this.subLevelId = subLevelId;
        this.startedAt = LocalDateTime.now();
        this.durationSeconds = 0;
        this.validLearningMinutes = 0;
        this.requiredMinutes = 420;
        this.attendanceConfirmCount = 0;
        this.attendanceAskedCount = 0;
        this.isPassed = false;
        this.sessionStatus = "IN_PROGRESS";
    }

    public void askAttendance() {
        this.attendanceAskedCount++;
    }

    public void confirmAttendance() {
        this.attendanceConfirmCount++;
    }

    public void complete(boolean passed) {
        this.endedAt = LocalDateTime.now();
        this.durationSeconds = (int) java.time.Duration.between(startedAt, endedAt).getSeconds();
        this.validLearningMinutes = durationSeconds / 60;
        this.isPassed = passed;
        this.sessionStatus = passed ? "COMPLETED" : "FAILED";
    }

    public String getLearningSessionId() {
        return learningSessionId;
    }

    public String getUserId() {
        return userId;
    }

    public String getRoomId() {
        return roomId;
    }

    public String getLevelId() {
        return levelId;
    }

    public String getSubLevelId() {
        return subLevelId;
    }

    public Integer getAttendanceConfirmCount() {
        return attendanceConfirmCount;
    }

    public Integer getAttendanceAskedCount() {
        return attendanceAskedCount;
    }
}
