package com.lucy.lms.mentor.dto;

public class ApproveUpgradeRequest {

    private String requestId;
    private String adminUserId;
    private String adminNotes;
    private String status; // APPROVED or REJECTED

    public String getRequestId() {
        return requestId;
    }

    public String getAdminUserId() {
        return adminUserId;
    }

    public String getAdminNotes() {
        return adminNotes;
    }

    public String getStatus() {
        return status;
    }
}
