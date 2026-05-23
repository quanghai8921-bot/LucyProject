package com.lucy.dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.Types;

import com.lucy.utils.DBConnection;

public class SubLevelDAO {
    public boolean upsert(String subLevelId, String levelId, Integer subLevelNumber, String sublevelTitle,
            String mainTask, String promptHint, Integer subDurationMins) {
        String sql = "INSERT INTO sublevel "
                + "(SubLevelId, LevelId, SubLevelNumber, SublevelTitle, MainTask, PromptHint, SubDurationMins) "
                + "VALUES (?, ?, ?, ?, ?, ?, ?) "
                + "ON DUPLICATE KEY UPDATE "
                + "LevelId = VALUES(LevelId), "
                + "SubLevelNumber = VALUES(SubLevelNumber), "
                + "SublevelTitle = VALUES(SublevelTitle), "
                + "MainTask = VALUES(MainTask), "
                + "PromptHint = VALUES(PromptHint), "
                + "SubDurationMins = VALUES(SubDurationMins)";

        try (Connection conn = DBConnection.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, subLevelId);
            ps.setString(2, levelId);
            setNullableInteger(ps, 3, subLevelNumber);
            ps.setString(4, sublevelTitle);
            ps.setString(5, mainTask);
            ps.setString(6, promptHint);
            setNullableInteger(ps, 7, subDurationMins);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            throw new RuntimeException("Loi khi upsert sublevel: " + subLevelId, e);
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
