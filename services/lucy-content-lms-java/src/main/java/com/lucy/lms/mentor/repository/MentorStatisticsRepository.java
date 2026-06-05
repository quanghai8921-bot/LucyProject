package com.lucy.lms.mentor.repository;

import com.lucy.lms.mentor.entity.MentorStatistics;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

public interface MentorStatisticsRepository extends JpaRepository<MentorStatistics, String> {
    Optional<MentorStatistics> findByMentorUserId(String mentorUserId);
}
