package com.lucy.backend.auth.dto;

import lombok.Data;
import java.time.LocalDateTime;

@Data
public class AdminCreatorApplicationDto {
    private String applicationId;
    private String userId;
    private String fullName;
    private String email;
    private String certificateUrl;
    private String status;
    private String rejectReason;
    private LocalDateTime submittedAt;
}
