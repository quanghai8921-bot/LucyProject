package com.lucy.backend.realtime.config;

import lombok.Data;
import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.context.annotation.Configuration;

@Data
@Configuration
@ConfigurationProperties(prefix = "agora.app")
public class AgoraProperties {
    private String id;
    private String certificate;
    private int tokenExpiresIn = 3600; // default to 1 hour if not specified
}
