package com.lucy.lms.content.repository;

import com.lucy.lms.content.model.ImportedDocxFile;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;

public interface ImportedDocxFileRepository extends JpaRepository<ImportedDocxFile, String> {
    List<ImportedDocxFile> findByImportStatusOrderByUploadedAtDesc(String importStatus);

    List<ImportedDocxFile> findByLanguageIdAndImportStatusOrderByUploadedAtDesc(String languageId, String importStatus);

    List<ImportedDocxFile> findAllByOrderByUploadedAtDesc();

    Optional<ImportedDocxFile> findFirstByFileNameOrderByUploadedAtDesc(String fileName);
}
