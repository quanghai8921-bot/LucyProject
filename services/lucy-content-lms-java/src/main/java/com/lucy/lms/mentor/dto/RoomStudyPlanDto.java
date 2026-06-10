package com.lucy.lms.mentor.dto;

import com.lucy.lms.content.model.ImportedDocxFile;
import com.lucy.lms.content.model.LearningLevel;
import com.lucy.lms.content.model.LevelGroup;
import com.lucy.lms.content.model.SubLevel;
import com.lucy.lms.mentor.entity.Room;
import com.lucy.lms.mentor.entity.RoomSubLevel;

import java.util.List;

public class RoomStudyPlanDto {
    private final Room room;
    private final ImportedDocxFile importedDocxFile;
    private final LevelGroup levelGroup;
    private final LearningLevel level;
    private final List<SubLevelItem> subLevels;

    public RoomStudyPlanDto(Room room, ImportedDocxFile importedDocxFile, LevelGroup levelGroup,
            LearningLevel level, List<SubLevelItem> subLevels) {
        this.room = room;
        this.importedDocxFile = importedDocxFile;
        this.levelGroup = levelGroup;
        this.level = level;
        this.subLevels = subLevels;
    }

    public Room getRoom() {
        return room;
    }

    public ImportedDocxFile getImportedDocxFile() {
        return importedDocxFile;
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
