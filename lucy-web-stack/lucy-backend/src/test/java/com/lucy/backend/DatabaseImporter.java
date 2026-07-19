package com.lucy.backend;
import java.io.File;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.Statement;
import java.sql.Types;
import java.util.HashMap;
import java.util.Map;
import java.util.UUID;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;

public class DatabaseImporter {

    // Thay đổi thông tin kết nối database cho phù hợp với môi trường của bạn
    private static final String DB_URL = "jdbc:mysql://localhost:3306/lucyProject?useUnicode=true&characterEncoding=utf-8";
    private static final String USER = "root";
    private static final String PASS = "123456789"; // Mật khẩu của bạn

    // Lưu trữ ánh xạ giữa ID cũ (trong JSON) và UUID mới
    private static final Map<String, String> idMap = new HashMap<>();

    private static String getOrGenerateUuid(String fileName, String oldId) {
        if (oldId == null || oldId.trim().isEmpty())
            return null;
        return idMap.computeIfAbsent(fileName + "_" + oldId, k -> UUID.randomUUID().toString());
    }

    public static void main(String[] args) {
        String[] files = { "Chinese.json", "Eng.json", "Janpanese.json" };
        ObjectMapper mapper = new ObjectMapper();

        // Lấy thư mục hiện tại (thư mục database)
        String currentDir = "D:\\LucyProject\\database";

        try (Connection conn = DriverManager.getConnection(DB_URL, USER, PASS)) {
            // Delete old data
            System.out.println("Xóa dữ liệu cũ...");
            try (Statement stmt = conn.createStatement()) {
                stmt.execute("SET FOREIGN_KEY_CHECKS = 0;");
                stmt.execute("DELETE FROM QuestionContent;");
                stmt.execute("DELETE FROM Questions;");
                stmt.execute("DELETE FROM SubLevel;");
                stmt.execute("DELETE FROM Levels;");
                stmt.execute("DELETE FROM LevelGroups;");
                stmt.execute("DELETE FROM Stages;");
                stmt.execute("DELETE FROM Languages;");
                stmt.execute("SET FOREIGN_KEY_CHECKS = 1;");
            }
            System.out.println("Xóa dữ liệu cũ thành công!");

            conn.setAutoCommit(false); // Dùng transaction để đảm bảo dữ liệu

            for (String fileName : files) {
                File file = new File(currentDir, fileName);
                if (!file.exists()) {
                    System.out.println("Không tìm thấy file: " + file.getAbsolutePath());
                    continue;
                }

                System.out.println("Đang xử lý " + fileName + "...");
                JsonNode root = mapper.readTree(file);

                // 1. Bảng Languages
                if (root.has("Languages")) {
                    String sql = "INSERT IGNORE INTO Languages (LanguageId, LanguageName) VALUES (?, ?)";
                    try (PreparedStatement pstmt = conn.prepareStatement(sql)) {
                        for (JsonNode node : root.get("Languages")) {
                            String newId = getOrGenerateUuid(fileName, node.path("LanguageId").asText(null));
                            pstmt.setString(1, newId);
                            pstmt.setString(2, node.path("LanguageName").asText(null));
                            pstmt.addBatch();
                        }
                        pstmt.executeBatch();
                    }
                }

                // 2. Bảng Stages
                if (root.has("Stages")) {
                    String sql = "INSERT IGNORE INTO Stages (StageId, LanguageId, StageNumber, DurationMinutes, CefrStart, CefrEnd, LevelStart, LevelEnd, SubDurationMinutes, SubNumber, CompletionOutcome, Descriptions) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
                    try (PreparedStatement pstmt = conn.prepareStatement(sql)) {
                        for (JsonNode node : root.get("Stages")) {
                            String newStageId = getOrGenerateUuid(fileName, node.path("StageId").asText(null));
                            String newLangId = getOrGenerateUuid(fileName, node.path("LanguageId").asText(null));

                            pstmt.setString(1, newStageId);
                            pstmt.setString(2, newLangId);
                            pstmt.setObject(3,
                                    node.path("StageNumber").isNull() ? null : node.path("StageNumber").asInt(),
                                    Types.INTEGER);
                            pstmt.setObject(4,
                                    node.path("DurationMinutes").isNull() ? null : node.path("DurationMinutes").asInt(),
                                    Types.INTEGER);
                            pstmt.setString(5,
                                    node.path("CefrStart").isNull() ? null : node.path("CefrStart").asText());
                            pstmt.setString(6, node.path("CefrEnd").isNull() ? null : node.path("CefrEnd").asText());
                            pstmt.setObject(7,
                                    node.path("LevelStart").isNull() ? null : node.path("LevelStart").asInt(),
                                    Types.INTEGER);
                            pstmt.setObject(8, node.path("LevelEnd").isNull() ? null : node.path("LevelEnd").asInt(),
                                    Types.INTEGER);
                            pstmt.setObject(9, node.path("SubDurationMinutes").isNull() ? null
                                    : node.path("SubDurationMinutes").asInt(), Types.INTEGER);
                            pstmt.setObject(10, node.path("SubNumber").isNull() ? null : node.path("SubNumber").asInt(),
                                    Types.INTEGER);
                            pstmt.setString(11, node.path("CompletionOutcome").isNull() ? null
                                    : node.path("CompletionOutcome").asText());
                            pstmt.setString(12,
                                    node.path("Descriptions").isNull() ? null : node.path("Descriptions").asText());
                            pstmt.addBatch();
                        }
                        pstmt.executeBatch();
                    }
                }

                // 3. Bảng LevelGroups
                if (root.has("LevelGroups")) {
                    String sql = "INSERT IGNORE INTO LevelGroups (GroupId, StageId, GroupTitle, GrCefrLevel) VALUES (?, ?, ?, ?)";
                    try (PreparedStatement pstmt = conn.prepareStatement(sql)) {
                        for (JsonNode node : root.get("LevelGroups")) {
                            String newGroupId = getOrGenerateUuid(fileName, node.path("GroupId").asText(null));
                            String newStageId = getOrGenerateUuid(fileName, node.path("StageId").asText(null));

                            pstmt.setString(1, newGroupId);
                            pstmt.setString(2, newStageId);
                            pstmt.setString(3,
                                    node.path("GroupTitle").isNull() ? null : node.path("GroupTitle").asText());
                            pstmt.setString(4,
                                    node.path("GrCefrLevel").isNull() ? null : node.path("GrCefrLevel").asText());
                            pstmt.addBatch();
                        }
                        pstmt.executeBatch();
                    }
                }

                // 4. Bảng Levels
                if (root.has("Levels")) {
                    String sql = "INSERT IGNORE INTO Levels (LevelId, GroupId, StageId, LevelTitle, LevelNumber) VALUES (?, ?, ?, ?, ?)";
                    try (PreparedStatement pstmt = conn.prepareStatement(sql)) {
                        for (JsonNode node : root.get("Levels")) {
                            String newLevelId = getOrGenerateUuid(fileName, node.path("LevelId").asText(null));
                            String newGroupId = getOrGenerateUuid(fileName, node.path("GroupId").asText(null));
                            String newStageId = getOrGenerateUuid(fileName, node.path("StageId").asText(null));

                            pstmt.setString(1, newLevelId);
                            pstmt.setString(2, newGroupId);
                            pstmt.setString(3, newStageId);
                            pstmt.setString(4,
                                    node.path("LevelTitle").isNull() ? null : node.path("LevelTitle").asText());
                            pstmt.setObject(5,
                                    node.path("LevelNumber").isNull() ? null : node.path("LevelNumber").asInt(),
                                    Types.INTEGER);
                            pstmt.addBatch();
                        }
                        pstmt.executeBatch();
                    }
                }

                // 5. Bảng SubLevel
                if (root.has("SubLevel")) {
                    String sql = "INSERT IGNORE INTO SubLevel (SubLevelId, LevelId, SubLevelNumber, SublevelTitle, MainTask) VALUES (?, ?, ?, ?, ?)";
                    try (PreparedStatement pstmt = conn.prepareStatement(sql)) {
                        for (JsonNode node : root.get("SubLevel")) {
                            String newSubLevelId = getOrGenerateUuid(fileName, node.path("SubLevelId").asText(null));
                            String newLevelId = getOrGenerateUuid(fileName, node.path("LevelId").asText(null));

                            pstmt.setString(1, newSubLevelId);
                            pstmt.setString(2, newLevelId);
                            pstmt.setObject(3,
                                    node.path("SubLevelNumber").isNull() ? null : node.path("SubLevelNumber").asInt(),
                                    Types.INTEGER);
                            pstmt.setString(4,
                                    node.path("SublevelTitle").isNull() ? null : node.path("SublevelTitle").asText());
                            pstmt.setString(5, node.path("MainTask").isNull() ? null : node.path("MainTask").asText());
                            pstmt.addBatch();
                        }
                        pstmt.executeBatch();
                    }
                }
                
                // 6. Bảng Questions
                if (root.has("Questions")) {
                    String sql = "INSERT IGNORE INTO Questions (QuestionId, SubLevelId, QuestionNumber, QuestionType, MaxScore) VALUES (?, ?, ?, ?, ?)";
                    try (PreparedStatement pstmt = conn.prepareStatement(sql)) {
                        for (JsonNode node : root.get("Questions")) {
                            String newQuestionId = getOrGenerateUuid(fileName, node.path("QuestionId").asText(null));
                            String newSubLevelId = getOrGenerateUuid(fileName, node.path("SubLevelId").asText(null));

                            pstmt.setString(1, newQuestionId);
                            pstmt.setString(2, newSubLevelId);
                            pstmt.setObject(3,
                                    node.path("QuestionNumber").isNull() ? null : node.path("QuestionNumber").asInt(),
                                    Types.INTEGER);
                            pstmt.setString(4, node.path("QuestionType").isNull() ? null : node.path("QuestionType").asText());
                            pstmt.setObject(5, node.path("MaxScore").isNull() ? null : node.path("MaxScore").asInt(), Types.INTEGER);
                            pstmt.addBatch();
                        }
                        pstmt.executeBatch();
                    }
                }
                
                // 7. Bảng QuestionContent
                if (root.has("QuestionContent")) {
                    String sql = "INSERT IGNORE INTO QuestionContent (ContentId, QuestionId, LanguageId, QuestionText, Hint) VALUES (?, ?, ?, ?, ?)";
                    try (PreparedStatement pstmt = conn.prepareStatement(sql)) {
                        for (JsonNode node : root.get("QuestionContent")) {
                            String newContentId = getOrGenerateUuid(fileName, node.path("ContentId").asText(null));
                            String newQuestionId = getOrGenerateUuid(fileName, node.path("QuestionId").asText(null));
                            String newLangId = getOrGenerateUuid(fileName, node.path("LanguageId").asText(null));

                            pstmt.setString(1, newContentId);
                            pstmt.setString(2, newQuestionId);
                            pstmt.setString(3, newLangId);
                            pstmt.setString(4, node.path("QuestionText").isNull() ? null : node.path("QuestionText").asText());
                            pstmt.setString(5, node.path("Hint").isNull() ? null : node.path("Hint").asText());
                            pstmt.addBatch();
                        }
                        pstmt.executeBatch();
                    }
                }
            }

            conn.commit();
            System.out.println("Import dữ liệu (sử dụng UUID) thành công!");
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}

