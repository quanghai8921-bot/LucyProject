package com.lucy.lms.content.repository;

import org.springframework.data.jpa.repository.JpaRepository;

import com.lucy.lms.content.model.StageDesignNote;

public interface StageDesignNoteRepository extends JpaRepository<StageDesignNote, String> {
    long countByStageId(String stageId);
}
