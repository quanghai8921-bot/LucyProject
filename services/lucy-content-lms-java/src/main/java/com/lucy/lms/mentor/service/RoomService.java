package com.lucy.lms.mentor.service;

import com.lucy.lms.mentor.dto.CreateMentorRoomRequest;
import com.lucy.lms.mentor.entity.Room;
import com.lucy.lms.mentor.entity.Notification;
import com.lucy.lms.mentor.repository.RoomRepository;
import com.lucy.lms.mentor.repository.NotificationRepository;
import com.lucy.lms.learner.entity.User;
import com.lucy.lms.learner.repository.UserRepository;
import com.lucy.lms.content.model.LearningLevel;
import com.lucy.lms.content.model.SubLevel;
import com.lucy.lms.content.repository.LearningLevelRepository;
import com.lucy.lms.content.repository.SubLevelRepository;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.*;

@Service
public class RoomService {

    private final RoomRepository roomRepository;
    private final LearningLevelRepository learningLevelRepository;
    private final SubLevelRepository subLevelRepository;
    private final NotificationRepository notificationRepository;
    private final UserRepository userRepository;

    public RoomService(RoomRepository roomRepository,
                       LearningLevelRepository learningLevelRepository,
                       SubLevelRepository subLevelRepository,
                       NotificationRepository notificationRepository,
                       UserRepository userRepository) {
        this.roomRepository = roomRepository;
        this.learningLevelRepository = learningLevelRepository;
        this.subLevelRepository = subLevelRepository;
        this.notificationRepository = notificationRepository;
        this.userRepository = userRepository;
    }

    @Transactional
    public Room createRoom(CreateMentorRoomRequest request) {
        if (request.getLanguageId() == null || request.getLevelId() == null) {
            throw new IllegalArgumentException("LevelId và languageId phải được chọn để tạo phòng mentor.");
        }

        com.lucy.lms.content.model.LearningLevel level = learningLevelRepository.findById(request.getLevelId())
                .orElseThrow(() -> new IllegalArgumentException("Không tìm thấy level: " + request.getLevelId()));

        if (!level.getStageId().startsWith(request.getLanguageId() + "_STAGE_")) {
            throw new IllegalArgumentException("Level này không thuộc ngôn ngữ đã chọn.");
        }

        boolean isImmediate = request.getScheduledStartAt() == null ||
                request.getScheduledStartAt().isBefore(LocalDateTime.now().plusMinutes(1));

        LocalDateTime scheduledTime = isImmediate ? LocalDateTime.now() : request.getScheduledStartAt();
        String initialStatus = isImmediate ? "ACTIVE" : "SCHEDULED";

        Room room = new Room(
                UUID.randomUUID().toString(),
                request.getHostUserId(),
                "MENTOR",
                request.getLevelId(),
                request.getLanguageId(),
                request.getRoomTitle(),
                "LIVE",
                "FREE",
                BigDecimal.ZERO,
                scheduledTime,
                initialStatus,
                request.getMaxParticipants(),
                LocalDateTime.now());

        if (isImmediate) {
            room.setStudyStartedAt(LocalDateTime.now());
        }

        Room savedRoom = roomRepository.save(room);

        // Bắn thông báo cho mọi người
        String msg = isImmediate
                ? "Mentor vừa tạo phòng và bắt đầu học ngay: " + request.getRoomTitle()
                : "Mentor đã lên lịch mở phòng: " + request.getRoomTitle();
        sendGlobalNotification("Phòng học mới", msg, "ROOM", savedRoom.getRoomId());

        return savedRoom;
    }

    @Transactional
    public Room startRoom(String roomId) {
        Room room = roomRepository.findById(roomId)
                .orElseThrow(() -> new IllegalArgumentException("Không tìm thấy phòng: " + roomId));

        if (!"SCHEDULED".equals(room.getRoomStatus())) {
            throw new IllegalStateException("Phòng học phải ở trạng thái SCHEDULED mới có thể bắt đầu.");
        }

        room.setRoomStatus("ACTIVE");
        room.setStudyStartedAt(LocalDateTime.now());
        Room savedRoom = roomRepository.save(room);

        sendGlobalNotification("Phòng live đã mở", "Mentor đã bắt đầu phòng học: " + room.getRoomTitle(), "ROOM", roomId);
        return savedRoom;
    }

    @Transactional
    public Room endRoom(String roomId) {
        Room room = roomRepository.findById(roomId)
                .orElseThrow(() -> new IllegalArgumentException("Không tìm thấy phòng: " + roomId));

        room.setRoomStatus("ENDED");
        room.setEndedAt(LocalDateTime.now());
        return roomRepository.save(room);
    }

    public List<Room> getAllRooms() {
        return roomRepository.findAll();
    }

    public List<Room> getRoomsByMentor(String hostUserId) {
        return roomRepository.findByHostUserId(hostUserId);
    }

    public Map<String, Object> getLevelDetailsByLanguageAndNumber(String languageId, Integer levelNumber) {
        List<LearningLevel> levels = learningLevelRepository.findByLanguageAndLevelNumber(languageId, levelNumber);
        if (levels.isEmpty()) {
            throw new NoSuchElementException("Không tìm thấy thông tin level cho ngôn ngữ " + languageId + " và level " + levelNumber);
        }

        LearningLevel level = levels.get(0);
        List<SubLevel> subLevels = subLevelRepository.findByLevelId(level.getLevelId());

        Map<String, Object> result = new LinkedHashMap<>();
        result.put("levelId", level.getLevelId());
        result.put("groupId", level.getGroupId());
        result.put("stageId", level.getStageId());
        result.put("levelTitle", level.getLevelTitle());
        result.put("levelNumber", level.getLevelNumber());
        result.put("levelDescription", level.getLevelDescription());

        List<Map<String, Object>> sublevelList = new ArrayList<>();
        for (SubLevel sub : subLevels) {
            Map<String, Object> subMap = new LinkedHashMap<>();
            subMap.put("subLevelId", sub.getSubLevelId());
            subMap.put("levelId", sub.getLevelId());
            subMap.put("subLevelNumber", sub.getSubLevelNumber());
            subMap.put("sublevelTitle", sub.getSublevelTitle());
            subMap.put("mainTask", sub.getMainTask());
            subMap.put("promptHint", sub.getPromptHint());
            subMap.put("subDurationMins", sub.getSubDurationMins());
            sublevelList.add(subMap);
        }
        result.put("sublevels", sublevelList);

        return result;
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