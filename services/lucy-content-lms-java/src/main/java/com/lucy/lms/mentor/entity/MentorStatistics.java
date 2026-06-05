package com.lucy.lms.mentor.entity;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.Table;

import java.math.BigDecimal;
import java.time.LocalDateTime;

@Entity
@Table(name = "MentorStatistics")
public class MentorStatistics {

    @Id
    @Column(name = "StatisticsId", length = 50)
    private String statisticsId;

    @Column(name = "MentorUserId", length = 50, nullable = false)
    private String mentorUserId;

    @Column(name = "TotalLearnersCount", nullable = false)
    private Integer totalLearnersCount;

    @Column(name = "AverageRating", precision = 3, scale = 2, nullable = false)
    private BigDecimal averageRating;

    @Column(name = "TotalTeachingHours", nullable = false)
    private Integer totalTeachingHours;

    @Column(name = "TotalCourses", nullable = false)
    private Integer totalCourses;

    @Column(name = "UpdatedAt", nullable = false)
    private LocalDateTime updatedAt;

    protected MentorStatistics() {
    }

    public MentorStatistics(String statisticsId, String mentorUserId,
                             Integer totalLearnersCount, BigDecimal averageRating,
                             Integer totalTeachingHours, Integer totalCourses, LocalDateTime updatedAt) {
        this.statisticsId = statisticsId;
        this.mentorUserId = mentorUserId;
        this.totalLearnersCount = totalLearnersCount;
        this.averageRating = averageRating;
        this.totalTeachingHours = totalTeachingHours;
        this.totalCourses = totalCourses != null ? totalCourses : 0;
        this.updatedAt = updatedAt;
    }

    public String getStatisticsId() {
        return statisticsId;
    }

    public String getMentorUserId() {
        return mentorUserId;
    }

    public Integer getTotalLearnersCount() {
        return totalLearnersCount;
    }

    public BigDecimal getAverageRating() {
        return averageRating;
    }

    public Integer getTotalTeachingHours() {
        return totalTeachingHours;
    }

    public Integer getTotalCourses() {
        return totalCourses;
    }

    public LocalDateTime getUpdatedAt() {
        return updatedAt;
    }

    public void setTotalLearnersCount(Integer totalLearnersCount) {
        this.totalLearnersCount = totalLearnersCount;
    }

    public void setAverageRating(BigDecimal averageRating) {
        this.averageRating = averageRating;
    }

    public void setTotalTeachingHours(Integer totalTeachingHours) {
        this.totalTeachingHours = totalTeachingHours;
    }

    public void setUpdatedAt(LocalDateTime updatedAt) {
        this.updatedAt = updatedAt;
    }
}
