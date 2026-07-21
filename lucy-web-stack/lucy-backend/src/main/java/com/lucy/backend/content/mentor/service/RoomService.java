package com.lucy.backend.content.mentor.service;

import com.lucy.backend.content.content.model.LearningLevel;
import com.lucy.backend.content.content.model.SubLevel;
import com.lucy.backend.content.content.repository.LearningLevelRepository;
import com.lucy.backend.content.content.repository.SubLevelRepository;
import com.lucy.backend.content.learner.repository.RoomParticipantRepository;
import com.lucy.backend.content.mentor.dto.CreateMentorRoomRequest;
import com.lucy.backend.content.mentor.entity.Room;
import com.lucy.backend.content.mentor.entity.RoomSubLevel;
import com.lucy.backend.content.mentor.repository.RoomRepository;
import com.lucy.backend.content.mentor.repository.RoomSubLevelRepository;
import com.lucy.backend.content.mentor.repository.PinnedMaterialRepository;
import com.lucy.backend.content.content.repository.LanguageRepository;
import com.lucy.backend.content.content.repository.StageRepository;
import com.lucy.backend.content.content.model.Language;
import com.lucy.backend.content.content.model.Stage;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import com.lucy.backend.auth.repository.AvatarPersonaRepository;
import com.lucy.backend.content.learner.dto.RoomParticipantDto;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;
import java.util.UUID;

@Service
public class RoomService {

    private final RoomRepository roomRepository;
    private final RoomParticipantRepository participantRepository;
    private final AvatarPersonaRepository avatarPersonaRepository;
    private final RoomSubLevelRepository roomSubLevelRepository;
    private final LearningLevelRepository learningLevelRepository;
    private final SubLevelRepository subLevelRepository;
    private final LanguageRepository languageRepository;
    private final StageRepository stageRepository;
    private final PinnedMaterialRepository pinnedMaterialRepository;

    public RoomService(
            RoomRepository roomRepository,
            RoomParticipantRepository participantRepository,
            AvatarPersonaRepository avatarPersonaRepository,
            RoomSubLevelRepository roomSubLevelRepository,
            LearningLevelRepository learningLevelRepository,
            SubLevelRepository subLevelRepository,
            LanguageRepository languageRepository,
            StageRepository stageRepository,
            PinnedMaterialRepository pinnedMaterialRepository) {
        this.roomRepository = roomRepository;
        this.participantRepository = participantRepository;
        this.avatarPersonaRepository = avatarPersonaRepository;
        this.roomSubLevelRepository = roomSubLevelRepository;
        this.learningLevelRepository = learningLevelRepository;
        this.subLevelRepository = subLevelRepository;
        this.languageRepository = languageRepository;
        this.stageRepository = stageRepository;
        this.pinnedMaterialRepository = pinnedMaterialRepository;
    }

    @Transactional
    public Room createRoom(CreateMentorRoomRequest request) {
        String realLanguageId = null;
        String levelId = null;

        if (request.getLanguageId() != null && !request.getLanguageId().isBlank()) {
            Language lang = languageRepository.findByLanguageNameIgnoreCase(request.getLanguageId())
                    .orElseThrow(() -> new IllegalArgumentException("Language not found: " + request.getLanguageId()));
            realLanguageId = lang.getLanguageId();
            levelId = resolveRoomLevelId(request, lang);
        }

        Room room = new Room(
                UUID.randomUUID().toString(),
                request.getHostUserId(),
                normalizeHostRole(request.getHostRole()),
                levelId,
                realLanguageId,
                request.getRoomTitle(),
                request.getRoomType() != null && !request.getRoomType().isBlank() ? request.getRoomType() : "LIVE",
                normalizeAccessType(request.getAccessType(), request.getPriceAmount()),
                request.getPriceAmount() != null ? request.getPriceAmount() : BigDecimal.ZERO,
                request.getScheduledStartAt(),
                request.getRoomStatus() != null ? request.getRoomStatus() : "SCHEDULED");

        enrichRoom(room);
        Room saved = roomRepository.save(room);

        // 🌟 Chỉ tạo lộ trình chương trình học phụ nếu phòng này có cấp độ (Dạy ngoại
        // ngữ)
        if (levelId != null) {
            prepareRoomSubLevels(saved);
        }

        enrichRoom(saved);
        return saved;
    }

    private String resolveRoomLevelId(CreateMentorRoomRequest request, Language lang) {
        if (request.getLevelId() != null && !request.getLevelId().isBlank()) {
            return request.getLevelId().trim();
        }
        if (request.getLevelNumber() == null) {
            return null;
        }
        if (request.getLevelNumber() <= 0) {
            throw new IllegalArgumentException("LevelNumber phai lon hon 0.");
        }

        List<Stage> stages = stageRepository.findByLanguageId(lang.getLanguageId());

        List<LearningLevel> allLevelsForLanguage = new java.util.ArrayList<>();
        for (Stage stage : stages) {
            allLevelsForLanguage.addAll(learningLevelRepository.findByStageIdOrderByLevelNumberAsc(stage.getStageId()));
        }

        LearningLevel targetLevel = null;
        for (LearningLevel level : allLevelsForLanguage) {
            if (level.getLevelNumber().equals(request.getLevelNumber())) {
                targetLevel = level;
                break;
            }
        }

        if (targetLevel == null && !allLevelsForLanguage.isEmpty()) {
            if (request.getLevelNumber() > 0 && request.getLevelNumber() <= allLevelsForLanguage.size()) {
                targetLevel = allLevelsForLanguage.get(request.getLevelNumber() - 1);
            } else {
                targetLevel = allLevelsForLanguage.get(0);
            }
        }

        if (targetLevel == null) {
            throw new IllegalArgumentException(
                    "Level " + request.getLevelNumber() + " not found for language " + request.getLanguageId());
        }

        return targetLevel.getLevelId();
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
        rooms.forEach(room -> {
            enrichRoom(room);
            // 🌟 Nếu trong DB chưa có levelNumber thì tự động update lưu lại vào DB
            if (room.getLevelNumber() != null) {
                roomRepository.save(room);
            }
        });
        return rooms;
    }

    public List<Room> getRoomsByMentor(String hostUserId) {
        List<Room> rooms = roomRepository.findByHostUserId(hostUserId);
        rooms.forEach(this::enrichRoom);
        return rooms;
    }

    public List<RoomParticipantDto> getRoomParticipants(String roomId) {
        return participantRepository.findByRoomIdAndParticipantStatus(roomId, "JOINED").stream()
                .map(p -> {
                    RoomParticipantDto dto = new RoomParticipantDto(p);
                    avatarPersonaRepository.findById(p.getUserId()).ifPresent(persona -> {
                        dto.setDisplayName(persona.getDisplayName());
                        dto.setAvatarUrl(persona.getAvatarUrl());
                    });
                    if (dto.getDisplayName() == null) {
                        dto.setDisplayName("Học viên " + p.getUserId());
                    }
                    return dto;
                })
                .toList();
    }

    @Transactional
    public Room endRoom(String roomId) {
        Room room = roomRepository.findById(roomId)
                .orElseThrow(() -> new IllegalArgumentException("Room not found: " + roomId));
        room.setRoomStatus("ENDED");
        room.setEndedAt(LocalDateTime.now());

        // Delete all pinned materials for this room when ending
        pinnedMaterialRepository.deleteByRoomId(roomId);

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
                        null))
                .toList();
        return roomSubLevelRepository.saveAll(roomSubLevels);
    }

    private void enrichRoom(Room room) {
        String mentorName = roomRepository.findMentorFullNameByUserId(room.getHostUserId());
        room.setHostUserName(mentorName != null ? mentorName : room.getHostUserId());
        room.setParticipantCount(participantRepository.countByRoomIdAndParticipantStatus(room.getRoomId(), "JOINED"));
        if (room.getLevelId() != null) {
            learningLevelRepository.findById(room.getLevelId())
                    .ifPresent(lvl -> room.setLevelNumber(lvl.getLevelNumber()));
        }
        if (room.getLanguageId() != null) {
            String langName = languageRepository.findLanguageNameByLanguageId(room.getLanguageId());
            room.setLanguageName(langName != null ? langName : "Language");
        }
    }

}
