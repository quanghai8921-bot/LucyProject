package com.lucy.lms.content.repository;

import org.springframework.data.jpa.repository.JpaRepository;

import com.lucy.lms.content.model.LevelGroup;

public interface LevelGroupRepository extends JpaRepository<LevelGroup, String> {
    long countByStageId(String stageId);
}
