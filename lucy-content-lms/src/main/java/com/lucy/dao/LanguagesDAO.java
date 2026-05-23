package com.lucy.dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

import com.lucy.models.Languages;
import com.lucy.utils.DBConnection;

public class LanguagesDAO {
    public boolean testConnection() {
        try (Connection conn = DBConnection.getConnection()) {
            return conn != null && !conn.isClosed();
        } catch (Exception e) {
            throw new RuntimeException("Loi khi ket noi database", e);
        }
    }

    public boolean existsByName(String languageName) {
        String sql = "SELECT 1 FROM languages WHERE LOWER(LanguageName) = LOWER(?) LIMIT 1";

        try (Connection conn = DBConnection.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, languageName);

            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        } catch (Exception e) {
            throw new RuntimeException("Loi khi kiem tra language: " + languageName, e);
        }
    }

    public String findLanguageIdByName(String languageName) {
        String sql = "SELECT LanguageId FROM languages WHERE LOWER(LanguageName) = LOWER(?) LIMIT 1";

        try (Connection conn = DBConnection.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, languageName);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getString("LanguageId");
                }
            }

            return null;
        } catch (Exception e) {
            throw new RuntimeException("Loi khi lay LanguageId theo LanguageName: " + languageName, e);
        }
    }

    public boolean insert(Languages language) {
        String sql = "INSERT INTO languages (LanguageId, LanguageName) VALUES (?, ?)";

        try (Connection conn = DBConnection.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, language.getLanguageId());
            ps.setString(2, language.getLanguageName());
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            throw new RuntimeException("Loi khi insert language: " + language.getLanguageName(), e);
        }
    }

    public boolean upsert(Languages language) {
        String sql = "INSERT INTO languages (LanguageId, LanguageName) VALUES (?, ?) "
                + "ON DUPLICATE KEY UPDATE LanguageName = VALUES(LanguageName)";

        try (Connection conn = DBConnection.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, language.getLanguageId());
            ps.setString(2, language.getLanguageName());
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            throw new RuntimeException("Loi khi upsert language: " + language.getLanguageName(), e);
        }
    }
}
