package com.lucy.lms.creator.dto;

import java.math.BigDecimal;
import java.time.LocalDateTime;

public class CreateCreatorRoomRequest {

    private String hostUserId;
    private String roomTitle;
    private BigDecimal priceAmount;
    private String accessType; // FREE | PAID
    private LocalDateTime scheduledStartAt;
    private Integer maxParticipants;
    private Boolean recordOption;

    public String getHostUserId() {
        return hostUserId;
    }

    public String getRoomTitle() {
        return roomTitle;
    }

    public BigDecimal getPriceAmount() {
        return priceAmount;
    }

    public String getAccessType() {
        return accessType;
    }

    public LocalDateTime getScheduledStartAt() {
        return scheduledStartAt;
    }

    public Integer getMaxParticipants() {
        return maxParticipants;
    }

    public Boolean getRecordOption() {
        return recordOption;
    }
}
