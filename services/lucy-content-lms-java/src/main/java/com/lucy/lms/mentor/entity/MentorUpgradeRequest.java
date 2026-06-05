package com.lucy.lms.mentor.entity;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.Table;

import java.time.LocalDateTime;

@Entity
@Table(name = "MentorUpgradeRequests")
public class MentorUpgradeRequest {

    @Id
    @Column(name = "RequestId", length = 50)
    private String requestId;

    @Column(name = "MentorUserId", length = 50, nullable = false)
    private String mentorUserId;

    @Column(name = "RequestStatus", length = 30, nullable = false)
    private String requestStatus;

    @Column(name = "RequestReason", length = 1000)
    private String requestReason;

    @Column(name = "AdminNotes", length = 1000)
    private String adminNotes;

    @Column(name = "ReviewedBy", length = 50)
    private String reviewedBy;

    @Column(name = "ReviewedAt")
    private LocalDateTime reviewedAt;

    @Column(name = "CreatedAt", nullable = false)
    private LocalDateTime createdAt;

    protected MentorUpgradeRequest() {
    }

    public MentorUpgradeRequest(String requestId, String mentorUserId, String requestStatus,
                                String requestReason, LocalDateTime createdAt) {
        this.requestId = requestId;
        this.mentorUserId = mentorUserId;
        this.requestStatus = requestStatus;
        this.requestReason = requestReason;
        this.createdAt = createdAt;
    }

    public String getRequestId() {
        return requestId;
    }

    public String getMentorUserId() {
        return mentorUserId;
    }

    public String getRequestStatus() {
        return requestStatus;
    }

    public String getRequestReason() {
        return requestReason;
    }

    public String getAdminNotes() {
        return adminNotes;
    }

    public String getReviewedBy() {
        return reviewedBy;
    }

    public LocalDateTime getReviewedAt() {
        return reviewedAt;
    }

    public LocalDateTime getCreatedAt() {
        return createdAt;
    }

    public void setRequestStatus(String requestStatus) {
        this.requestStatus = requestStatus;
    }

    public void setAdminNotes(String adminNotes) {
        this.adminNotes = adminNotes;
    }

    public void setReviewedBy(String reviewedBy) {
        this.reviewedBy = reviewedBy;
    }

    public void setReviewedAt(LocalDateTime reviewedAt) {
        this.reviewedAt = reviewedAt;
    }
}
