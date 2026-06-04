package com.lucy.lms.mentor.service;

import com.lucy.lms.mentor.dto.ApproveUpgradeRequest;
import com.lucy.lms.mentor.dto.RequestUpgradeToCreatorRequest;
import com.lucy.lms.mentor.entity.MentorStatistics;
import com.lucy.lms.mentor.entity.MentorUpgradeRequest;
import com.lucy.lms.mentor.repository.MentorStatisticsRepository;
import com.lucy.lms.mentor.repository.MentorUpgradeRequestRepository;
import com.lucy.lms.learner.entity.User;
import com.lucy.lms.learner.repository.UserRepository;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.*;

@Service
public class MentorUpgradeService {

    // Điều kiện để upgrade lên Creator
    private static final Integer MIN_LEARNERS = 500; // Ít nhất 500 học viên
    private static final BigDecimal MIN_RATING = BigDecimal.valueOf(4.5); // Đánh giá tối thiểu 4.5
    private static final Integer MIN_TEACHING_HOURS = 500; // Ít nhất 500 giờ dạy

    private final MentorStatisticsRepository mentorStatisticsRepository;
    private final MentorUpgradeRequestRepository upgradeRequestRepository;
    private final UserRepository userRepository;

    public MentorUpgradeService(MentorStatisticsRepository mentorStatisticsRepository,
                                MentorUpgradeRequestRepository upgradeRequestRepository,
                                UserRepository userRepository) {
        this.mentorStatisticsRepository = mentorStatisticsRepository;
        this.upgradeRequestRepository = upgradeRequestRepository;
        this.userRepository = userRepository;
    }

    /**
     * Kiểm tra xem mentor có đủ điều kiện upgrade lên Creator không.
     */
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

        Map<String, Object> requirements = new LinkedHashMap<>();
        requirements.put("minLearners", MIN_LEARNERS);
        requirements.put("currentLearners", stats.getTotalLearnersCount());
        requirements.put("learnersOk", learnersOk);

        requirements.put("minRating", MIN_RATING.doubleValue());
        requirements.put("currentRating", stats.getAverageRating().doubleValue());
        requirements.put("ratingOk", ratingOk);

        requirements.put("minTeachingHours", MIN_TEACHING_HOURS);
        requirements.put("currentTeachingHours", stats.getTotalTeachingHours());
        requirements.put("hoursOk", hoursOk);

        boolean allMet = learnersOk && ratingOk && hoursOk;

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
            if (!hoursOk) {
                missingReqs.add("Số giờ dạy chưa đủ " + MIN_TEACHING_HOURS);
            }
            result.put("missingRequirements", missingReqs);
        }

        return result;
    }

    /**
     * Mentor gửi yêu cầu upgrade lên Creator.
     */
    @Transactional
    public MentorUpgradeRequest requestUpgrade(RequestUpgradeToCreatorRequest request) {
        // Kiểm tra điều kiện
        Map<String, Object> eligibility = checkUpgradeEligibility(request.getMentorUserId());

        if (!(Boolean) eligibility.get("eligible")) {
            throw new IllegalStateException("Mentor chưa đủ điều kiện để upgrade: " +
                    String.join(", ", (List<String>) eligibility.get("missingRequirements")));
        }

        // Kiểm tra xem có request PENDING chưa được xử lý không
        Optional<MentorUpgradeRequest> existingOpt = upgradeRequestRepository
                .findByMentorUserIdAndRequestStatus(request.getMentorUserId(), "PENDING");

        if (existingOpt.isPresent()) {
            throw new IllegalStateException("Bạn đã có yêu cầu upgrade đang chờ xác nhận. Vui lòng chờ admin xử lý.");
        }

        // Tạo request upgrade mới
        MentorUpgradeRequest upgradeRequest = new MentorUpgradeRequest(
                UUID.randomUUID().toString(),
                request.getMentorUserId(),
                "PENDING",
                request.getRequestReason(),
                LocalDateTime.now()
        );

        return upgradeRequestRepository.save(upgradeRequest);
    }

    /**
     * Admin xác nhận hoặc từ chối yêu cầu upgrade.
     */
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

        // Nếu APPROVED, cập nhật user role thành CREATOR
        if ("APPROVED".equals(status)) {
            User mentor = userRepository.findById(upgradeRequest.getMentorUserId())
                    .orElseThrow(() -> new IllegalArgumentException("Không tìm thấy mentor: " + upgradeRequest.getMentorUserId()));

            // Thêm role CREATOR (nếu user model hỗ trợ multiple roles)
            // Giả sử có field role, thay đổi thành "CREATOR" hoặc "MENTOR,CREATOR"
            // mentor.setRole("CREATOR"); // hoặc mentor.addRole("CREATOR");
            // userRepository.save(mentor);

            // Gửi thông báo cho mentor về việc approved
            // (có thể dùng NotificationService ở đây)
        }

        return saved;
    }

    /**
     * Lấy danh sách yêu cầu upgrade đang chờ xử lý (cho admin).
     */
    public List<MentorUpgradeRequest> getPendingUpgradeRequests() {
        return upgradeRequestRepository.findByRequestStatus("PENDING");
    }

    /**
     * Lấy lịch sử yêu cầu upgrade của mentor.
     */
    public List<MentorUpgradeRequest> getMentorUpgradeHistory(String mentorUserId) {
        return upgradeRequestRepository.findByMentorUserId(mentorUserId);
    }

    /**
     * Cập nhật thống kê của mentor (được gọi định kỳ từ background job).
     */
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
                    LocalDateTime.now()
            );
        }

        return mentorStatisticsRepository.save(stats);
    }
}
