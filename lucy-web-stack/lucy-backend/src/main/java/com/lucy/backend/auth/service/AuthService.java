package com.lucy.backend.auth.service;

import com.lucy.backend.auth.dto.AuthResponse;
import com.lucy.backend.auth.dto.LoginRequest;
import com.lucy.backend.auth.dto.RegisterRequest;
import com.lucy.backend.auth.entity.User;
import com.lucy.backend.auth.entity.UserRole;
import com.lucy.backend.auth.repository.UserRepository;
import com.lucy.backend.auth.repository.UserRoleRepository;
import com.lucy.backend.auth.security.JwtUtil;
import com.lucy.backend.auth.entity.MentorApplication;
import com.lucy.backend.auth.entity.ContentCreatorApplication;
import com.lucy.backend.auth.repository.MentorApplicationRepository;
import com.lucy.backend.auth.repository.ContentCreatorApplicationRepository;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.mail.SimpleMailMessage;
import org.springframework.mail.javamail.JavaMailSender;
import java.time.format.DateTimeFormatter;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;
import java.util.UUID;
import java.util.stream.Collectors;

@Service
public class AuthService {
    private final UserRepository userRepository;
    private final UserRoleRepository userRoleRepository;
    private final PasswordEncoder passwordEncoder;
    private final JwtUtil jwtUtil;
    private final MentorApplicationRepository mentorAppRepo;
    private final ContentCreatorApplicationRepository creatorAppRepo;
    // 🌟 1. Inject thêm JavaMailSender để gửi Email thực tế
    private final JavaMailSender mailSender;

    // 🌟 2. Tạo một Class nội bộ (Inner Class) để đóng gói Key và thời gian hết hạn
    private static class ResetToken {
        private final String key;
        private final LocalDateTime expiryTime;

        public ResetToken(String key, LocalDateTime expiryTime) {
            this.key = key;
            this.expiryTime = expiryTime;
        }

        public String getKey() {
            return key;
        }

        public boolean isExpired() {
            return LocalDateTime.now().isAfter(expiryTime);
        }
    }

    // 🌟 3. Đổi cấu trúc Map để lưu trữ đối tượng ResetToken có thời gian hạn định
    // 5 phút
    private final java.util.Map<String, ResetToken> resetPasswordKeys = new java.util.concurrent.ConcurrentHashMap<>();

    public AuthService(UserRepository userRepository, UserRoleRepository userRoleRepository,
            PasswordEncoder passwordEncoder, JwtUtil jwtUtil,
            MentorApplicationRepository mentorAppRepo, ContentCreatorApplicationRepository creatorAppRepo,
            JavaMailSender mailSender) {
        this.userRepository = userRepository;
        this.userRoleRepository = userRoleRepository;
        this.passwordEncoder = passwordEncoder;
        this.jwtUtil = jwtUtil;
        this.mentorAppRepo = mentorAppRepo;
        this.creatorAppRepo = creatorAppRepo;
        this.mailSender = mailSender; // Gán đối tượng gửi mail
    }

    // 🌟 5. Cập nhật BƯỚC 1: Sinh mã, giới hạn 5 phút và gửi Email thực tế về hòm
    // thư người dùng
    public void requestForgotPasswordKey(String email) {
        User user = userRepository.findByEmail(email)
                .orElseThrow(() -> new RuntimeException("Địa chỉ Email không tồn tại trên hệ thống."));

        String generatedKey = String.valueOf((int) ((Math.random() * 900000) + 100000));

        // Thiết lập thời gian hết hạn: Thời gian hiện tại + 5 phút
        LocalDateTime expiryTime = LocalDateTime.now().plusMinutes(5);
        resetPasswordKeys.put(email, new ResetToken(generatedKey, expiryTime));

        // Tiến hành gửi Email bằng STMP Gmail đã cấu hình
        try {
            SimpleMailMessage message = new SimpleMailMessage();
            message.setFrom("quanghai8921@gmail.com"); // Email gửi đi
            message.setTo(email); // Email nhận
            message.setSubject("[LUCY] Mã xác nhận khôi phục mật khẩu");
            message.setText("Xin chào " + user.getFullName() + ",\n\n"
                    + "Mã xác nhận (Key) phục hồi mật khẩu hệ thống LUCY của bạn là: " + generatedKey + "\n\n"
                    + "⚠️ Lưu ý: Mã số này chỉ có hiệu lực trong vòng 5 phút (Hết hạn lúc: "
                    + expiryTime.format(DateTimeFormatter.ofPattern("HH:mm:ss")) + ").\n\n"
                    + "Nếu bạn không thực hiện yêu cầu này, vui lòng bỏ qua email bảo mật này.");

            mailSender.send(message);
            System.out.println("-> Đã gửi thành công mã khôi phục " + generatedKey + " tới email " + email);
        } catch (Exception e) {
            throw new RuntimeException("Lỗi kết nối dịch vụ SMTP Gmail: " + e.getMessage());
        }
    }

    // 🌟 6. Cập nhật BƯỚC 2: Kiểm tra chính xác mã và chặn đứng nếu quá thời hạn 5
    // phút
    public void verifyForgotPasswordKey(String email, String key) {
        ResetToken tokenWrapper = resetPasswordKeys.get(email);

        if (tokenWrapper == null || !tokenWrapper.getKey().equals(key)) {
            throw new RuntimeException("Mã xác nhận (Key) không chính xác.");
        }

        // Kiểm tra xem thời gian hiện tại đã vượt quá 5 phút chưa
        if (tokenWrapper.isExpired()) {
            resetPasswordKeys.remove(email); // Dọn dẹp mã đã hết hạn ra khỏi bộ nhớ
            throw new RuntimeException(
                    "Mã xác nhận của bạn đã hết hạn hiệu lực (Quá hạn 5 phút). Vui lòng bấm gửi lại mã mới.");
        }
    }

    // 🌟 7. Cập nhật BƯỚC 3: Lưu mật khẩu mới và xóa Token bảo mật
    public void resetPassword(String email, String key, String newPassword) {
        // Tái thẩm định mã xác nhận và thời gian hết hạn
        verifyForgotPasswordKey(email, key);

        User user = userRepository.findByEmail(email)
                .orElseThrow(() -> new RuntimeException("Người dùng không tồn tại."));

        // Tiến hành băm mật khẩu mới bằng Bcrypt và lưu trữ
        user.setPasswords(passwordEncoder.encode(newPassword));
        userRepository.save(user);

        // Khôi phục hoàn tất, xóa token khẩn cấp khỏi Map để đảm bảo an toàn tuyệt đối
        resetPasswordKeys.remove(email);
    }

    public AuthResponse login(LoginRequest request) {
        User user = userRepository.findByEmail(request.getEmail())
                .orElseThrow(() -> new RuntimeException("Email không tồn tại"));

        boolean isMatch = passwordEncoder.matches(request.getPassword(), user.getPasswords());
        if (!isMatch && !request.getPassword().equals(user.getPasswords())) {
            throw new RuntimeException("Mật khẩu không đúng");
        }

        List<String> roles = userRoleRepository.findByUserId(user.getUserId())
                .stream().map(UserRole::getRoleId).collect(Collectors.toList());

        if (roles.contains("R003")) {
            Optional<MentorApplication> appOpt = mentorAppRepo.findByUserId(user.getUserId());
            if (appOpt.isPresent()) {
                String status = appOpt.get().getStatus();
                if ("PENDING".equals(status)) {
                    throw new RuntimeException("Tài khoản Mentor đang chờ Admin duyệt.");
                } else if ("REJECTED".equals(status)) {
                    throw new RuntimeException("Đơn đăng ký Mentor đã bị từ chối: " + appOpt.get().getRejectReason());
                }
            }
        }

        if (roles.contains("R004")) {
            Optional<ContentCreatorApplication> appOpt = creatorAppRepo.findByUserId(user.getUserId());
            if (appOpt.isPresent()) {
                String status = appOpt.get().getStatus();
                if ("PENDING".equals(status)) {
                    throw new RuntimeException("Tài khoản Creator đang chờ Admin duyệt.");
                } else if ("REJECTED".equals(status)) {
                    throw new RuntimeException("Đơn đăng ký Creator đã bị từ chối: " + appOpt.get().getRejectReason());
                }
            }
        }

        String token = jwtUtil.generateToken(user.getUserId(), user.getEmail(), roles);

        return new AuthResponse(token, user.getEmail(), user.getFullName(), user.getUserId(), roles);
    }

    public AuthResponse register(RegisterRequest request) {
        if (userRepository.existsByEmail(request.getEmail())) {
            throw new RuntimeException("Email đã tồn tại");
        }

        User user = new User();
        user.setUserId("U" + UUID.randomUUID().toString().substring(0, 8));
        user.setFullName(request.getFullName());
        user.setEmail(request.getEmail());
        user.setPasswords(passwordEncoder.encode(request.getPassword()));
        userRepository.save(user);

        UserRole role = new UserRole();
        role.setUserId(user.getUserId());
        role.setRoleId(request.getRole() != null ? request.getRole() : "R002"); // default role learner = 1
        userRoleRepository.save(role);

        List<String> roles = List.of(role.getRoleId());

        if ("R003".equals(role.getRoleId())) {
            MentorApplication app = new MentorApplication();
            app.setApplicationId(UUID.randomUUID().toString());
            app.setUserId(user.getUserId());
            app.setStatus("PENDING");
            app.setSubmittedAt(LocalDateTime.now());
            mentorAppRepo.save(app);
            return new AuthResponse(null, user.getEmail(), user.getFullName(), user.getUserId(), roles);
        }

        if ("R004".equals(role.getRoleId())) {
            ContentCreatorApplication app = new ContentCreatorApplication();
            app.setApplicationId(UUID.randomUUID().toString());
            app.setUserId(user.getUserId());
            app.setStatus("PENDING");
            app.setSubmittedAt(LocalDateTime.now());
            creatorAppRepo.save(app);
            return new AuthResponse(null, user.getEmail(), user.getFullName(), user.getUserId(), roles);
        }

        String token = jwtUtil.generateToken(user.getUserId(), user.getEmail(), roles);

        return new AuthResponse(token, user.getEmail(), user.getFullName(), user.getUserId(), roles);
    }
}
