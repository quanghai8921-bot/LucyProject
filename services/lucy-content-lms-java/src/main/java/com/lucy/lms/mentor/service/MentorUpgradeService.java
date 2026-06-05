package com.lucy.lms.mentor.service;

import com.lucy.lms.mentor.dto.ApproveUpgradeRequest;
import com.lucy.lms.mentor.dto.RequestUpgradeToCreatorRequest;
import com.lucy.lms.mentor.entity.MentorStatistics;
import com.lucy.lms.mentor.entity.MentorUpgradeRequest;
import com.lucy.lms.mentor.repository.MentorStatisticsRepository;
import com.lucy.lms.mentor.repository.MentorUpgradeRequestRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.*;

@Service
public class MentorUpgradeService {

    private static final Integer MIN_LEARNERS = 500;
    private static final BigDecimal MIN_RATING = BigDecimal.valueOf(4.5);
    private static final Integer MIN_TEACHING_HOURS = 500;
    private static final Integer MIN_RATING_PERIOD_MONTHS = 12;

    private final MentorStatisticsRepository mentorStatisticsRepository;
    private final MentorUpgradeRequestRepository upgradeRequestRepository;

    public MentorUpgradeService(MentorStatisticsRepository mentorStatisticsRepository,
                                MentorUpgradeRequestRepository upgradeRequestRepository) {
        this.mentorStatisticsRepository = mentorStatisticsRepository;
        this.upgradeRequestRepository = upgradeRequestRepository;
    }

    public Map<String, Object> checkUpgradeEligibility(String mentorUserId) {
        Map<String, Object> result = new LinkedHashMap<>();
        Optional<MentorStatistics> statsOpt = mentorStatisticsRepository.findByMentorUserId(mentorUserId);

        if (!statsOpt.isPresent()) {
            result.put("eligible", false);
            result.put("reason", "Chưa có thống kê hiệu suất cho mentor này");
            result.put("statistics", null);
            return result;
        }

        MentorStatistics stats = statsOpt.get();
        boolean learnersOk = stats.getTotalLearnersCount() >= MIN_LEARNERS;
        boolean ratingOk = stats.getAverageRating().compareTo(MIN_RATING) >= 0;
        boolean hoursOk = stats.getTotalTeachingHours() >= MIN_TEACHING_HOURS;
        boolean ratingPeriodOk = stats.getUpdatedAt() != null &&
                stats.getUpdatedAt().isAfter(LocalDateTime.now().minusMonths(MIN_RATING_PERIOD_MONTHS));

        Map<String, Object> requirements = new LinkedHashMap<>();
        requirements.put("minLearners", MIN_LEARNERS);
        requirements.put("currentLearners", stats.getTotalLearnersCount());
        requirements.put("learnersOk", learnersOk);

        requirements.put("minRating", MIN_RATING.doubleValue());
        requirements.put("currentRating", stats.getAverageRating().doubleValue());
        requirements.put("ratingOk", ratingOk);
        requirements.put("ratingPeriodMonths", MIN_RATING_PERIOD_MONTHS);
        requirements.put("ratingPeriodOk", ratingPeriodOk);

        requirements.put("minTeachingHours", MIN_TEACHING_HOURS);
        requirements.put("currentTeachingHours", stats.getTotalTeachingHours());
        requirements.put("hoursOk", hoursOk);

        boolean allMet = learnersOk && ratingOk && hoursOk && ratingPeriodOk;
        result.put("eligible", allMet);
        result.put("requirements", requirements);
        result.put("statistics", stats);

        if (!allMet) {
            List<String> missingReqs = new ArrayList<>();
            if (!learnersOk) {
                missingReqs.add("Số học viên chưa đủ " + MIN_LEARNERS);
            }
            if (!ratingOk) {
                missingReqs.add("Đánh giá chưa đạt " + MIN_RATING);
            }
            if (!ratingPeriodOk) {
                missingReqs.add("Dữ liệu đánh giá/học tập chưa cập nhật trong vòng " + MIN_RATING_PERIOD_MONTHS + " tháng");
            }
            if (!hoursOk) {
                missingReqs.add("Số giờ dạy chưa đủ " + MIN_TEACHING_HOURS);
            }
            result.put("missingRequirements", missingReqs);
        }

        return result;
    }

    @Transactional
    public MentorUpgradeRequest requestUpgrade(RequestUpgradeToCreatorRequest request) {
        Map<String, Object> eligibility = checkUpgradeEligibility(request.getMentorUserId());
        if (!(Boolean) eligibility.get("eligible")) {
            throw new IllegalStateException("Mentor chưa đủ điều kiện để upgrade: " +
                    String.join(", ", (List<String>) eligibility.get("missingRequirements")));
        }

        Optional<MentorUpgradeRequest> existingOpt = upgradeRequestRepository
                .findByMentorUserIdAndRequestStatus(request.getMentorUserId(), "PENDING");
        if (existingOpt.isPresent()) {
            throw new IllegalStateException("Bạn đã có yêu cầu upgrade đang chờ xác nhận. Vui lòng chờ admin xử lý.");
        }

        MentorUpgradeRequest upgradeRequest = new MentorUpgradeRequest(
                UUID.randomUUID().toString(),
                request.getMentorUserId(),
                "PENDING",
                request.getRequestReason(),
                LocalDateTime.now());

        return upgradeRequestRepository.save(upgradeRequest);
    }

    @Transactional
    public MentorUpgradeRequest reviewUpgradeRequest(ApproveUpgradeRequest request) {
        MentorUpgradeRequest upgradeRequest = upgradeRequestRepository.findById(request.getRequestId())
                .orElseThrow(() -> new IllegalArgumentException("Không tìm thấy yêu cầu upgrade: " + request.getRequestId()));

        if (!"PENDING".equals(upgradeRequest.getRequestStatus())) {
            throw new IllegalStateException("Chỉ có thể xử lý yêu cầu ở trạng thái PENDING");
        }

        String status = request.getStatus();
        if (!("APPROVED".equals(status) || "REJECTED".equals(status))) {
            throw new IllegalArgumentException("Trạng thái phải là APPROVED hoặc REJECTED");
        }

        upgradeRequest.setRequestStatus(status);
        upgradeRequest.setAdminNotes(request.getAdminNotes());
        upgradeRequest.setReviewedBy(request.getAdminUserId());
        upgradeRequest.setReviewedAt(LocalDateTime.now());

        MentorUpgradeRequest saved = upgradeRequestRepository.save(upgradeRequest);
        return saved;
    }

    public List<MentorUpgradeRequest> getPendingUpgradeRequests() {
        return upgradeRequestRepository.findByRequestStatus("PENDING");
    }

    public List<MentorUpgradeRequest> getMentorUpgradeHistory(String mentorUserId) {
        return upgradeRequestRepository.findByMentorUserId(mentorUserId);
    }

    @Transactional
    public MentorStatistics updateMentorStatistics(String mentorUserId,
                                                   Integer totalLearners,
                                                   BigDecimal averageRating,
                                                   Integer totalTeachingHours) {
        Optional<MentorStatistics> statsOpt = mentorStatisticsRepository.findByMentorUserId(mentorUserId);
        MentorStatistics stats;
        if (statsOpt.isPresent()) {
            stats = statsOpt.get();
            stats.setTotalLearnersCount(totalLearners);
            stats.setAverageRating(averageRating);
            stats.setTotalTeachingHours(totalTeachingHours);
            stats.setUpdatedAt(LocalDateTime.now());
        } else {
            stats = new MentorStatistics(
                    UUID.randomUUID().toString(),
                    mentorUserId,
                    totalLearners,
                    averageRating,
                    totalTeachingHours,
                    0,
                    LocalDateTime.now());
        }

        return mentorStatisticsRepository.save(stats);
    }
}
