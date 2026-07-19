package com.lucy.backend.content.content.repository;

import java.util.List;
import org.springframework.data.jpa.repository.JpaRepository;

import com.lucy.backend.content.content.model.Stage;

public interface StageRepository extends JpaRepository<Stage, String> {
    List<Stage> findByLanguageId(String languageId);
}
