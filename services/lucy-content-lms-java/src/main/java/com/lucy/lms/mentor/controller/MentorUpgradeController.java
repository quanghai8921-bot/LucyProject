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

    @GetMapping("/{mentorUserId}")
    public Map<String, Object> checkEligibility(@PathVariable String mentorUserId) {
        return mentorUpgradeService.checkUpgradeEligibility(mentorUserId);
    }

    @PostMapping("/request")
    public MentorUpgradeRequest requestUpgrade(@RequestBody RequestUpgradeToCreatorRequest request) {
        return mentorUpgradeService.requestUpgrade(request);
    }

    @PostMapping("/review")
    public MentorUpgradeRequest reviewUpgrade(@RequestBody ApproveUpgradeRequest request) {
        return mentorUpgradeService.reviewUpgradeRequest(request);
    }

    @GetMapping("/pending")
    public List<MentorUpgradeRequest> getPendingRequests() {
        return mentorUpgradeService.getPendingUpgradeRequests();
    }

    @GetMapping("/history/{mentorUserId}")
    public List<MentorUpgradeRequest> getHistory(@PathVariable String mentorUserId) {
        return mentorUpgradeService.getMentorUpgradeHistory(mentorUserId);
    }
}
