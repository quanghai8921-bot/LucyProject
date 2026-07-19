package com.lucy.backend.content.creator.repository;

import com.lucy.backend.content.creator.entity.PaidContent;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface PaidContentRepository extends JpaRepository<PaidContent, String> {
    List<PaidContent> findByCreatorUserIdOrderByPublishedAtDesc(String creatorUserId);

    List<PaidContent> findByContentTypeAndContentStatusOrderByPublishedAtDesc(String contentType, String contentStatus);
}
