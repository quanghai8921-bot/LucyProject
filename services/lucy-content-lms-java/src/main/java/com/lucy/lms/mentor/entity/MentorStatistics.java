package com.lucy.lms.mentor.entity;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.Table;

import java.math.BigDecimal;
import java.time.LocalDateTime;

/**
 * Thống kê hiệu suất Mentor để xét điều kiện lên Creator.
 * Được cập nhật định kỳ từ dữ liệu: session, rating, learners.
 */
@Entity
@Table(name = "MentorStatistics")
public class MentorStatistics {

    @Id
    @Column(name = "StatisticId", length = 50)
    private String statisticId;

    @Column(name = "MentorUserId", length = 50, nullable = false)
    private String mentorUserId;

    @Column(name = "TotalLearnersCount", nullable = false)
    private Integer totalLearnersCount; // Tổng số học viên

    @Column(name = "AverageRating", nullable = false)
    private BigDecimal averageRating; // Điểm đánh giá trung bình (0-5)

    @Column(name = "TotalTeachingHours", nullable = false)
    private Integer totalTeachingHours; // Tổng giờ dạy

    @Column(name = "RatingCountLastYear", nullable = false)
    private Integer ratingCountLastYear; // Số lần đánh giá trong năm qua

    @Column(name = "UpdatedAt", nullable = false)
    private LocalDateTime updatedAt; // Cập nhật lần cuối

    protected MentorStatistics() {
    }

    public MentorStatistics(String statisticId, String mentorUserId, Integer totalLearnersCount,
                            BigDecimal averageRating, Integer totalTeachingHours,
                            Integer ratingCountLastYear, LocalDateTime updatedAt) {
        this.statisticId = statisticId;
        this.mentorUserId = mentorUserId;
        this.totalLearnersCount = totalLearnersCount != null ? totalLearnersCount : 0;
        this.averageRating = averageRating != null ? averageRating : BigDecimal.ZERO;
        this.totalTeachingHours = totalTeachingHours != null ? totalTeachingHours : 0;
        this.ratingCountLastYear = ratingCountLastYear != null ? ratingCountLastYear : 0;
        this.updatedAt = updatedAt;
    }

    public String getStatisticId() {
        return statisticId;
    }

    public String getMentorUserId() {
        return mentorUserId;
    }

    public Integer getTotalLearnersCount() {
        return totalLearnersCount;
    }

    public void setTotalLearnersCount(Integer totalLearnersCount) {
        this.totalLearnersCount = totalLearnersCount;
    }

    public BigDecimal getAverageRating() {
        return averageRating;
    }

    public void setAverageRating(BigDecimal averageRating) {
        this.averageRating = averageRating;
    }

    public Integer getTotalTeachingHours() {
        return totalTeachingHours;
    }

    public void setTotalTeachingHours(Integer totalTeachingHours) {
        this.totalTeachingHours = totalTeachingHours;
    }

    public Integer getRatingCountLastYear() {
        return ratingCountLastYear;
    }

    public void setRatingCountLastYear(Integer ratingCountLastYear) {
        this.ratingCountLastYear = ratingCountLastYear;
    }

    public LocalDateTime getUpdatedAt() {
        return updatedAt;
    }

    public void setUpdatedAt(LocalDateTime updatedAt) {
        this.updatedAt = updatedAt;
    }
}
