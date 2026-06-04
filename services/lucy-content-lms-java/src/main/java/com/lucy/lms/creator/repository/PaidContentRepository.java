package com.lucy.lms.creator.repository;

import com.lucy.lms.creator.entity.PaidContent;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;

public interface PaidContentRepository extends JpaRepository<PaidContent, String> {
    List<PaidContent> findByCreatorUserId(String creatorUserId);
    List<PaidContent> findByCreatorUserIdAndContentType(String creatorUserId, String contentType);
}
