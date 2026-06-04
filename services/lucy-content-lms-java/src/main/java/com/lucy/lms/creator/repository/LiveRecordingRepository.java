package com.lucy.lms.creator.repository;

import com.lucy.lms.creator.entity.LiveRecording;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;
import java.util.Optional;

public interface LiveRecordingRepository extends JpaRepository<LiveRecording, String> {
    Optional<LiveRecording> findByRoomId(String roomId);
    List<LiveRecording> findByCreatorUserId(String creatorUserId);
}
