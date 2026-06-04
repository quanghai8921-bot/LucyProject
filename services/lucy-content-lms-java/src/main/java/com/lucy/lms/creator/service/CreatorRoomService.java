package com.lucy.lms.creator.service;

import com.lucy.lms.creator.dto.CreateCreatorRoomRequest;
import com.lucy.lms.creator.entity.LiveRecording;
import com.lucy.lms.creator.entity.PaidContent;
import com.lucy.lms.creator.repository.LiveRecordingRepository;
import com.lucy.lms.creator.repository.PaidContentRepository;
import com.lucy.lms.mentor.entity.Room;
import com.lucy.lms.mentor.entity.Notification;
import com.lucy.lms.mentor.repository.RoomRepository;
import com.lucy.lms.mentor.repository.NotificationRepository;
import com.lucy.lms.mentor.service.RoomService;
import com.lucy.lms.learner.entity.User;
import com.lucy.lms.learner.repository.UserRepository;
import com.lucy.lms.content.model.LearningLevel;
import com.lucy.lms.content.model.SubLevel;
import com.lucy.lms.content.repository.LearningLevelRepository;
import com.lucy.lms.content.repository.SubLevelRepository;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.time.Duration;
import java.time.LocalDateTime;
import java.util.*;
import java.util.UUID;

@Service
public class CreatorRoomService {

    private final RoomRepository roomRepository;
    private final LiveRecordingRepository liveRecordingRepository;
    private final PaidContentRepository paidContentRepository;
    private final NotificationRepository notificationRepository;
    private final UserRepository userRepository;
    private final RoomService mentorRoomService;
    private final LearningLevelRepository learningLevelRepository;
    private final SubLevelRepository subLevelRepository;

    public CreatorRoomService(RoomRepository roomRepository,
                              LiveRecordingRepository liveRecordingRepository,
                              PaidContentRepository paidContentRepository,
                              NotificationRepository notificationRepository,
                              UserRepository userRepository,
                              RoomService mentorRoomService,
                              LearningLevelRepository learningLevelRepository,
                              SubLevelRepository subLevelRepository) {
        this.roomRepository = roomRepository;
        this.liveRecordingRepository = liveRecordingRepository;
        this.paidContentRepository = paidContentRepository;
        this.notificationRepository = notificationRepository;
        this.userRepository = userRepository;
        this.mentorRoomService = mentorRoomService;
        this.learningLevelRepository = learningLevelRepository;
        this.subLevelRepository = subLevelRepository;
    }

    @Transactional
    public Room createRoom(CreateCreatorRoomRequest request) {
        boolean isImmediate = request.getScheduledStartAt() == null ||
                request.getScheduledStartAt().isBefore(LocalDateTime.now().plusMinutes(1));

        LocalDateTime scheduledTime = isImmediate ? LocalDateTime.now() : request.getScheduledStartAt();
        String initialStatus = isImmediate ? "ACTIVE" : "SCHEDULED";

        Room room = new Room(
                UUID.randomUUID().toString(),
                request.getHostUserId(),
                "CREATOR",
                null, // No admin docx Level restriction for Creator
                null, // No admin docx Language restriction for Creator
                request.getRoomTitle(),
                "CREATOR_LIVE",
                request.getAccessType() != null ? request.getAccessType() : "FREE",
                request.getPriceAmount() != null ? request.getPriceAmount() : BigDecimal.ZERO,
                scheduledTime,
                initialStatus,
                request.getMaxParticipants(),
                LocalDateTime.now()
        );

        if (isImmediate) {
            room.setStudyStartedAt(LocalDateTime.now());
        }

        Room savedRoom = roomRepository.save(room);

        // Tạo live recording nếu bật recordOption
        if (Boolean.TRUE.equals(request.getRecordOption())) {
            LiveRecording recording = new LiveRecording(
                    UUID.randomUUID().toString(),
                    savedRoom.getRoomId(),
                    request.getHostUserId(),
                    null,
                    0,
                    "PROCESSING",
                    LocalDateTime.now()
            );
            liveRecordingRepository.save(recording);
        }

        // Bắn thông báo cho mọi người
        String msg = isImmediate
                ? "Content Creator vừa mở phòng live mới: " + request.getRoomTitle()
                : "Content Creator đã lên lịch phòng live: " + request.getRoomTitle();
        sendGlobalNotification("Phòng Live Creator mới", msg, "ROOM", savedRoom.getRoomId());

        return savedRoom;
    }

    @Transactional
    public Room startRoom(String roomId) {
        Room room = roomRepository.findById(roomId)
                .orElseThrow(() -> new IllegalArgumentException("Không tìm thấy phòng: " + roomId));

        if (!"SCHEDULED".equals(room.getRoomStatus())) {
            throw new IllegalStateException("Phòng live phải ở trạng thái SCHEDULED mới bắt đầu được.");
        }

        room.setRoomStatus("ACTIVE");
        room.setStudyStartedAt(LocalDateTime.now());
        Room savedRoom = roomRepository.save(room);

        sendGlobalNotification("Phòng live đã mở", "Creator đã bắt đầu live: " + room.getRoomTitle(), "ROOM", roomId);
        return savedRoom;
    }

    @Transactional
    public Room endRoom(String roomId, boolean convertToPodcast) {
        Room room = roomRepository.findById(roomId)
                .orElseThrow(() -> new IllegalArgumentException("Không tìm thấy phòng: " + roomId));

        room.setRoomStatus("ENDED");
        room.setEndedAt(LocalDateTime.now());
        Room savedRoom = roomRepository.save(room);

        // Xử lý live recording
        liveRecordingRepository.findByRoomId(roomId).ifPresent(rec -> {
            rec.setCompletedAt(LocalDateTime.now());
            rec.setRecordingStatus("COMPLETED");
            long mins = Duration.between(rec.getCreatedAt(), LocalDateTime.now()).toMinutes();
            rec.setDurationMinutes((int) Math.max(1, mins));
            rec.setAudioUrl("http://lucy-cdn/recordings/" + rec.getRecordingId() + ".mp3");
            liveRecordingRepository.save(rec);

            // Chuyển thành Podcast nháp nếu được chọn
            if (convertToPodcast) {
                PaidContent podcast = new PaidContent(
                        UUID.randomUUID().toString(),
                        room.getHostUserId(),
                        roomId,
                        rec.getRecordingId(),
                        "PODCAST",
                        room.getRoomTitle(),
                        "Bản ghi Podcast được chuyển đổi tự động từ buổi Live: " + room.getRoomTitle(),
                        null,
                        rec.getAudioUrl(),
                        BigDecimal.ZERO, // Draft mặc định giá 0
                        "DRAFT",
                        null
                );
                paidContentRepository.save(podcast);
            }
        });

        return savedRoom;
    }

    public List<PaidContent> getPodcastsByCreator(String creatorId) {
        return paidContentRepository.findByCreatorUserIdAndContentType(creatorId, "PODCAST");
    }

    public List<PaidContent> getContentsByCreator(String creatorId) {
        return paidContentRepository.findByCreatorUserId(creatorId);
    }

    // === Mentor Features for Creator (Level Up Support) ===
    
    public Map<String, Object> getLevelDetailsByLanguageAndNumber(String languageId, Integer levelNumber) {
        return mentorRoomService.getLevelDetailsByLanguageAndNumber(languageId, levelNumber);
    }

    public List<Room> getRoomsByCreator(String hostUserId) {
        return roomRepository.findByHostUserId(hostUserId);
    }

    public Room getMentorRoom(String roomId) {
        return roomRepository.findById(roomId)
                .orElseThrow(() -> new IllegalArgumentException("Không tìm thấy phòng: " + roomId));
    }

    public PaidContent createPaidContent(com.lucy.lms.creator.dto.CreatePaidContentRequest request) {
        PaidContent content = new PaidContent(
                UUID.randomUUID().toString(),
                request.getCreatorUserId(),
                request.getRoomId(),
                request.getRecordingId(),
                request.getContentType() != null ? request.getContentType() : "PAID_LIVE",
                request.getTitle(),
                request.getDescriptionText(),
                request.getThumbnailUrl(),
                request.getAudioUrl(),
                request.getPriceAmount() != null ? request.getPriceAmount() : BigDecimal.ZERO,
                request.getContentStatus() != null ? request.getContentStatus() : "DRAFT",
                request.getPublishedAt()
        );

        return paidContentRepository.save(content);
    }

    @Transactional
    public PaidContent publishPodcast(String contentId, BigDecimal price) {
        PaidContent content = paidContentRepository.findById(contentId)
                .orElseThrow(() -> new IllegalArgumentException("Không tìm thấy nội dung: " + contentId));

        content.setContentStatus("PUBLISHED");
        content.setPublishedAt(LocalDateTime.now());
        if (price != null) {
            content.setPriceAmount(price);
        }
        return paidContentRepository.save(content);
    }

    private void sendGlobalNotification(String title, String bodyText, String refType, String refId) {
        List<User> users = userRepository.findAll();
        for (User user : users) {
            Notification notification = new Notification(
                    UUID.randomUUID().toString(),
                    user.getUserId(),
                    title,
                    bodyText,
                    "SYSTEM",
                    refType + ":" + refId,
                    0,
                    LocalDateTime.now()
            );
            notificationRepository.save(notification);
        }
    }
}
