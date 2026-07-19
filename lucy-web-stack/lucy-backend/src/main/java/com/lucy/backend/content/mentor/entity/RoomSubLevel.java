package com.lucy.backend.content.mentor.entity;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.Table;

import java.time.LocalDateTime;

@Entity
@Table(name = "RoomSubLevels")
public class RoomSubLevel {
    @Id
    @Column(name = "RoomSubLevelId", length = 50)
    private String roomSubLevelId;

    @Column(name = "RoomId", length = 50, nullable = false)
    private String roomId;

    @Column(name = "SubLevelId", length = 50, nullable = false)
    private String subLevelId;

    @Column(name = "StepOrder", nullable = false)
    private Integer stepOrder;

    @Column(name = "PlannedDurationMins")
    private Integer plannedDurationMins;

    @Column(name = "StartedAt")
    private LocalDateTime startedAt;

    @Column(name = "EndedAt")
    private LocalDateTime endedAt;

    @Column(name = "Status", length = 30, nullable = false)
    private String status;

    protected RoomSubLevel() {
    }

    public RoomSubLevel(String roomSubLevelId, String roomId, String subLevelId, Integer stepOrder,
            Integer plannedDurationMins) {
        this.roomSubLevelId = roomSubLevelId;
        this.roomId = roomId;
        this.subLevelId = subLevelId;
        this.stepOrder = stepOrder;
        this.plannedDurationMins = plannedDurationMins;
        this.status = "NOT_STARTED";
    }

    public void start(LocalDateTime now) {
        this.startedAt = now;
        this.status = "IN_PROGRESS";
    }

    public void complete(LocalDateTime now) {
        this.endedAt = now;
        this.status = "COMPLETED";
    }

    public String getRoomSubLevelId() {
        return roomSubLevelId;
    }

    public String getRoomId() {
        return roomId;
    }

    public String getSubLevelId() {
        return subLevelId;
    }

    public Integer getStepOrder() {
        return stepOrder;
    }

    public Integer getPlannedDurationMins() {
        return plannedDurationMins;
    }

    public LocalDateTime getStartedAt() {
        return startedAt;
    }

    public LocalDateTime getEndedAt() {
        return endedAt;
    }

    public String getStatus() {
        return status;
    }
}
