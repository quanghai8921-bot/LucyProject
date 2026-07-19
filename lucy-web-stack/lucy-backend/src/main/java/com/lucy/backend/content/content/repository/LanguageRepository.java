package com.lucy.backend.content.content.repository;

import java.util.Optional;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import com.lucy.backend.content.content.model.Language;

public interface LanguageRepository extends JpaRepository<Language, String> {
    Optional<Language> findByLanguageNameIgnoreCase(String languageName);

    @Query("SELECT l.languageName FROM Language l WHERE l.languageId = :languageId")
    String findLanguageNameByLanguageId(@Param("languageId") String languageId);
}
