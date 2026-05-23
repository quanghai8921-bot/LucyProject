package com.lucy.dao;

import java.sql.Connection;
import java.sql.PreparedStatement;

import com.lucy.utils.DBConnection;

public class LevelsDAO {
    public boolean upsert(String levelId, String groupId, String stageId, String levelTitle, Integer levelNumber) {
        String sql = "INSERT INTO levels (LevelId, GroupId, StageId, LevelTitle, LevelNumber) "
                + "VALUES (?, ?, ?, ?, ?) "
                + "ON DUPLICATE KEY UPDATE "
                + "GroupId = VALUES(GroupId), "
                + "StageId = VALUES(StageId), "
                + "LevelTitle = VALUES(LevelTitle), "
                + "LevelNumber = VALUES(LevelNumber)";

        try (Connection conn = DBConnection.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, levelId);
            ps.setString(2, groupId);
            ps.setString(3, stageId);
            ps.setString(4, levelTitle);
            ps.setInt(5, levelNumber);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            throw new RuntimeException("Loi khi upsert level: " + levelId, e);
        }
    }
}
