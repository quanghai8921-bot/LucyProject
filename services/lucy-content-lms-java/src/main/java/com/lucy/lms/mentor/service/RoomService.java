package com.lucy.lms.mentor.service;

import com.lucy.lms.content.model.ImportedDocxFile;
import com.lucy.lms.content.model.LearningLevel;
import com.lucy.lms.content.model.LevelGroup;
import com.lucy.lms.content.model.SubLevel;
import com.lucy.lms.content.repository.ImportedDocxFileRepository;
import com.lucy.lms.content.repository.LearningLevelRepository;
import com.lucy.lms.content.repository.LevelGroupRepository;
import com.lucy.lms.content.repository.SubLevelRepository;
import com.lucy.lms.learner.repository.RoomParticipantRepository;
import com.lucy.lms.mentor.dto.CreateMentorRoomRequest;
import com.lucy.lms.mentor.dto.RoomStudyPlanDto;
import com.lucy.lms.mentor.entity.Room;
import com.lucy.lms.mentor.entity.RoomSubLevel;
import com.lucy.lms.mentor.repository.RoomRepository;
import com.lucy.lms.mentor.repository.RoomSubLevelRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.UUID;
import java.util.function.Function;
import java.util.stream.Collectors;

@Service
public class RoomService {

    private final RoomRepository roomRepository;
    private final RoomParticipantRepository participantRepository;
    private final RoomSubLevelRepository roomSubLevelRepository;
    private final ImportedDocxFileRepository importedDocxFileRepository;
    private final LearningLevelRepository learningLevelRepository;
    private final LevelGroupRepository levelGroupRepository;
    private final SubLevelRepository subLevelRepository;

    public RoomService(
            RoomRepository roomRepository,
            RoomParticipantRepository participantRepository,
            RoomSubLevelRepository roomSubLevelRepository,
            ImportedDocxFileRepository importedDocxFileRepository,
            LearningLevelRepository learningLevelRepository,
            LevelGroupRepository levelGroupRepository,
            SubLevelRepository subLevelRepository) {
        this.roomRepository = roomRepository;
        this.participantRepository = participantRepository;
        this.roomSubLevelRepository = roomSubLevelRepository;
        this.importedDocxFileRepository = importedDocxFileRepository;
        this.learningLevelRepository = learningLevelRepository;
        this.levelGroupRepository = levelGroupRepository;
        this.subLevelRepository = subLevelRepository;
    }

    @Transactional
    public Room createRoom(CreateMentorRoomRequest request) {
        String levelId = resolveRoomLevelId(request);

        Room room = new Room(
                UUID.randomUUID().toString(),
                request.getHostUserId(),
                normalizeHostRole(request.getHostRole()),
                levelId,
                request.getLanguageId(),
                request.getImportedDocxFileId(),
                request.getRoomTitle(),
                "LIVE",
                normalizeAccessType(request.getAccessType(), request.getPriceAmount()),
                request.getPriceAmount() != null ? request.getPriceAmount() : BigDecimal.ZERO,
                request.getScheduledStartAt(),
                request.getRoomStatus() != null ? request.getRoomStatus() : "SCHEDULED",
                request.getMaxParticipants(),
                LocalDateTime.now());

        Room saved = roomRepository.save(room);
        prepareRoomSubLevels(saved);
        enrichRoom(saved);
        return saved;
    }

    private String resolveRoomLevelId(CreateMentorRoomRequest request) {
        if (request.getLevelId() != null && !request.getLevelId().isBlank()) {
            return request.getLevelId().trim();
        }
        if (request.getLevelNumber() == null) {
            return null;
        }
        if (request.getLevelNumber() <= 0) {
            throw new IllegalArgumentException("LevelNumber phai lon hon 0.");
        }
        if (request.getLanguageId() == null || request.getLanguageId().isBlank()) {
            throw new IllegalArgumentException("LanguageId la bat buoc khi chon LevelNumber.");
        }

        String stageIdPrefix = request.getLanguageId().trim().toUpperCase(Locale.ROOT) + "_STAGE_";
        List<LearningLevel> levels = learningLevelRepository
                .findByStageIdStartingWithOrderByStageIdAscLevelNumberAsc(stageIdPrefix);
                
        if (levels.isEmpty() || request.getLevelNumber() > levels.size()) {
            throw new IllegalArgumentException(
                    "Level " + request.getLevelNumber() + " khong ton tai cho ngon ngu "
                            + request.getLanguageId() + ".");
        }
        
        LearningLevel level = levels.get(request.getLevelNumber() - 1);
        return level.getLevelId();
    }

    private String normalizeHostRole(String hostRole) {
        if (hostRole == null || hostRole.isBlank()) {
            return "MENTOR";
        }
        String normalized = hostRole.trim().toUpperCase();
        return normalized.equals("CREATOR") ? "CREATOR" : "MENTOR";
    }

    private String normalizeAccessType(String accessType, BigDecimal priceAmount) {
        if (accessType != null && !accessType.isBlank()) {
            String normalized = accessType.trim().toUpperCase();
            return normalized.equals("PAID") ? "PAID" : "FREE";
        }
        return priceAmount != null && priceAmount.compareTo(BigDecimal.ZERO) > 0 ? "PAID" : "FREE";
    }

    public List<Room> getAllRooms() {
        List<Room> rooms = roomRepository.findAll();
        rooms.forEach(this::enrichRoom);
        return rooms;
    }

    public List<Room> getRoomsByMentor(String hostUserId) {
        List<Room> rooms = roomRepository.findByHostUserId(hostUserId);
        rooms.forEach(this::enrichRoom);
        return rooms;
    }

    public Room endRoom(String roomId) {
        Room room = roomRepository.findById(roomId)
                .orElseThrow(() -> new IllegalArgumentException("Room not found: " + roomId));
        room.setRoomStatus("ENDED");
        room.setEndedAt(LocalDateTime.now());
        Room saved = roomRepository.save(room);
        enrichRoom(saved);
        return saved;
    }

    public Room openRoom(String roomId) {
        Room room = roomRepository.findById(roomId)
                .orElseThrow(() -> new IllegalArgumentException("Room not found: " + roomId));
        room.setRoomStatus("OPEN");
        prepareRoomSubLevels(room);
        Room saved = roomRepository.save(room);
        enrichRoom(saved);
        return saved;
    }

    @Transactional
    public Room startStudy(String roomId) {
        Room room = roomRepository.findById(roomId)
                .orElseThrow(() -> new IllegalArgumentException("Room not found: " + roomId));
        room.setRoomStatus("STUDYING");
        if (room.getStudyStartedAt() == null) {
            room.setStudyStartedAt(LocalDateTime.now());
        }
        List<RoomSubLevel> roomSubLevels = prepareRoomSubLevels(room);
        roomSubLevels.stream()
                .filter(item -> "NOT_STARTED".equalsIgnoreCase(item.getStatus()))
                .findFirst()
                .ifPresent(item -> item.start(LocalDateTime.now()));
        roomSubLevelRepository.saveAll(roomSubLevels);
        Room saved = roomRepository.save(room);
        enrichRoom(saved);
        return saved;
    }

    @Transactional
    public RoomStudyPlanDto getStudyPlan(String roomId) {
        Room room = roomRepository.findById(roomId)
                .orElseThrow(() -> new IllegalArgumentException("Room not found: " + roomId));
        prepareRoomSubLevels(room);
        ImportedDocxFile importedFile = room.getImportedDocxFileId() == null
                ? null
                : importedDocxFileRepository.findById(room.getImportedDocxFileId()).orElse(null);
        LearningLevel level = room.getLevelId() == null
                ? null
                : learningLevelRepository.findById(room.getLevelId()).orElse(null);
        LevelGroup group = level == null || level.getGroupId() == null
                ? null
                : levelGroupRepository.findById(level.getGroupId()).orElse(null);
        Map<String, RoomSubLevel> roomSubLevelBySubLevelId = roomSubLevelRepository
                .findByRoomIdOrderByStepOrderAsc(roomId)
                .stream()
                .collect(Collectors.toMap(RoomSubLevel::getSubLevelId, Function.identity()));
        List<RoomStudyPlanDto.SubLevelItem> subLevels = room.getLevelId() == null
                ? List.of()
                : subLevelRepository.findByLevelIdOrderBySubLevelNumberAsc(room.getLevelId()).stream()
                        .map(subLevel -> new RoomStudyPlanDto.SubLevelItem(
                                subLevel,
                                roomSubLevelBySubLevelId.get(subLevel.getSubLevelId())))
                        .toList();
        enrichRoom(room);
        return new RoomStudyPlanDto(room, importedFile, group, level, subLevels);
    }

    @Transactional
    public RoomSubLevel completeSubLevel(String roomId, String subLevelId) {
        RoomSubLevel current = roomSubLevelRepository.findByRoomIdAndSubLevelId(roomId, subLevelId)
                .orElseThrow(() -> new IllegalArgumentException("Room sublevel not found."));
        LocalDateTime now = LocalDateTime.now();
        current.complete(now);
        roomSubLevelRepository.save(current);

        roomSubLevelRepository.findByRoomIdOrderByStepOrderAsc(roomId).stream()
                .filter(item -> item.getStepOrder() > current.getStepOrder())
                .filter(item -> "NOT_STARTED".equalsIgnoreCase(item.getStatus()))
                .findFirst()
                .ifPresent(next -> {
                    next.start(now);
                    roomSubLevelRepository.save(next);
                });
        return current;
    }

    private List<RoomSubLevel> prepareRoomSubLevels(Room room) {
        if (room.getLevelId() == null || room.getLevelId().isBlank()) {
            return List.of();
        }
        List<RoomSubLevel> existing = roomSubLevelRepository.findByRoomIdOrderByStepOrderAsc(room.getRoomId());
        if (!existing.isEmpty()) {
            return existing;
        }
        List<SubLevel> subLevels = subLevelRepository.findByLevelIdOrderBySubLevelNumberAsc(room.getLevelId());
        List<RoomSubLevel> roomSubLevels = subLevels.stream()
                .map(subLevel -> new RoomSubLevel(
                        UUID.randomUUID().toString(),
                        room.getRoomId(),
                        subLevel.getSubLevelId(),
                        subLevel.getSubLevelNumber() == null ? 1 : subLevel.getSubLevelNumber(),
                        subLevel.getSubDurationMins()))
                .toList();
        return roomSubLevelRepository.saveAll(roomSubLevels);
    }

    private void enrichRoom(Room room) {
        String mentorName = roomRepository.findMentorFullNameByUserId(room.getHostUserId());
        room.setHostUserName(mentorName != null ? mentorName : room.getHostUserId());
        room.setParticipantCount(participantRepository.countByRoomIdAndParticipantStatus(room.getRoomId(), "JOINED"));
    }
}
