# Mentor & Creator Business Analysis

## 1. Mục tiêu

Tài liệu này tổng hợp nghiệp vụ backend cho hai vai trò chính trong dịch vụ `lucy-content-lms-java`:
- **Mentor**: người hướng dẫn, tạo phòng Live gắn với Level/SubLevel của content.
- **Creator**: người sản xuất nội dung, phát Live và đóng gói Podcast/Paid Content.

Nội dung tập trung vào quy trình backend, model, endpoint và luồng nâng cấp Mentor lên Creator.

## 2. Phạm vi

Không bao gồm UI Flutter.
Tài liệu chỉ mô tả nghiệp vụ backend đã implement trong:
- `com.lucy.lms.mentor`
- `com.lucy.lms.creator`

## 3. Mentor

### 3.1. Khái niệm

Mentor là người tạo phòng Live theo giai đoạn học tập đã xác định bởi:
- `languageId`
- `levelId`

Mentor phòng học được quản lý bởi entity `Room` trong package `mentor.entity`.

### 3.2. Tạo phòng Mentor

Endpoint: `POST /api/mentor/rooms`

Input chính:
- `hostUserId`
- `languageId`
- `levelId`
- `roomTitle`
- `scheduledStartAt` (có thể null để bắt đầu ngay)
- `maxParticipants`

Quy tắc:
- Nếu `scheduledStartAt` null hoặc sớm hơn +1 phút, phòng được đánh dấu `ACTIVE` và đặt `studyStartedAt` ngay.
- Nếu phòng lên lịch, trạng thái `SCHEDULED`.
- Phòng Mentor chỉ được tạo khi `languageId` và `levelId` hợp lệ và trùng stage.
- Mọi người dùng được gửi notification hệ thống khi phòng được tạo hoặc lên lịch.

### 3.3. Quản lý phòng Mentor

Các thao tác chính:
- `POST /api/mentor/rooms/{roomId}/start`: chuyển phòng từ `SCHEDULED` sang `ACTIVE`, cập nhật `studyStartedAt`.
- `POST /api/mentor/rooms/{roomId}/end`: đặt phòng `ENDED` và ghi `endedAt`.
- `GET /api/mentor/rooms`: lấy tất cả phòng.
- `GET /api/mentor/rooms/mentor/{hostUserId}`: lấy phòng theo mentor.

### 3.4. Lookup Level/SubLevel

Endpoint: `GET /api/mentor/rooms/level-details?languageId=...&levelNumber=...`

Chức năng:
- Tìm `LearningLevel` theo `languageId` và `levelNumber`.
- Trả về metadata Level và danh sách SubLevel.
- SubLevel bao gồm: `subLevelId`, `subLevelNumber`, `sublevelTitle`, `mainTask`, `promptHint`, `subDurationMins`.

### 3.5. Gửi notification

Backend hiện gửi notification đến tất cả người dùng khi phòng Mentor hoặc Creator được tạo/bắt đầu.
Notification lưu vào bảng tương ứng với `Notification` entity.

## 4. Creator

### 4.1. Khái niệm

Creator là content creator, có thể mở phòng Live chức năng riêng và publish nội dung trả phí.
Creator vẫn giữ lại một số tính năng Mentor khi cần level lookup hoặc quản lý phòng.

### 4.2. Tạo phòng Creator

Endpoint: `POST /api/creator/rooms`

Input chính:
- `hostUserId`
- `roomTitle`
- `scheduledStartAt`
- `accessType` (FREE/PAY)
- `priceAmount`
- `recordOption` (có thể tạo ghi âm tự động)
- `maxParticipants`

Quy tắc:
- Không yêu cầu `levelId` / `languageId` như Mentor.
- Trạng thái `ACTIVE` nếu bắt đầu ngay, `SCHEDULED` nếu lên lịch.
- Nếu `recordOption=true`, tạo bản ghi `LiveRecording` với trạng thái `PROCESSING`.
- Gửi notification chung khi phòng Live Creator xuất hiện.

### 4.3. Quản lý phòng Creator

Các thao tác chính:
- `POST /api/creator/rooms/{roomId}/start`: bắt đầu phòng Creator đã lên lịch.
- `POST /api/creator/rooms/{roomId}/end?convertToPodcast=true`: kết thúc phòng, mark `ENDED`, hoàn thành recording và tùy chọn tạo nội dung Podcast nháp.

Khi kết thúc:
- `LiveRecording` cập nhật `completedAt`, `durationMinutes`, `recordingStatus`, và `audioUrl`.
- Nếu `convertToPodcast=true`, tạo `PaidContent` dạng `PODCAST` với `status=DRAFT`.

### 4.4. Paid Content / Podcast

Endpoints chính:
- `POST /api/creator/rooms/contents`: tạo PaidContent mới.
- `GET /api/creator/rooms/contents?creatorId=...`: lấy nội dung Creator.
- `GET /api/creator/rooms/podcasts?creatorId=...`: lấy podcast Creator.
- `POST /api/creator/rooms/podcasts/{contentId}/publish?price=...`: publish podcast.

PaidContent gồm:
- `creatorUserId`
- `roomId`
- `recordingId`
- `contentType` (ví dụ `PODCAST`)
- `title`, `descriptionText`, `thumbnailUrl`, `audioUrl`
- `priceAmount`
- `contentStatus`
- `publishedAt`

### 4.5. Tái sử dụng Mentor features

Creator có thể dùng lại:
- `GET /api/creator/rooms/level-details` để tra cứu Level/SubLevel.
- `GET /api/creator/rooms/my-rooms?creatorId=...` để lấy phòng do creator tạo.
- `GET /api/creator/rooms/{roomId}` để xem chi tiết phòng.

## 5. Mentor -> Creator upgrade

### 5.1. Mục tiêu

Cho phép Mentor đủ điều kiện chuyển sang vai trò Creator mà vẫn giữ quyền truy cập một số tính năng Mentor.

### 5.2. Tiêu chí eligibility

Các điều kiện backend hiện tại:
- `totalLearnersCount >= 500`
- `averageRating >= 4.5`
- `totalTeachingHours >= 500`

### 5.3. Quy trình

1. Mentor gọi `requestUpgrade`:
   - Kiểm tra điều kiện qua `MentorStatistics`.
   - Nếu chưa đủ, trả về lý do và không tạo request.
   - Nếu đủ, tạo `MentorUpgradeRequest` với trạng thái `PENDING`.
2. Admin xử lý request:
   - `reviewUpgradeRequest` kiểm tra request `PENDING`.
   - Nếu approve, set `APPROVED`; nếu reject, set `REJECTED`.
   - Khi approve, backend mock-up chỗ cập nhật role user lên `CREATOR`.
3. Lấy danh sách request:
   - `getPendingUpgradeRequests()` cho admin.
   - `getMentorUpgradeHistory(mentorUserId)` cho mentor.

### 5.4. Dữ liệu liên quan

- `MentorStatistics`: lưu tổng học viên, rating, giờ dạy và thời điểm cập nhật.
- `MentorUpgradeRequest`: ghi trạng thái, lý do, admin review, timestamp.

## 6. Kiến trúc và ranh giới nghiệp vụ

### 6.1. Mentor và Creator cách ly

- Mentor tập trung vào phòng học dựa trên Level/SubLevel và quản lý phòng Mentor.
- Creator tập trung vào phòng Live tự do, ghi âm, chuyển thành podcast và nội dung trả phí.

### 6.2. Nơi dùng chung

- `Room` entity dùng cho cả Mentor và Creator.
- `Notification` dùng chung để gửi thông báo cho người dùng.
- `RoomService` Mentor được tái sử dụng trong `CreatorRoomService` để giữ tính năng tra cứu Level/SubLevel.

### 6.3. Những gì đã loại bỏ

- Quy trình tracking session thời gian học/điểm danh cho Mentor đã được xóa.
- Không còn `RoomSession` / `RoomSessionService` / `RoomSessionController` / `RoomSessionRepository`.
- Điều này có nghĩa backend hiện tại chỉ quản lý phòng và nội dung, không quản lý thời gian học cụ thể cho từng phiên.

## 7. Kiểm tra và chạy backend

Để kiểm tra dịch vụ trong thư mục `services/lucy-content-lms-java`:

```bash
cd /d "D:\lucy project\LucyProject\services\lucy-content-lms-java"
mvn test
```

Nếu chạy từ thư mục khác:

```bash
mvn -f "D:\lucy project\LucyProject\services\lucy-content-lms-java\pom.xml" test
```

## 8. Kết luận

Hiện tại backend đã triển khai:
- Mentor: tạo/phát/đóng phòng live dựa trên Level
- Creator: tạo/phát/đóng phòng Live Creator, ghi âm, tạo podcast/paid content
- Mentor upgrade: kiểm tra điều kiện, tạo request, admin review
- Cả hai vai trò đều có endpoint riêng nhưng có thể dùng chung model `Room` và notification workflow

Tài liệu này phản ánh đúng trạng thái code đang có trong repository.
