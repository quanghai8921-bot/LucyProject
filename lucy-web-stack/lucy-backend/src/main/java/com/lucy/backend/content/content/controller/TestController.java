package com.lucy.backend.content.content.controller;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jdbc.core.JdbcTemplate;
import java.util.List;
import java.util.Map;

@RestController
public class TestController {
    @Autowired
    private JdbcTemplate jdbcTemplate;

    @GetMapping("/api/test-db")
    public List<Map<String, Object>> testDb() {
        return jdbcTemplate.queryForList("SELECT l.LanguageName, s.StageId, lv.LevelTitle, lv.LevelNumber FROM Languages l JOIN Stages s ON l.LanguageId = s.LanguageId JOIN Levels lv ON s.StageId = lv.StageId WHERE lv.LevelNumber = 23");
    }
}
