package com.lucy.lms.content.repository;

import org.springframework.data.jpa.repository.JpaRepository;

import com.lucy.lms.content.model.Language;

public interface LanguageRepository extends JpaRepository<Language, String> {
}
