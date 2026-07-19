package com.lucy.backend.content.content.repository;

import org.springframework.data.jpa.repository.JpaRepository;

import com.lucy.backend.content.content.model.LevelGroup;

public interface LevelGroupRepository extends JpaRepository<LevelGroup, String> {
    long countByStageId(String stageId);
}
