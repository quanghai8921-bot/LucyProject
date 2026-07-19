package com.lucy.backend.content.content.controller;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jdbc.core.JdbcTemplate;
import java.util.List;
import java.util.Map;

@RestController
public class DebugContentController {

    @Autowired
    private JdbcTemplate jdbcTemplate;

    @GetMapping("/test/db-levels")
    public List<Map<String, Object>> getTestLevelDetails() {
        return jdbcTemplate.queryForList("SELECT * FROM Levels LIMIT 5");
    }
}
