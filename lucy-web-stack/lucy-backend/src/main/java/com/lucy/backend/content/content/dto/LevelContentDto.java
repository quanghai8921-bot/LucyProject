package com.lucy.backend.content.content.dto;

import java.util.List;

public class LevelContentDto {
    private Integer levelNumber;
    private String levelTitle;
    private List<SubLevelContentDto> subLevels;

    public LevelContentDto() {}

    public LevelContentDto(Integer levelNumber, String levelTitle, List<SubLevelContentDto> subLevels) {
        this.levelNumber = levelNumber;
        this.levelTitle = levelTitle;
        this.subLevels = subLevels;
    }

    public Integer getLevelNumber() {
        return levelNumber;
    }

    public void setLevelNumber(Integer levelNumber) {
        this.levelNumber = levelNumber;
    }

    public String getLevelTitle() {
        return levelTitle;
    }

    public void setLevelTitle(String levelTitle) {
        this.levelTitle = levelTitle;
    }

    public List<SubLevelContentDto> getSubLevels() {
        return subLevels;
    }

    public void setSubLevels(List<SubLevelContentDto> subLevels) {
        this.subLevels = subLevels;
    }
}
