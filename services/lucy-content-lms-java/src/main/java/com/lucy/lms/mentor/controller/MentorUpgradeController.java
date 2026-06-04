package com.lucy.lms.mentor.controller;

import com.lucy.lms.mentor.dto.ApproveUpgradeRequest;
import com.lucy.lms.mentor.dto.RequestUpgradeToCreatorRequest;
import com.lucy.lms.mentor.entity.MentorUpgradeRequest;
import com.lucy.lms.mentor.service.MentorUpgradeService;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/mentor/upgrade")
public class MentorUpgradeController {

    private final MentorUpgradeService mentorUpgradeService;

    public MentorUpgradeController(MentorUpgradeService mentorUpgradeService) {
        this.mentorUpgradeService = mentorUpgradeService;
    }

    @GetMapping("/eligibility")
    public Map<String, Object> checkEligibility(@RequestParam String mentorUserId) {
        return mentorUpgradeService.checkUpgradeEligibility(mentorUserId);
    }

    @PostMapping("/request")
    public MentorUpgradeRequest requestUpgrade(@RequestBody RequestUpgradeToCreatorRequest request) {
        return mentorUpgradeService.requestUpgrade(request);
    }

    @GetMapping("/history")
    public List<MentorUpgradeRequest> getUpgradeHistory(@RequestParam String mentorUserId) {
        return mentorUpgradeService.getMentorUpgradeHistory(mentorUserId);
    }

    // === Admin Endpoints ===

    @GetMapping("/admin/pending")
    public List<MentorUpgradeRequest> getPendingRequests() {
        return mentorUpgradeService.getPendingUpgradeRequests();
    }

    @PostMapping("/admin/review")
    public MentorUpgradeRequest reviewRequest(@RequestBody ApproveUpgradeRequest request) {
        return mentorUpgradeService.reviewUpgradeRequest(request);
    }
}
