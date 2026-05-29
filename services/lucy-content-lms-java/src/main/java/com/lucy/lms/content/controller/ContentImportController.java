package com.lucy.lms.content.controller;

import java.util.Map;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.lucy.lms.content.service.ImportDocxService;
import com.lucy.lms.content.service.ImportDocxService.BatchImportSummary;
import com.lucy.lms.content.service.ImportDocxService.ImportSummary;
import com.lucy.lms.content.service.ImportDocxService.ParsedImportData;

@RestController
@RequestMapping("/api/import-docx")
public class ContentImportController {

    private final ImportDocxService importDocxService;
    private final String importDocxPath;

    public ContentImportController(
            ImportDocxService importDocxService,
            @Value("${lucy.import-docx.path:src/main/resources/import-docx}") String importDocxPath) {
        this.importDocxService = importDocxService;
        this.importDocxPath = importDocxPath;
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
        return importDocxService.importAllDocxToDatabase(importDocxPath);
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
