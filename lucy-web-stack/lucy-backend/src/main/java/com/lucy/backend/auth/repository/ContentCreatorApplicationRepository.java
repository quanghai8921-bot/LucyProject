package com.lucy.backend.auth.repository;

import com.lucy.backend.auth.entity.ContentCreatorApplication;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

import java.util.Optional;

@Repository
public interface ContentCreatorApplicationRepository extends JpaRepository<ContentCreatorApplication, String> {
    List<ContentCreatorApplication> findAllByOrderBySubmittedAtDesc();
    Optional<ContentCreatorApplication> findByUserId(String userId);
}
