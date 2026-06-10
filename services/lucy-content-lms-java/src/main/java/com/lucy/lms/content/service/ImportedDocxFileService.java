package com.lucy.lms.content.service;

import com.lucy.lms.content.model.ImportedDocxFile;
import com.lucy.lms.content.repository.ImportedDocxFileRepository;
import com.lucy.lms.content.service.ImportDocxService.ImportSummary;
import com.lucy.lms.content.service.ImportDocxService.ParsedImportData;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;

import java.io.File;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.StandardCopyOption;
import java.util.Arrays;
import java.util.List;
import java.util.Locale;
import java.util.UUID;

@Service
public class ImportedDocxFileService {
    private final ImportedDocxFileRepository importedDocxFileRepository;
    private final ImportDocxService importDocxService;

    public ImportedDocxFileService(
            ImportedDocxFileRepository importedDocxFileRepository,
            ImportDocxService importDocxService) {
        this.importedDocxFileRepository = importedDocxFileRepository;
        this.importDocxService = importDocxService;
    }

    @Transactional
    public ImportedDocxFile uploadAndImport(MultipartFile file, String uploadedBy, String importDocxPath) {
        if (file == null || file.isEmpty()) {
            throw new IllegalArgumentException("File DOCX khong duoc de trong.");
        }
        String originalName = safeFileName(file.getOriginalFilename());
        if (!originalName.toLowerCase(Locale.ROOT).endsWith(".docx")) {
            throw new IllegalArgumentException("Chi ho tro upload file .docx.");
        }

        try {
            Files.createDirectories(Path.of(importDocxPath));
            Path target = uniqueTargetPath(importDocxPath, originalName);
            Files.copy(file.getInputStream(), target, StandardCopyOption.REPLACE_EXISTING);

            ImportedDocxFile importedFile = new ImportedDocxFile(
                    UUID.randomUUID().toString(),
                    target.getFileName().toString(),
                    target.toString(),
                    blankToNull(uploadedBy));
            importedFile.markChecking();
            importedDocxFileRepository.save(importedFile);

            return parseAndImport(importedFile.getImportedDocxFileId(), importDocxPath);
        } catch (IOException e) {
            throw new RuntimeException("Khong luu duoc file DOCX: " + e.getMessage(), e);
        }
    }

    @Transactional
    public ImportedDocxFile parseAndImport(String importedDocxFileId, String importDocxPath) {
        ImportedDocxFile importedFile = importedDocxFileRepository.findById(importedDocxFileId)
                .orElseThrow(() -> new IllegalArgumentException("Khong tim thay file DOCX: " + importedDocxFileId));

        importedFile.markParsing();
        importedDocxFileRepository.save(importedFile);

        try {
            ParsedImportData parsed = importDocxService.parseDocxImportData(importDocxPath, importedFile.getFileName());
            ImportSummary summary = importDocxService.importDocxToDatabase(importDocxPath, importedFile.getFileName());
            importedFile.markImported(
                    summary.languageId,
                    summary.stageId,
                    parsed.stage.levelStart,
                    parsed.stage.levelEnd);
        } catch (Exception e) {
            importedFile.markFailed(rootMessage(e));
        }

        return importedDocxFileRepository.save(importedFile);
    }

    @Transactional(readOnly = true)
    public List<ImportedDocxFile> listImportedFiles(String languageId) {
        if (languageId == null || languageId.isBlank()) {
            return importedDocxFileRepository.findAllByOrderByUploadedAtDesc();
        }
        return importedDocxFileRepository.findByLanguageIdAndImportStatusOrderByUploadedAtDesc(
                languageId.trim().toUpperCase(Locale.ROOT),
                "IMPORTED");
    }

    @Transactional(readOnly = true)
    public ImportedDocxFile getFile(String importedDocxFileId) {
        return importedDocxFileRepository.findById(importedDocxFileId)
                .orElseThrow(() -> new IllegalArgumentException("Khong tim thay file DOCX: " + importedDocxFileId));
    }

    @Transactional
    public ImportDocxService.BatchImportSummary importFolderAndRecordFiles(String importDocxPath) {
        ImportDocxService.BatchImportSummary batchSummary = new ImportDocxService.BatchImportSummary();

        for (File file : listDocxFiles(importDocxPath)) {
            ImportDocxService.FileImportResult result = new ImportDocxService.FileImportResult();
            result.fileName = file.getName();

            ImportedDocxFile importedFile = importedDocxFileRepository
                    .findFirstByFileNameOrderByUploadedAtDesc(file.getName())
                    .orElseGet(() -> importedDocxFileRepository.save(new ImportedDocxFile(
                            UUID.randomUUID().toString(),
                            file.getName(),
                            file.getPath(),
                            null)));

            importedFile.markParsing();
            importedDocxFileRepository.save(importedFile);

            try {
                ParsedImportData parsed = importDocxService.parseDocxImportData(importDocxPath, file.getName());
                ImportSummary summary = importDocxService.importDocxToDatabase(importDocxPath, file.getName());
                importedFile.markImported(
                        summary.languageId,
                        summary.stageId,
                        parsed.stage.levelStart,
                        parsed.stage.levelEnd);
                result.summary = summary;
                result.success = true;
                batchSummary.successCount++;
            } catch (Exception e) {
                importedFile.markFailed(rootMessage(e));
                result.success = false;
                result.errorMessage = rootMessage(e);
                batchSummary.failedCount++;
            }

            importedDocxFileRepository.save(importedFile);
            batchSummary.results.add(result);
        }

        return batchSummary;
    }

    private Path uniqueTargetPath(String importDocxPath, String fileName) {
        Path folder = Path.of(importDocxPath);
        Path target = folder.resolve(fileName);
        if (!Files.exists(target)) {
            return target;
        }
        String base = fileName.substring(0, fileName.length() - 5);
        return folder.resolve(base + "-" + System.currentTimeMillis() + ".docx");
    }

    private String safeFileName(String value) {
        String fileName = value == null || value.isBlank() ? "uploaded.docx" : Path.of(value).getFileName().toString();
        return fileName.replaceAll("[\\\\/:*?\"<>|]", "_");
    }

    private String blankToNull(String value) {
        return value == null || value.isBlank() ? null : value.trim();
    }

    private String rootMessage(Exception e) {
        Throwable current = e;
        while (current.getCause() != null) {
            current = current.getCause();
        }
        return current.getMessage();
    }

    private File[] listDocxFiles(String importDocxPath) {
        File importFolder = new File(importDocxPath);
        if (!importFolder.exists() || !importFolder.isDirectory()) {
            throw new IllegalArgumentException("Khong tim thay folder: " + importFolder.getPath());
        }

        File[] files = importFolder.listFiles((dir, name) -> {
            String normalized = name.toLowerCase(Locale.ROOT);
            return normalized.endsWith(".docx") && !normalized.startsWith("~$");
        });
        if (files == null || files.length == 0) {
            throw new IllegalArgumentException("Khong tim thay file .docx trong folder: " + importFolder.getPath());
        }

        Arrays.sort(files, (first, second) -> first.getName().compareToIgnoreCase(second.getName()));
        return files;
    }
}
