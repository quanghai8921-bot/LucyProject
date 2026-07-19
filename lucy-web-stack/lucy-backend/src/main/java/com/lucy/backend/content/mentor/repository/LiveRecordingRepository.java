package com.lucy.backend.content.mentor.repository;

import com.lucy.backend.content.mentor.entity.LiveRecording;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface LiveRecordingRepository extends JpaRepository<LiveRecording, String> {
    Optional<LiveRecording> findByRoomIdAndRecordingStatus(String roomId, String recordingStatus);
}
