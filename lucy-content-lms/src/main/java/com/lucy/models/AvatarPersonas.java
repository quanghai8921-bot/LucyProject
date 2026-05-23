package com.lucy.models;

public class AvatarPersonas {
    private String UserId;
    private String DisplayName;
    private String AvatarUrl;

    public AvatarPersonas() {
    }

    public AvatarPersonas(String UserId, String DisplayName, String AvatarUrl) {
        this.UserId = UserId;
        this.DisplayName = DisplayName;
        this.AvatarUrl = AvatarUrl;
    }

    public String getUserId() {
        return this.UserId;
    }

    public void setUserId(String UserId) {
        this.UserId = UserId;
    }

    public String getDisplayName() {
        return this.DisplayName;
    }

    public void setDisplayName(String DisplayName) {
        this.DisplayName = DisplayName;
    }

    public String getAvatarUrl() {
        return this.AvatarUrl;
    }

    public void setAvatarUrl(String AvatarUrl) {
        this.AvatarUrl = AvatarUrl;
    }
}