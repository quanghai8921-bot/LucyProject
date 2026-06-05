package com.lucy.lms.content.repository;

import org.springframework.data.jpa.repository.JpaRepository;

import com.lucy.lms.content.model.Stage;

public interface StageRepository extends JpaRepository<Stage, String> {
}
