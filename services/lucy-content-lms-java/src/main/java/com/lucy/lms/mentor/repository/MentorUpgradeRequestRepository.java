package com.lucy.lms.mentor.repository;

import com.lucy.lms.mentor.entity.MentorUpgradeRequest;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;
import java.util.Optional;

public interface MentorUpgradeRequestRepository extends JpaRepository<MentorUpgradeRequest, String> {
    Optional<MentorUpgradeRequest> findByMentorUserIdAndRequestStatus(String mentorUserId, String requestStatus);
    List<MentorUpgradeRequest> findByRequestStatus(String requestStatus);
    List<MentorUpgradeRequest> findByMentorUserId(String mentorUserId);
}
