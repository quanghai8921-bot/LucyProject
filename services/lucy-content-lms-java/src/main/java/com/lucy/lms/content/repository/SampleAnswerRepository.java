package com.lucy.lms.content.repository;

import java.util.Collection;

import org.springframework.data.jpa.repository.JpaRepository;

import com.lucy.lms.content.model.SampleAnswer;

public interface SampleAnswerRepository extends JpaRepository<SampleAnswer, String> {
    long countByQuestionIdIn(Collection<String> questionIds);
}
