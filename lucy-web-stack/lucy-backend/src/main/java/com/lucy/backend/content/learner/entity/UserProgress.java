package com.lucy.backend.content.learner.entity;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.Table;

import java.math.BigDecimal;
import java.time.LocalDateTime;

@Entity
@Table(name = "UserProgress")
public class UserProgress {
    @Id
    @Column(name = "ProgressId", length = 50)
    private String progressId;

    @Column(name = "UserId", length = 50, nullable = false)
    private String userId;

    @Column(name = "LanguageId", length = 50, nullable = false)
    private String languageId;

    @Column(name = "LevelId", length = 50, nullable = false)
    private String levelId;

    @Column(name = "CurrentSubLevelId", length = 50)
    private String currentSubLevelId;

    @Column(name = "CompletedSubLevelCount", nullable = false)
    private Integer completedSubLevelCount;

    @Column(name = "ProgressPercent", nullable = false)
    private BigDecimal progressPercent;

    @Column(name = "Status", length = 30, nullable = false)
    private String status;

    @Column(name = "CompletedAt")
    private LocalDateTime completedAt;

    protected UserProgress() {
    }

    public UserProgress(String progressId, String userId, String languageId, String levelId) {
        this.progressId = progressId;
        this.userId = userId;
        this.languageId = languageId;
        this.levelId = levelId;
        this.completedSubLevelCount = 0;
        this.progressPercent = BigDecimal.ZERO;
        this.status = "IN_PROGRESS";
    }

    public void markLevelPassed(int completedSubLevelCount) {
        this.completedSubLevelCount = completedSubLevelCount;
        this.progressPercent = BigDecimal.valueOf(100);
        this.status = "COMPLETED";
        this.completedAt = LocalDateTime.now();
        this.currentSubLevelId = null;
    }
}
