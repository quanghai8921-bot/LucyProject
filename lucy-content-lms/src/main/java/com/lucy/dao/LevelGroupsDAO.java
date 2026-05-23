package com.lucy.dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.Types;

import com.lucy.utils.DBConnection;

public class LevelGroupsDAO {
    public boolean upsert(String groupId, String stageId, String groupTitle, String grCefrLevel,
            Integer grLevelStart, Integer grLevelEnd) {
        String sql = "INSERT INTO levelgroups "
                + "(GroupId, StageId, GroupTitle, GrCefrLevel, GrLevelStart, GrLevelEnd) "
                + "VALUES (?, ?, ?, ?, ?, ?) "
                + "ON DUPLICATE KEY UPDATE "
                + "StageId = VALUES(StageId), "
                + "GroupTitle = VALUES(GroupTitle), "
                + "GrCefrLevel = VALUES(GrCefrLevel), "
                + "GrLevelStart = VALUES(GrLevelStart), "
                + "GrLevelEnd = VALUES(GrLevelEnd)";

        try (Connection conn = DBConnection.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, groupId);
            ps.setString(2, stageId);
            ps.setString(3, groupTitle);
            ps.setString(4, grCefrLevel);
            setNullableInteger(ps, 5, grLevelStart);
            setNullableInteger(ps, 6, grLevelEnd);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            throw new RuntimeException("Loi khi upsert level group: " + groupId, e);
        }
    }

    private void setNullableInteger(PreparedStatement ps, int parameterIndex, Integer value) throws Exception {
        if (value == null) {
            ps.setNull(parameterIndex, Types.INTEGER);
            return;
        }

        ps.setInt(parameterIndex, value);
    }
}
