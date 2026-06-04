package com.lucy.lms.content.repository;

import java.util.Collection;
import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;

import com.lucy.lms.content.model.SubLevel;

public interface SubLevelRepository extends JpaRepository<SubLevel, String> {
    long countByLevelIdIn(Collection<String> levelIds);

    List<SubLevel> findByLevelIdIn(Collection<String> levelIds);

    List<SubLevel> findByLevelId(String levelId);
}
