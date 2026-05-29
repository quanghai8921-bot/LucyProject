package com.lucy.lms;

import static org.assertj.core.api.Assertions.assertThat;

import java.io.File;

import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.condition.EnabledIfSystemProperty;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.TestPropertySource;

import com.lucy.lms.content.service.ImportDocxService;
import com.lucy.lms.content.service.ImportDocxService.BatchImportSummary;
import com.lucy.lms.content.service.ImportDocxService.FileImportResult;

@SpringBootTest
@TestPropertySource(
        locations = "file:src/main/resources/application.properties",
        properties = "lucy.import-docx.auto-run=false")
@EnabledIfSystemProperty(named = "lucy.import.test.enabled", matches = "true")
class ImportDocxServiceFileScanTest {

    private static final String IMPORT_FOLDER = "src/main/resources/import-docx";

    @Autowired
    private ImportDocxService importDocxService;

    @Test
    void importsAllEightBundledDocxFiles() {
        File[] files = new File(IMPORT_FOLDER).listFiles((dir, name) -> name.endsWith(".docx") && !name.startsWith("~$"));

        assertThat(files).isNotNull();
        assertThat(files).hasSize(8);

        BatchImportSummary summary = importDocxService.importAllDocxToDatabase(IMPORT_FOLDER);

        System.out.println("DOCX IMPORT RESULT: success=" + summary.successCount + ", failed=" + summary.failedCount);
        for (FileImportResult result : summary.results) {
            if (result.success) {
                System.out.println("DOCX IMPORT SUCCESS: " + result.fileName + " -> " + result.summary);
            } else {
                System.err.println("DOCX IMPORT FAILED: " + result.fileName + " -> " + result.errorMessage);
            }
        }

        assertThat(summary.results).hasSize(8);
        assertThat(summary.failedCount).isZero();
        assertThat(summary.successCount).isEqualTo(8);
    }
}
