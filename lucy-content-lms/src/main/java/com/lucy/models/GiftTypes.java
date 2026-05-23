package com.lucy.models;

public class GiftTypes {
    private String GiftTypeId;
    private String GiftName;
    private java.math.BigDecimal GiftValue;
    private String ImageUrl;
    private int IsStatus;

    public GiftTypes() {
    }

    public GiftTypes(String GiftTypeId, String GiftName, java.math.BigDecimal GiftValue, String ImageUrl,
            int IsStatus) {
        this.GiftTypeId = GiftTypeId;
        this.GiftName = GiftName;
        this.GiftValue = GiftValue;
        this.ImageUrl = ImageUrl;
        this.IsStatus = IsStatus;
    }

    public String getGiftTypeId() {
        return this.GiftTypeId;
    }

    public void setGiftTypeId(String GiftTypeId) {
        this.GiftTypeId = GiftTypeId;
    }

    public String getGiftName() {
        return this.GiftName;
    }

    public void setGiftName(String GiftName) {
        this.GiftName = GiftName;
    }

    public java.math.BigDecimal getGiftValue() {
        return this.GiftValue;
    }

    public void setGiftValue(java.math.BigDecimal GiftValue) {
        this.GiftValue = GiftValue;
    }

    public String getImageUrl() {
        return this.ImageUrl;
    }

    public void setImageUrl(String ImageUrl) {
        this.ImageUrl = ImageUrl;
    }

    public int getIsStatus() {
        return this.IsStatus;
    }

    public void setIsStatus(int IsStatus) {
        this.IsStatus = IsStatus;
    }
}