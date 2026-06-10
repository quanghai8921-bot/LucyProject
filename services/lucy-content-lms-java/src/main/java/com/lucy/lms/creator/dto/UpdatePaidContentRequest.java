package com.lucy.lms.creator.dto;

import java.math.BigDecimal;

public class UpdatePaidContentRequest {
    private String title;
    private String descriptionText;
    private BigDecimal priceAmount;
    private String contentStatus;

    public String getTitle() {
        return title;
    }

    public String getDescriptionText() {
        return descriptionText;
    }

    public BigDecimal getPriceAmount() {
        return priceAmount;
    }

    public String getContentStatus() {
        return contentStatus;
    }
}
