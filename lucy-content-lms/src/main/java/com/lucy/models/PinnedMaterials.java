package com.lucy.models;

import java.util.Date;

public class PinnedMaterials {
    private String MaterialId;
    private String RoomId;
    private String SubLevelId;
    private String Title;
    private String MaterialType;
    private String FileUrl;
    private String ContentText;
    private String PinnedBy;
    private Date CreatedAt;

    public PinnedMaterials() {
    }

    public PinnedMaterials(String MaterialId, String RoomId, String SubLevelId, String Title, String MaterialType,
            String FileUrl, String ContentText, String PinnedBy, Date CreatedAt) {
        this.MaterialId = MaterialId;
        this.RoomId = RoomId;
        this.SubLevelId = SubLevelId;
        this.Title = Title;
        this.MaterialType = MaterialType;
        this.FileUrl = FileUrl;
        this.ContentText = ContentText;
        this.PinnedBy = PinnedBy;
        this.CreatedAt = CreatedAt;
    }

    public String getMaterialId() {
        return this.MaterialId;
    }

    public void setMaterialId(String MaterialId) {
        this.MaterialId = MaterialId;
    }

    public String getRoomId() {
        return this.RoomId;
    }

    public void setRoomId(String RoomId) {
        this.RoomId = RoomId;
    }

    public String getSubLevelId() {
        return this.SubLevelId;
    }

    public void setSubLevelId(String SubLevelId) {
        this.SubLevelId = SubLevelId;
    }

    public String getTitle() {
        return this.Title;
    }

    public void setTitle(String Title) {
        this.Title = Title;
    }

    public String getMaterialType() {
        return this.MaterialType;
    }

    public void setMaterialType(String MaterialType) {
        this.MaterialType = MaterialType;
    }

    public String getFileUrl() {
        return this.FileUrl;
    }

    public void setFileUrl(String FileUrl) {
        this.FileUrl = FileUrl;
    }

    public String getContentText() {
        return this.ContentText;
    }

    public void setContentText(String ContentText) {
        this.ContentText = ContentText;
    }

    public String getPinnedBy() {
        return this.PinnedBy;
    }

    public void setPinnedBy(String PinnedBy) {
        this.PinnedBy = PinnedBy;
    }

    public Date getCreatedAt() {
        return this.CreatedAt;
    }

    public void setCreatedAt(Date CreatedAt) {
        this.CreatedAt = CreatedAt;
    }
}