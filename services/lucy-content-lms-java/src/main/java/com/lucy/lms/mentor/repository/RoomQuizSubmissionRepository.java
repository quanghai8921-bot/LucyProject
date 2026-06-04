package com.lucy.lms.mentor.repository;

import com.lucy.lms.mentor.entity.RoomQuizSubmission;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;

public interface RoomQuizSubmissionRepository extends JpaRepository<RoomQuizSubmission, String> {
    List<RoomQuizSubmission> findByQuizId(String quizId);
    List<RoomQuizSubmission> findByLearnerId(String learnerId);
    List<RoomQuizSubmission> findByQuizIdAndLearnerId(String quizId, String learnerId);
}
