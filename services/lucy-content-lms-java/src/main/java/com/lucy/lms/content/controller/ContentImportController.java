package com.lucy.lms.content.controller;

import java.util.Map;
import java.util.List;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.multipart.MultipartFile;

import com.lucy.lms.content.model.ImportedDocxFile;
import com.lucy.lms.content.service.ImportDocxService;
import com.lucy.lms.content.service.ImportDocxService.BatchImportSummary;
import com.lucy.lms.content.service.ImportDocxService.ImportSummary;
import com.lucy.lms.content.service.ImportDocxService.ParsedImportData;
import com.lucy.lms.content.service.ImportedDocxFileService;

@RestController
@RequestMapping("/api/import-docx")
public class ContentImportController {

    private final ImportDocxService importDocxService;
    private final ImportedDocxFileService importedDocxFileService;
    private final String importDocxPath;

    public ContentImportController(
            ImportDocxService importDocxService,
            ImportedDocxFileService importedDocxFileService,
            @Value("${lucy.import-docx.path:src/main/resources/import-docx}") String importDocxPath) {
        this.importDocxService = importDocxService;
        this.importedDocxFileService = importedDocxFileService;
        this.importDocxPath = importDocxPath;
    }

    @PostMapping("/upload")
    public ImportedDocxFile uploadFile(
            @RequestParam("file") MultipartFile file,
            @RequestParam(value = "uploadedBy", required = false) String uploadedBy) {
        return importedDocxFileService.uploadAndImport(file, uploadedBy, importDocxPath);
    }

    @GetMapping("/files")
    public List<ImportedDocxFile> listFiles(
            @RequestParam(value = "languageId", required = false) String languageId) {
        return importedDocxFileService.listImportedFiles(languageId);
    }

    @GetMapping("/parse/{fileName}")
    public ParsedImportData parseFile(@PathVariable String fileName) {
        return importDocxService.parseDocxImportData(importDocxPath, fileName);
    }

    @PostMapping("/{fileName}")
    public ImportSummary importFile(@PathVariable String fileName) {
        return importDocxService.importDocxToDatabase(importDocxPath, fileName);
    }

    @PostMapping
    public BatchImportSummary importAll() {
        return importedDocxFileService.importFolderAndRecordFiles(importDocxPath);
    }

    @GetMapping("/verify/{languageId}/{stageId}")
    public ImportSummary verify(@PathVariable String languageId, @PathVariable String stageId) {
        return importDocxService.verifyImportInDatabase(languageId, stageId);
    }

    @GetMapping("/folder")
    public Map<String, String> importFolder() {
        return Map.of("path", importDocxPath);
    }
}
