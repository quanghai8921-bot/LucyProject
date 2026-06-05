package com.lucy.lms.creator.dto;

import java.math.BigDecimal;
import java.time.LocalDateTime;

public class UpdateCreatorRoomRequest {

    private String roomId;
    private String roomTitle;
    private LocalDateTime scheduledStartAt;
    private String accessType;
    private BigDecimal priceAmount;
    private Boolean recordOption;
    private Integer maxParticipants;

    public UpdateCreatorRoomRequest() {
    }

    public String getRoomId() {
        return roomId;
    }

    public void setRoomId(String roomId) {
        this.roomId = roomId;
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
}
