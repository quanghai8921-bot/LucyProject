package com.lucy.lms.mentor.entity;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.Table;

import java.time.LocalDateTime;

/**
 * Yêu cầu nâng cấp từ Mentor lên Creator.
 * Admin sẽ review và approve/reject.
 */
@Entity
@Table(name = "MentorUpgradeRequests")
public class MentorUpgradeRequest {

    @Id
    @Column(name = "RequestId", length = 50)
    private String requestId;

    @Column(name = "MentorUserId", length = 50, nullable = false)
    private String mentorUserId;

    @Column(name = "RequestStatus", length = 30, nullable = false)
    private String requestStatus; // PENDING, APPROVED, REJECTED

    @Column(name = "RequestReason", columnDefinition = "TEXT")
    private String requestReason; // Lý do mentor muốn upgrade

    @Column(name = "AdminNotes", columnDefinition = "TEXT")
    private String adminNotes; // Ghi chú của admin

    @Column(name = "RequestedAt", nullable = false)
    private LocalDateTime requestedAt;

    @Column(name = "ReviewedAt")
    private LocalDateTime reviewedAt;

    @Column(name = "ReviewedBy", length = 50)
    private String reviewedBy; // UserId của admin đã xử lý

    protected MentorUpgradeRequest() {
    }

    public MentorUpgradeRequest(String requestId, String mentorUserId, String requestStatus,
                                String requestReason, LocalDateTime requestedAt) {
        this.requestId = requestId;
        this.mentorUserId = mentorUserId;
        this.requestStatus = requestStatus != null ? requestStatus : "PENDING";
        this.requestReason = requestReason;
        this.requestedAt = requestedAt;
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

    public void setRequestStatus(String requestStatus) {
        this.requestStatus = requestStatus;
    }

    public String getRequestReason() {
        return requestReason;
    }

    public void setRequestReason(String requestReason) {
        this.requestReason = requestReason;
    }

    public String getAdminNotes() {
        return adminNotes;
    }

    public void setAdminNotes(String adminNotes) {
        this.adminNotes = adminNotes;
    }

    public LocalDateTime getRequestedAt() {
        return requestedAt;
    }

    public LocalDateTime getReviewedAt() {
        return reviewedAt;
    }

    public void setReviewedAt(LocalDateTime reviewedAt) {
        this.reviewedAt = reviewedAt;
    }

    public String getReviewedBy() {
        return reviewedBy;
    }

    public void setReviewedBy(String reviewedBy) {
        this.reviewedBy = reviewedBy;
    }
}
