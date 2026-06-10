package com.lucy.lms;

import static org.assertj.core.api.Assertions.assertThat;

import java.sql.Connection;

import javax.sql.DataSource;

import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.condition.EnabledIfSystemProperty;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.TestPropertySource;

@SpringBootTest
@TestPropertySource(
        locations = "file:src/main/resources/application.properties",
        properties = "lucy.import-docx.auto-run=false")
@EnabledIfSystemProperty(named = "lucy.db.test.enabled", matches = "true")
class DatabaseConnectionTest {

    @Autowired
    private DataSource dataSource;

    @Test
    void connectsToConfiguredDatabase() throws Exception {
        try (Connection connection = dataSource.getConnection()) {
            assertThat(connection.isValid(2)).isTrue();
            assertThat(connection.getCatalog()).isEqualToIgnoringCase("lucyProject");
            System.out.println("DB CONNECTION SUCCESS: catalog=" + connection.getCatalog());
        } catch (Exception e) {
            System.err.println("DB CONNECTION FAILED: " + e.getMessage());
            throw e;
        }
    }
}
