package com.lucy.backend.auth.entity;

import jakarta.persistence.*;
import lombok.Data;
import java.time.LocalDateTime;

@Entity
@Table(name = "MentorApplications")
@Data
public class MentorApplication {
    @Id
    @Column(name = "ApplicationId", length = 50)
    private String applicationId;

    @Column(name = "UserId", length = 50, nullable = false)
    private String userId;

    @Column(name = "LanguageId", length = 50)
    private String languageId;

    @Column(name = "CertificateUrl", length = 255)
    private String certificateUrl;

    @Column(name = "Status", length = 30, nullable = false)
    private String status = "PENDING";

    @Column(name = "RejectReason", length = 255)
    private String rejectReason;

    @Column(name = "SubmittedAt", nullable = false)
    private LocalDateTime submittedAt = LocalDateTime.now();
}
