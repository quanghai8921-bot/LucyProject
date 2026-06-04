package com.lucy.lms.mentor.dto;

public class CreateRoomMaterialRequest {

    private String roomId;
    private String uploadedBy;
    private String fileName;
    private String fileUrl;
    private String fileType;

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
}