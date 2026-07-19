package com.lucy.backend.content.content.controller;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jdbc.core.JdbcTemplate;
import java.util.List;
import java.util.Map;

@RestController
public class DebugController {

    @Autowired
    private JdbcTemplate jdbcTemplate;

    @GetMapping("/api/auth/debug/db")
    public String debugDb() {
        StringBuilder sb = new StringBuilder();
        try {
            sb.append("=== Languages ===\n");
            jdbcTemplate.queryForList("SELECT * FROM Languages").forEach(row -> sb.append(row).append("\n"));
            sb.append("=== Stages ===\n");
            jdbcTemplate.queryForList("SELECT * FROM Stages").forEach(row -> sb.append(row).append("\n"));
            sb.append("=== Levels ===\n");
            jdbcTemplate.queryForList("SELECT * FROM Levels").forEach(row -> sb.append(row).append("\n"));
            sb.append("=== SubLevel ===\n");
            jdbcTemplate.queryForList("SELECT * FROM SubLevel").forEach(row -> sb.append(row).append("\n"));
        } catch (Exception e) {
            sb.append("Error: ").append(e.getMessage());
        }
        return sb.toString();
    }
}
