package com.lucy.backend.content.learner.dto;

public class AttendanceEligibilityDto {
    private final String userId;
    private final String roomId;
    private final String levelId;
    private final long askedCount;
    private final long confirmedCount;
    private final long offlineCount;
    private final boolean eligibleForQuiz;

    public AttendanceEligibilityDto(String userId, String roomId, String levelId, long askedCount,
            long confirmedCount, long offlineCount, boolean eligibleForQuiz) {
        this.userId = userId;
        this.roomId = roomId;
        this.levelId = levelId;
        this.askedCount = askedCount;
        this.confirmedCount = confirmedCount;
        this.offlineCount = offlineCount;
        this.eligibleForQuiz = eligibleForQuiz;
    }

    public String getUserId() {
        return userId;
    }

    public String getRoomId() {
        return roomId;
    }

    public String getLevelId() {
        return levelId;
    }

    public long getAskedCount() {
        return askedCount;
    }

    public long getConfirmedCount() {
        return confirmedCount;
    }

    public long getOfflineCount() {
        return offlineCount;
    }

    public boolean getEligibleForQuiz() {
        return eligibleForQuiz;
    }
}
