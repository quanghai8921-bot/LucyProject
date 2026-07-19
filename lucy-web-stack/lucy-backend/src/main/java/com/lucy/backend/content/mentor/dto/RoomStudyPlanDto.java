package com.lucy.backend.content.mentor.dto;

import com.lucy.backend.content.content.model.LearningLevel;
import com.lucy.backend.content.content.model.LevelGroup;
import com.lucy.backend.content.content.model.SubLevel;
import com.lucy.backend.content.mentor.entity.Room;
import com.lucy.backend.content.mentor.entity.RoomSubLevel;

import java.util.List;

public class RoomStudyPlanDto {
    private final Room room;
    private final LevelGroup levelGroup;
    private final LearningLevel level;
    private final List<SubLevelItem> subLevels;

    public RoomStudyPlanDto(Room room, LevelGroup levelGroup,
            LearningLevel level, List<SubLevelItem> subLevels) {
        this.room = room;
        this.levelGroup = levelGroup;
        this.level = level;
        this.subLevels = subLevels;
    }

    public Room getRoom() {
        return room;
    }


    public LevelGroup getLevelGroup() {
        return levelGroup;
    }

    public LearningLevel getLevel() {
        return level;
    }

    public List<SubLevelItem> getSubLevels() {
        return subLevels;
    }

    public static class SubLevelItem {
        private final SubLevel subLevel;
        private final RoomSubLevel roomSubLevel;

        public SubLevelItem(SubLevel subLevel, RoomSubLevel roomSubLevel) {
            this.subLevel = subLevel;
            this.roomSubLevel = roomSubLevel;
        }

        public SubLevel getSubLevel() {
            return subLevel;
        }

        public RoomSubLevel getRoomSubLevel() {
            return roomSubLevel;
        }
    }
}
