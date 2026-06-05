package com.lucy.lms.content.repository;

import java.util.Collection;

import org.springframework.data.jpa.repository.JpaRepository;

import com.lucy.lms.content.model.QuestionContent;

public interface QuestionContentRepository extends JpaRepository<QuestionContent, String> {
    long countByQuestionIdIn(Collection<String> questionIds);
}
