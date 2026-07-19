package com.lucy.backend.content.content.repository;

import java.util.Collection;

import org.springframework.data.jpa.repository.JpaRepository;

import com.lucy.backend.content.content.model.SampleAnswer;

public interface SampleAnswerRepository extends JpaRepository<SampleAnswer, String> {
    long countByQuestionIdIn(Collection<String> questionIds);
}
