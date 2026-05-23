package com.lucy.importer;

import com.lucy.service.ImportDocxService;
import com.lucy.service.ImportDocxService.BatchImportSummary;
import com.lucy.service.ImportDocxService.FileImportResult;
import com.lucy.service.ImportDocxService.ImportSummary;

public class ImportRunner {
    public static void main(String[] args) {
        System.out.println("=== DOCX BATCH IMPORT ===");

        String importFolderPath = "src/main/resources/import-docx";
        ImportDocxService service = new ImportDocxService();

        try {
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
