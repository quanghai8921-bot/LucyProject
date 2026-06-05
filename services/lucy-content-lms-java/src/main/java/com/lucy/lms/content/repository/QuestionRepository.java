package com.lucy.lms.content.repository;

import java.util.Collection;
import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;

import com.lucy.lms.content.model.Question;

public interface QuestionRepository extends JpaRepository<Question, String> {
    long countBySubLevelIdIn(Collection<String> subLevelIds);

    List<Question> findBySubLevelIdIn(Collection<String> subLevelIds);
}
