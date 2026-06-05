package com.lucy.lms.content.importer;

import org.springframework.boot.ApplicationArguments;
import org.springframework.boot.ApplicationRunner;
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;

import com.lucy.lms.content.service.ImportDocxService;
import com.lucy.lms.content.service.ImportDocxService.BatchImportSummary;
import com.lucy.lms.content.service.ImportDocxService.FileImportResult;

@Component
@ConditionalOnProperty(prefix = "lucy.import-docx", name = "auto-run", havingValue = "true")
public class StartupDocxImportRunner implements ApplicationRunner {
    private static final int EXPECTED_DOCX_FILE_COUNT = 8;

    private final ImportDocxService importDocxService;
    private final String importDocxPath;

    public StartupDocxImportRunner(
            ImportDocxService importDocxService,
            @Value("${lucy.import-docx.path:src/main/resources/import-docx}") String importDocxPath) {
        this.importDocxService = importDocxService;
        this.importDocxPath = importDocxPath;
    }

    @Override
    public void run(ApplicationArguments args) {
        System.out.println("=== DOCX STARTUP IMPORT ===");
        System.out.println("Bat dau quet keyword trong folder: " + importDocxPath);

        BatchImportSummary summary = importDocxService.importAllDocxToDatabase(importDocxPath);

        if (summary.results.size() == EXPECTED_DOCX_FILE_COUNT
                && summary.successCount == EXPECTED_DOCX_FILE_COUNT
                && summary.failedCount == 0) {
            System.out.println("Da quet 8 file va import thanh cong.");
            return;
        }

        System.err.println("Import DOCX chua thanh cong.");
        System.err.println("So file da quet: " + summary.results.size());
        System.err.println("Thanh cong: " + summary.successCount + ", That bai: " + summary.failedCount);
        for (FileImportResult result : summary.results) {
            if (!result.success) {
                System.err.println("FAILED: " + result.fileName + " -> " + result.errorMessage);
            }
        }

        throw new IllegalStateException("Import DOCX that bai hoac khong du 8 file.");
    }
}
