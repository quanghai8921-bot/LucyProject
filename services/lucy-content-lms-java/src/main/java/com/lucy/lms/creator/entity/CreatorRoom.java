package com.lucy.lms.creator.entity;

import jakarta.persistence.*;
import java.math.BigDecimal;
import java.time.LocalDateTime;

@Entity
@Table(name = "creator_rooms")
public class CreatorRoom {

    @Id
    private String id;

    @Column(name = "host_user_id", nullable = false)
    private String hostUserId;

    @Column(name = "room_title", nullable = false)
    private String roomTitle;

    @Column(name = "scheduled_start_at")
    private LocalDateTime scheduledStartAt;

    @Column(name = "access_type")
    private String accessType;

    @Column(name = "price_amount")
    private BigDecimal priceAmount;

    @Column(name = "record_option")
    private Boolean recordOption;

    @Column(name = "max_participants")
    private Integer maxParticipants;

    @Column(name = "status")
    private String status;

    public CreatorRoom() {
    }

    public CreatorRoom(String id, String hostUserId, String roomTitle, LocalDateTime scheduledStartAt,
                       String accessType, BigDecimal priceAmount, Boolean recordOption, Integer maxParticipants,
                       String status) {
        this.id = id;
        this.hostUserId = hostUserId;
        this.roomTitle = roomTitle;
        this.scheduledStartAt = scheduledStartAt;
        this.accessType = accessType;
        this.priceAmount = priceAmount;
        this.recordOption = recordOption;
        this.maxParticipants = maxParticipants;
        this.status = status;
    }

    public String getId() {
        return id;
    }

    public void setId(String id) {
        this.id = id;
    }

    public String getHostUserId() {
        return hostUserId;
    }

    public void setHostUserId(String hostUserId) {
        this.hostUserId = hostUserId;
    }

    public String getRoomTitle() {
        return roomTitle;
    }

    public void setRoomTitle(String roomTitle) {
        this.roomTitle = roomTitle;
    }

    public LocalDateTime getScheduledStartAt() {
        return scheduledStartAt;
    }

    public void setScheduledStartAt(LocalDateTime scheduledStartAt) {
        this.scheduledStartAt = scheduledStartAt;
    }

    public String getAccessType() {
        return accessType;
    }

    public void setAccessType(String accessType) {
        this.accessType = accessType;
    }

    public BigDecimal getPriceAmount() {
        return priceAmount;
    }

    public void setPriceAmount(BigDecimal priceAmount) {
        this.priceAmount = priceAmount;
    }

    public Boolean getRecordOption() {
        return recordOption;
    }

    public void setRecordOption(Boolean recordOption) {
        this.recordOption = recordOption;
    }

    public Integer getMaxParticipants() {
        return maxParticipants;
    }

    public void setMaxParticipants(Integer maxParticipants) {
        this.maxParticipants = maxParticipants;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }
}
