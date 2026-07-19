package com.lucy.backend.content.content.repository;

import org.springframework.data.jpa.repository.JpaRepository;

import com.lucy.backend.content.content.model.StageDesignNote;

public interface StageDesignNoteRepository extends JpaRepository<StageDesignNote, String> {
    long countByStageId(String stageId);
}
