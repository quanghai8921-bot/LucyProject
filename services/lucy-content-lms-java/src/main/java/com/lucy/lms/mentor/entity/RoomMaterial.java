package com.lucy.lms.mentor.entity;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.Table;

import java.time.LocalDateTime;

@Entity
@Table(name = "RoomMaterials")
public class RoomMaterial {

    @Id
    @Column(name = "MaterialId", length = 50)
    private String materialId;

    @Column(name = "RoomId", length = 50, nullable = false)
    private String roomId;

    @Column(name = "UploadedBy", length = 50, nullable = false)
    private String uploadedBy;

    @Column(name = "FileName", length = 255, nullable = false)
    private String fileName;

    @Column(name = "FileUrl", length = 255, nullable = false)
    private String fileUrl;

    @Column(name = "FileType", length = 50)
    private String fileType;

    @Column(name = "UploadedAt")
    private LocalDateTime uploadedAt;

    @Column(name = "IsVisible")
    private Boolean isVisible;

    protected RoomMaterial() {
    }

    public RoomMaterial(
            String materialId,
            String roomId,
            String uploadedBy,
            String fileName,
            String fileUrl,
            String fileType,
            LocalDateTime uploadedAt,
            Boolean isVisible) {

        this.materialId = materialId;
        this.roomId = roomId;
        this.uploadedBy = uploadedBy;
        this.fileName = fileName;
        this.fileUrl = fileUrl;
        this.fileType = fileType;
        this.uploadedAt = uploadedAt;
        this.isVisible = isVisible;
    }

    public String getMaterialId() {
        return materialId;
    }

    public String getRoomId() {
        return roomId;
    }

    public String getUploadedBy() {
        return uploadedBy;
    }

    public String getFileName() {
        return fileName;
    }

    public String getFileUrl() {
        return fileUrl;
    }

    public String getFileType() {
        return fileType;
    }

    public LocalDateTime getUploadedAt() {
        return uploadedAt;
    }

    public Boolean getIsVisible() {
        return isVisible;
    }
}