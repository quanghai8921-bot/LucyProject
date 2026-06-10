package com.lucy.lms.content.model;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.Table;

import java.time.LocalDateTime;

@Entity
@Table(name = "ImportedDocxFiles")
public class ImportedDocxFile {
    @Id
    @Column(name = "ImportedDocxFileId", length = 50)
    private String importedDocxFileId;

    @Column(name = "FileName", nullable = false)
    private String fileName;

    @Column(name = "FilePath", nullable = false)
    private String filePath;

    @Column(name = "LanguageId", length = 50)
    private String languageId;

    @Column(name = "StageId", length = 50)
    private String stageId;

    @Column(name = "LevelStart")
    private Integer levelStart;

    @Column(name = "LevelEnd")
    private Integer levelEnd;

    @Column(name = "ImportStatus", length = 30, nullable = false)
    private String importStatus;

    @Column(name = "ErrorMessage")
    private String errorMessage;

    @Column(name = "UploadedBy", length = 50)
    private String uploadedBy;

    @Column(name = "UploadedAt", nullable = false)
    private LocalDateTime uploadedAt;

    @Column(name = "ParsedAt")
    private LocalDateTime parsedAt;

    protected ImportedDocxFile() {
    }

    public ImportedDocxFile(String importedDocxFileId, String fileName, String filePath, String uploadedBy) {
        this.importedDocxFileId = importedDocxFileId;
        this.fileName = fileName;
        this.filePath = filePath;
        this.uploadedBy = uploadedBy;
        this.importStatus = "UPLOADED";
        this.uploadedAt = LocalDateTime.now();
    }

    public void markChecking() {
        this.importStatus = "CHECKING";
        this.errorMessage = null;
    }

    public void markParsing() {
        this.importStatus = "PARSING";
    }

    public void markImported(String languageId, String stageId, Integer levelStart, Integer levelEnd) {
        this.languageId = languageId;
        this.stageId = stageId;
        this.levelStart = levelStart;
        this.levelEnd = levelEnd;
        this.importStatus = "IMPORTED";
        this.parsedAt = LocalDateTime.now();
        this.errorMessage = null;
    }

    public void markFailed(String errorMessage) {
        this.importStatus = "FAILED";
        this.errorMessage = errorMessage == null ? null : errorMessage.substring(0, Math.min(errorMessage.length(), 255));
        this.parsedAt = LocalDateTime.now();
    }

    public String getImportedDocxFileId() {
        return importedDocxFileId;
    }

    public String getFileName() {
        return fileName;
    }

    public String getFilePath() {
        return filePath;
    }

    public String getLanguageId() {
        return languageId;
    }

    public String getStageId() {
        return stageId;
    }

    public Integer getLevelStart() {
        return levelStart;
    }

    public Integer getLevelEnd() {
        return levelEnd;
    }

    public String getImportStatus() {
        return importStatus;
    }

    public String getErrorMessage() {
        return errorMessage;
    }

    public String getUploadedBy() {
        return uploadedBy;
    }

    public LocalDateTime getUploadedAt() {
        return uploadedAt;
    }

    public LocalDateTime getParsedAt() {
        return parsedAt;
    }
}
