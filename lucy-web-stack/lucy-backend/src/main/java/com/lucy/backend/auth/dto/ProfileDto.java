package com.lucy.backend.auth.dto;

import lombok.Data;

@Data
public class ProfileDto {
    private String userId;
    private String fullName;
    private String displayName;
    private String avatarUrl;
    private String levelNumber;

    // Getter & Setter
    public String getLevelNumber() {
        return levelNumber;
    }

    public void setLevelNumber(String levelNumber) {
        this.levelNumber = levelNumber;
    }
}
