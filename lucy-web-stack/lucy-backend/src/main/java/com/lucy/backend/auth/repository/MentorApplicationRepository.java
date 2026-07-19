package com.lucy.backend.auth.repository;

import com.lucy.backend.auth.entity.MentorApplication;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

import java.util.Optional;

@Repository
public interface MentorApplicationRepository extends JpaRepository<MentorApplication, String> {
    List<MentorApplication> findAllByOrderBySubmittedAtDesc();
    Optional<MentorApplication> findByUserId(String userId);
}
