package com.lucy.backend.content.content.dto;

public class SubLevelContentDto {
    private String subLevelTitle;
    private String mainTask;

    public SubLevelContentDto() {}

    public SubLevelContentDto(String subLevelTitle, String mainTask) {
        this.subLevelTitle = subLevelTitle;
        this.mainTask = mainTask;
    }

    public String getSubLevelTitle() {
        return subLevelTitle;
    }

    public void setSubLevelTitle(String subLevelTitle) {
        this.subLevelTitle = subLevelTitle;
    }

    public String getMainTask() {
        return mainTask;
    }

    public void setMainTask(String mainTask) {
        this.mainTask = mainTask;
    }
}
