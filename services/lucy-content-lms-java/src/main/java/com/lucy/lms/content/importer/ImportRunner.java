package com.lucy.lms.content.importer;

import org.springframework.boot.WebApplicationType;
import org.springframework.boot.builder.SpringApplicationBuilder;
import org.springframework.context.ConfigurableApplicationContext;

import com.lucy.lms.LucyContentLmsApplication;
import com.lucy.lms.content.service.ImportDocxService;
import com.lucy.lms.content.service.ImportDocxService.BatchImportSummary;
import com.lucy.lms.content.service.ImportDocxService.FileImportResult;
import com.lucy.lms.content.service.ImportDocxService.ImportSummary;

public class ImportRunner {
    public static void main(String[] args) {
        System.out.println("=== DOCX BATCH IMPORT ===");

        String importFolderPath = "src/main/resources/import-docx";

        try (ConfigurableApplicationContext context = new SpringApplicationBuilder(LucyContentLmsApplication.class)
                .web(WebApplicationType.NONE)
                .properties("lucy.import-docx.auto-run=false")
                .run(args)) {
            ImportDocxService service = context.getBean(ImportDocxService.class);

            if (args.length > 0 && "raw".equalsIgnoreCase(args[0])) {
                if (args.length > 1) {
                    service.printRawContentFromFile(importFolderPath,
                            String.join(" ", java.util.Arrays.copyOfRange(args, 1, args.length)));
                } else {
                    service.printRawContentFromResourceFiles(importFolderPath);
                }
                return;
            }
            if (args.length > 0 && "parse".equalsIgnoreCase(args[0])) {
                String targetFileName = args.length > 1
                        ? String.join(" ", java.util.Arrays.copyOfRange(args, 1, args.length))
                        : "Eng - STAGE 1 (LEVELS 1-30).docx";
                service.printParsedDocxImportData(importFolderPath, targetFileName);
                return;
            }

            BatchImportSummary batchSummary = service.importAllDocxToDatabase(importFolderPath);

            System.out.println("======================================");
            System.out.println("BATCH RESULT: " + batchSummary);

            for (FileImportResult result : batchSummary.results) {
                System.out.println("--------------------------------------");
                System.out.println(result);

                if (result.success) {
                    ImportSummary summary = result.summary;
                    System.out.println("VERIFY DATABASE: "
                            + service.verifyImportInDatabase(summary.languageId, summary.stageId));
                }
            }
        } catch (Exception e) {
            System.err.println("ERR: Batch import database that bai: " + e.getMessage());
            e.printStackTrace();
        }
    }
}
