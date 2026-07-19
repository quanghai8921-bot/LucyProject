package com.lucy.backend.content.mentor.entity;

import jakarta.persistence.*;
import lombok.Data;
import java.time.LocalDateTime;

@Entity
@Table(name = "PinnedMaterials")
@Data
public class PinnedMaterial {
    @Id
    @Column(name = "PinnedMaterialId", length = 50)
    private String pinnedMaterialId;

    @Column(name = "RoomId", length = 50, nullable = false)
    private String roomId;

    @Column(name = "UploadedByUserId", length = 50, nullable = false)
    private String uploadedByUserId;

    @Column(name = "Title", length = 255, nullable = false)
    private String title;

    @Column(name = "FileUrl", length = 500, nullable = false)
    private String fileUrl;

    @Column(name = "FileType", length = 50)
    private String fileType;

    @Column(name = "FileSize")
    private Long fileSize;

    @Column(name = "DisplayOrder")
    private Integer displayOrder = 1;

    @Column(name = "IsActive")
    private Integer isActive = 1;

    @Column(name = "CreatedAt", updatable = false)
    private LocalDateTime createdAt = LocalDateTime.now();
}
