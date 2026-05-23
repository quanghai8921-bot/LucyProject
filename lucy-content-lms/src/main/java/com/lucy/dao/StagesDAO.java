package com.lucy.dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.Types;

import com.lucy.utils.DBConnection;

public class StagesDAO {
    public boolean insert(String stageId, String languageId, Integer stageNumber, Integer durationMinutes,
            String ceftStart, String ceftEnd, Integer levelStart, Integer levelEnd, String completionOutcome,
            String descriptions, int isStatus) {
        String sql = "INSERT INTO stages (StageId, LanguageId, StageNumber, DurationMinutes, CeftStart, CeftEnd, "
                + "LevelStart, LevelEnd, CompletionOutcome, Descriptions, IsStatus) "
                + "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";

        try (Connection conn = DBConnection.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, stageId);
            ps.setString(2, languageId);
            setNullableInteger(ps, 3, stageNumber);
            setNullableInteger(ps, 4, durationMinutes);
            ps.setString(5, ceftStart);
            ps.setString(6, ceftEnd);
            setNullableInteger(ps, 7, levelStart);
            setNullableInteger(ps, 8, levelEnd);
            ps.setString(9, completionOutcome);
            ps.setString(10, descriptions);
            ps.setInt(11, isStatus);

            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            throw new RuntimeException("Loi khi insert stage: " + stageId, e);
        }
    }

    public boolean upsert(String stageId, String languageId, Integer stageNumber, Integer durationMinutes,
            String ceftStart, String ceftEnd, Integer levelStart, Integer levelEnd, String completionOutcome,
            String descriptions, int isStatus) {
        String sql = "INSERT INTO stages (StageId, LanguageId, StageNumber, DurationMinutes, CeftStart, CeftEnd, "
                + "LevelStart, LevelEnd, CompletionOutcome, Descriptions, IsStatus) "
                + "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?) "
                + "ON DUPLICATE KEY UPDATE "
                + "LanguageId = VALUES(LanguageId), "
                + "StageNumber = VALUES(StageNumber), "
                + "DurationMinutes = VALUES(DurationMinutes), "
                + "CeftStart = VALUES(CeftStart), "
                + "CeftEnd = VALUES(CeftEnd), "
                + "LevelStart = VALUES(LevelStart), "
                + "LevelEnd = VALUES(LevelEnd), "
                + "CompletionOutcome = VALUES(CompletionOutcome), "
                + "Descriptions = VALUES(Descriptions), "
                + "IsStatus = VALUES(IsStatus)";

        try (Connection conn = DBConnection.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, stageId);
            ps.setString(2, languageId);
            setNullableInteger(ps, 3, stageNumber);
            setNullableInteger(ps, 4, durationMinutes);
            ps.setString(5, ceftStart);
            ps.setString(6, ceftEnd);
            setNullableInteger(ps, 7, levelStart);
            setNullableInteger(ps, 8, levelEnd);
            ps.setString(9, completionOutcome);
            ps.setString(10, descriptions);
            ps.setInt(11, isStatus);

            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            throw new RuntimeException("Loi khi upsert stage: " + stageId, e);
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
