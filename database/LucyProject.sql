Create database lucyProject
CHARACTER
SET utf8mb4
COLLATE utf8mb4_unicode_ci;

CREATE TABLE Languages
(
    LanguageId VARCHAR(50) PRIMARY KEY,
    LanguageName VARCHAR(50) NOT NULL
)
ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE Users
(
    UserId VARCHAR(50) PRIMARY KEY,
    FullName VARCHAR(50) NOT NULL,
    PhoneNumber VARCHAR(10) UNIQUE NOT NULL,
    Email VARCHAR(50) UNIQUE NOT NULL,
    Passwords VARCHAR(255) NOT NULL,
    CreatedAt DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    IsStatus INT NOT NULL
)
ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE Roles
(
    RoleId VARCHAR(50) PRIMARY KEY,
    RoleName VARCHAR(50) NOT NULL,
    IsActive TINYINT NOT NULL DEFAULT 1
)
ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
INSERT INTO Roles
    (RoleId, RoleName)
VALUES
    ('R001', 'ADMINSTRATOR'),
    ('R002', 'LUCY ANONYMOUS'),
    ('R003', 'MENTOR'),
    ('R004', 'CONTENT CREATOR');

CREATE TABLE UserRoles
(
    UserId VARCHAR(50) NOT NULL,
    RoleId VARCHAR(50) NOT NULL,
    AssignedDate DATETIME DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (UserId, RoleId),
    FOREIGN KEY (UserId) REFERENCES Users(UserId),
    FOREIGN KEY (RoleId) REFERENCES Roles(RoleId)
)
ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE AvatarPersonas
(
    UserId VARCHAR(50) PRIMARY KEY,
    DisplayName VARCHAR(50) NOT NULL,
    AvatarUrl VARCHAR(255),
    IsAnonymous INT NOT NULL DEFAULT 1,
    CreatedAt DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (UserId) REFERENCES Users(UserId)
)
ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE MentorApplications
(
    -- Đơn đăng kí mentor
    ApplicationId VARCHAR(50) PRIMARY KEY,
    UserId VARCHAR(50) NOT NULL,
    LanguageId VARCHAR(50) NULL,
    CertificateUrl VARCHAR(255) NULL,
    Status VARCHAR(30) NOT NULL DEFAULT 'PENDING',
    RejectReason VARCHAR(255) NULL,
    SubmittedAt DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (UserId) REFERENCES Users(UserId),
    FOREIGN KEY (LanguageId) REFERENCES Languages(LanguageId)
)
ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE CreatorUpgradeRequests
(
    UpgradeRequestId VARCHAR(50) PRIMARY KEY,
    UserId VARCHAR(50) NOT NULL,
    TotalTeachingMinutes INT NOT NULL DEFAULT 0,
    AverageRating DECIMAL(3,2) NULL,
    LearnerCount INT NOT NULL DEFAULT 0,
    Status VARCHAR(30) NOT NULL DEFAULT 'PENDING',
    -- PENDING, APPROVED, REJECTED
    RejectReason VARCHAR(255) NULL,
    SubmittedAt DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (UserId) REFERENCES Users(UserId)
)
ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE Stages
(
    StageId VARCHAR(50) PRIMARY KEY,
    LanguageId VARCHAR(50) NOT NULL,
    StageNumber INT NULL,
    DurationMinutes INT NULL,
    CefrStart VARCHAR(20),
    CefrEnd VARCHAR(20),
    LevelStart INT NOT NULL,
    LevelEnd INT NOT NULL,
    CompletionOutcome VARCHAR(255),
    Descriptions VARCHAR(255),
    IsStatus INT NOT NULL,
    FOREIGN KEY (LanguageId) REFERENCES Languages(LanguageId)
)
ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE StageDesignNotes
(
    NoteId VARCHAR(50) PRIMARY KEY,
    StageId VARCHAR(50) NOT NULL,
    NoteType VARCHAR(50) NOT NULL,
    NoteOrder INT NULL,
    ContentText TEXT NOT NULL,
    FOREIGN KEY (StageId) REFERENCES Stages(StageId)
)
ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE StageStepTemplates
(
    StageStepTemplateId VARCHAR(50) PRIMARY KEY,
    StageId VARCHAR(50) NOT NULL,
    TemplateType VARCHAR(50) NOT NULL,
    TemplateStepOrder INT NOT NULL,
    TemplateStepTitle VARCHAR(100) NOT NULL,
    TemplateDurationMinutes INT NULL,
    TemplateDescription VARCHAR(255) NULL,
    IsStatus INT NOT NULL DEFAULT 1,
    FOREIGN KEY (StageId) REFERENCES Stages(StageId)
)
ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE LevelGroups
(
    GroupId VARCHAR(50) PRIMARY KEY,
    StageId VARCHAR(50) NOT NULL,
    GroupTitle VARCHAR(100) NULL,
    GrCefrLevel VARCHAR(50) null,
    GrLevelStart INT,
    GrLevelEnd INT,
    FOREIGN KEY (StageId) REFERENCES Stages(StageId)
)
ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE Levels
(
    LevelId VARCHAR(50) PRIMARY KEY,
    GroupId VARCHAR(50) NULL,
    StageId VARCHAR(50) NOT NULL,
    LevelTitle VARCHAR(100) null,
    LevelNumber INT NOT NULL,
    LevelDescription text null,
    FOREIGN KEY (StageId) REFERENCES Stages(StageId),
    FOREIGN KEY (GroupId) REFERENCES LevelGroups(GroupId)
)
ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE SubLevel
(
    SubLevelId VARCHAR(50) PRIMARY KEY,
    LevelId VARCHAR(50) NOT NULL,
    SubLevelNumber INT NULL,
    SublevelTitle VARCHAR(100) NULL,
    MainTask VARCHAR(255),
    PromptHint VARCHAR(255),
    SubDurationMins INT NULL,
    FOREIGN KEY (LevelId) REFERENCES Levels(LevelId)
)
ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE Questions
(
    QuestionId VARCHAR(50) PRIMARY KEY,
    SubLevelId VARCHAR(50) NOT NULL,
    QuestionNumber INT NULL,
    QuestionType VARCHAR(50) NULL,
    CreatedAt DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (SubLevelId) REFERENCES SubLevel(SubLevelId)
)
ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE QuestionContent
(
    QuestionContentId VARCHAR(50) PRIMARY KEY,
    QuestionId VARCHAR(50) NOT NULL,
    LanguageId VARCHAR(50) NOT NULL,
    QuestionText TEXT NOT NULL,
    QueRomanization text,
    Translation text,
    GrammarNote VARCHAR(255) NULL,
    PronunciationNote VARCHAR(255) NULL,
    ExampleContext VARCHAR(255) NULL,
    FOREIGN KEY (QuestionId) REFERENCES Questions(QuestionId),
    FOREIGN KEY (LanguageId) REFERENCES Languages(LanguageId)
)
ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE SampleAnswers
(
    AnswerId VARCHAR(50) PRIMARY KEY,
    QuestionId VARCHAR(50) NOT NULL,
    LanguageId VARCHAR(50) NOT NULL,
    AnswerText TEXT NULL,
    AnsRomanization TEXT NULL,
    Translation TEXT NULL,
    AnswerOrder INT NULL,
    FOREIGN KEY (QuestionId) REFERENCES Questions(QuestionId),
    FOREIGN KEY (LanguageId) REFERENCES Languages(LanguageId)
)
ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE ImportedDocxFiles
(
    ImportedDocxFileId VARCHAR(50) PRIMARY KEY,
    FileName VARCHAR(255) NOT NULL,
    FilePath VARCHAR(255) NOT NULL,
    LanguageId VARCHAR(50) NULL,
    StageId VARCHAR(50) NULL,
    LevelStart INT NULL,
    LevelEnd INT NULL,
    ImportStatus VARCHAR(30) NOT NULL DEFAULT 'UPLOADED',
    -- UPLOADED, CHECKING, PARSING, IMPORTED, FAILED
    ErrorMessage VARCHAR(255) NULL,
    UploadedBy VARCHAR(50) NULL,
    UploadedAt DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    ParsedAt DATETIME NULL,
    FOREIGN KEY (LanguageId) REFERENCES Languages(LanguageId),
    FOREIGN KEY (StageId) REFERENCES Stages(StageId),
    FOREIGN KEY (UploadedBy) REFERENCES Users(UserId)
)
ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE INDEX idx_imported_docx_status ON ImportedDocxFiles(ImportStatus);
CREATE INDEX idx_imported_docx_language ON ImportedDocxFiles(LanguageId);

CREATE TABLE Rooms
(
    RoomId VARCHAR(50) PRIMARY KEY,
    HostUserId VARCHAR(50) NOT NULL,
    HostRole VARCHAR(30) NOT NULL,
    LevelId VARCHAR(50) NULL,
    LanguageId VARCHAR(50) NULL,
    ImportedDocxFileId VARCHAR(50) NULL,
    RoomTitle VARCHAR(100) NOT NULL,
    RoomType varchar(100) null,
    -- MENTOR_CLASS, CREATOR_LIVE
    AccessType varchar(100) null,
    -- Free, Paid
    PriceAmount decimal(18,2) null,
    -- Giá tiền nếu phòng đó thu phí
    ScheduledStartAt DATETIME NOT NULL,
    -- Thời gian lên lịch phòng sẽ mở
    StudyStartedAt DATETIME NULL,
    -- Thời gian bắt đầu bấm nút học để đo điều kiện
    EndedAt DATETIME NULL,
    RoomStatus VARCHAR(30) NOT NULL,
    -- Trạng thái phòng OPEN, STUDYING, ENDED, CANCELLED   
    MaxParticipants INT NULL,
    -- Số lượng người join phiên live
    CreatedAt DATETIME DEFAULT CURRENT_TIMESTAMP,
    -- Thời gian mentor bắt đầu tạo Live
    FOREIGN KEY (HostUserId) REFERENCES Users(UserId),
    FOREIGN KEY (LanguageId) REFERENCES Languages(LanguageId),
    FOREIGN KEY (LevelId) REFERENCES Levels(LevelId),
    FOREIGN KEY (ImportedDocxFileId) REFERENCES ImportedDocxFiles(ImportedDocxFileId)
)
ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE INDEX idx_rooms_language_level ON Rooms(LanguageId, LevelId);
CREATE INDEX idx_rooms_status ON Rooms(RoomStatus);
CREATE INDEX idx_rooms_host ON Rooms(HostUserId);

CREATE TABLE RoomSubLevels
(
    -- Để biết phòng đó mentor đang dùng các sublevel nào
    RoomSubLevelId VARCHAR(50) PRIMARY KEY,
    RoomId VARCHAR(50) NOT NULL,
    SubLevelId VARCHAR(50) NOT NULL,
    StepOrder INT NOT NULL,
    PlannedDurationMins INT NULL,
    StartedAt DATETIME NULL,
    EndedAt DATETIME NULL,
    Status VARCHAR(30) NOT NULL DEFAULT 'NOT_STARTED',
    FOREIGN KEY (RoomId) REFERENCES Rooms(RoomId),
    FOREIGN KEY (SubLevelId) REFERENCES SubLevel(SubLevelId),
    UNIQUE (RoomId, SubLevelId)
)
ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE RoomParticipants
(
    -- Danh sách người tham gia phòng
    ParticipantId VARCHAR(50) PRIMARY KEY,
    RoomId VARCHAR(50) NOT NULL,
    UserId VARCHAR(50) NOT NULL,
    JoinedAt DATETIME DEFAULT CURRENT_TIMESTAMP,
    LastSeenAt DATETIME NULL,
    LeftAt DATETIME NULL,
    TotalActiveSeconds INT NOT NULL DEFAULT 0,
    -- tổng thời gian người học hoạt động trong phòng
    MicStatus VARCHAR(20) NOT NULL DEFAULT 'OFF',
    HandRaiseStatus VARCHAR(30) NOT NULL DEFAULT 'NONE',
    ParticipantStatus VARCHAR(30) NOT NULL DEFAULT 'JOINED',
    -- đang trong phòng hay đã rời
    FOREIGN KEY (RoomId) REFERENCES Rooms(RoomId),
    FOREIGN KEY (UserId) REFERENCES Users(UserId)
)
ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE INDEX idx_room_participants_room ON RoomParticipants(RoomId);
CREATE INDEX idx_room_participants_user ON RoomParticipants(UserId);

CREATE TABLE RoomMaterials
(
    -- Tài liệu mentor ghim trong phòng cho người học
    MaterialId VARCHAR(50) PRIMARY KEY,
    RoomId VARCHAR(50) NOT NULL,
    UploadedBy VARCHAR(50) NOT NULL,
    FileName VARCHAR(255) NOT NULL,
    FileUrl VARCHAR(255) NOT NULL,
    FileType VARCHAR(50) NULL,
    UploadedAt DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    IsVisible TINYINT NOT NULL DEFAULT 1,
    -- 1 là hiện, 0 là tắt
    FOREIGN KEY (RoomId) REFERENCES Rooms(RoomId)
)
ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE LearningSessions
(
    LearningSessionId VARCHAR(50) PRIMARY KEY,
    UserId VARCHAR(50) NOT NULL,
    RoomId VARCHAR(50) NOT NULL,
    LevelId VARCHAR(50) NOT NULL,
    SubLevelId VARCHAR(50) NOT NULL,
    StartedAt DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    EndedAt DATETIME NULL,
    DurationSeconds INT NOT NULL DEFAULT 0,-- Tổng thời gian từ lúc bắt đầu tới kết thúc
    ValidLearningMinutes INT NOT NULL DEFAULT 0,
    -- Thời gian hợp lệ
    RequiredMinutes INT NOT NULL DEFAULT 420,
    -- Số phút tối thiểu cần đạt
    AttendanceConfirmCount INT NOT NULL DEFAULT 0,
    -- Số lần người học bấm nút đang học
    AttendanceAskedCount INT NOT NULL DEFAULT 0,
    -- tổng số lần hệ thống hỏi
    IsPassed TINYINT NOT NULL DEFAULT 0,
    -- Có pass sublevel không
    SessionStatus VARCHAR(30) NOT NULL DEFAULT 'IN_PROGRESS',
    -- IN_PROGRESS, COMPLETED, FAILED
    FOREIGN KEY (UserId) REFERENCES Users(UserId),
    FOREIGN KEY (RoomId) REFERENCES Rooms(RoomId),
    FOREIGN KEY (LevelId) REFERENCES Levels(LevelId),
    FOREIGN KEY (SubLevelId) REFERENCES SubLevel(SubLevelId)
)
ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE INDEX idx_learning_user_level ON LearningSessions(UserId, LevelId);
CREATE INDEX idx_learning_room ON LearningSessions(RoomId);

CREATE TABLE AttendanceChecks
(
    CheckId VARCHAR(50) PRIMARY KEY,
    LearningSessionId VARCHAR(50) NOT NULL,
    AskedAt DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    -- Hệ thống hỏi lúc nào
    ConfirmedAt DATETIME NULL,
    -- Người học confirm lúc nào
    IsConfirmed TINYINT NOT NULL DEFAULT 0,
    -- Người học có confirm hay không
    FOREIGN KEY (LearningSessionId) REFERENCES LearningSessions(LearningSessionId)
)
ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE UserProgress
(
    ProgressId VARCHAR(50) PRIMARY KEY,
    UserId VARCHAR(50) NOT NULL,
    LanguageId VARCHAR(50) NOT NULL,
    LevelId VARCHAR(50) NOT NULL,
    CurrentSubLevelId VARCHAR(50) NULL,
    -- Sublevel đang học hiện tại
    CompletedSubLevelCount INT NOT NULL DEFAULT 0,
    -- Đã hoàn thành bao nhiêu sublevel
    ProgressPercent DECIMAL(5,2) NOT NULL DEFAULT 0,
    -- Tỉ lệ phần trăm đạt được
    Status VARCHAR(30) NOT NULL DEFAULT 'IN_PROGRESS',
    -- IN_PROGRESS, COMPLETED, LOCKED
    CompletedAt DATETIME NULL,
    -- Hoàn thành lúc nào 
    FOREIGN KEY (UserId) REFERENCES Users(UserId),
    FOREIGN KEY (LanguageId) REFERENCES Languages(LanguageId),
    FOREIGN KEY (LevelId) REFERENCES Levels(LevelId),
    FOREIGN KEY (CurrentSubLevelId) REFERENCES SubLevel(SubLevelId)
)
ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE LevelUpgradeRules
(
    -- Bảng này lưu luật lên level
    RuleId VARCHAR(50) PRIMARY KEY,
    LevelId VARCHAR(50) NOT NULL,
    RequiredSubLevelCount INT NOT NULL DEFAULT 6,
    -- cần hoàn thành bao nhiêu sublevel.
    MinSecondsPerSubLevel INT NOT NULL DEFAULT 420,
    -- mỗi sublevel cần tối thiểu bao nhiêu giây.
    MinQuizScorePercent DECIMAL(5,2) NOT NULL DEFAULT 80,
    -- điểm quiz tối thiểu, ví dụ 80%.
    MinAttendanceConfirmPercent DECIMAL(5,2) NOT NULL DEFAULT 60,
    -- tỷ lệ xác nhận tối thiểu.
    MaxOfflineCount INT NOT NULL DEFAULT 2,
    -- tối đa số lần không xác nhận online vẫn được nhận quiz.
    IsActive TINYINT NOT NULL DEFAULT 1,
    FOREIGN KEY (LevelId) REFERENCES Levels(LevelId)
)
ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE MentorRatings
(
    RatingId VARCHAR(50) PRIMARY KEY,
    MentorUserId VARCHAR(50) NOT NULL,
    LearnerUserId VARCHAR(50) NOT NULL,
    RoomId VARCHAR(50) NOT NULL,
    RatingValue TINYINT NOT NULL,
    -- 1 -> 5
    CommentText TEXT NULL,
    -- Lời nhận xét
    CreatedAt DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (MentorUserId) REFERENCES Users(UserId),
    FOREIGN KEY (LearnerUserId) REFERENCES Users(UserId),
    FOREIGN KEY (RoomId) REFERENCES Rooms(RoomId)
)
ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE Wallets
(
    -- Ví tiền của mỗi user
    WalletId VARCHAR(50) PRIMARY KEY,
    UserId VARCHAR(50) NOT NULL UNIQUE,
    Balance DECIMAL(12,2) NOT NULL DEFAULT 0,
    -- Số dư ví
    CurrencyCode VARCHAR(10) NOT NULL DEFAULT 'VND',
    WalletStatus VARCHAR(30) NOT NULL DEFAULT 'ACTIVE',
    -- ACTIVE, LOCKED
    CreatedAt DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (UserId) REFERENCES Users(UserId)
)
ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE WalletTransactions
(
    WalletTransactionId VARCHAR(50) PRIMARY KEY,
    WalletId VARCHAR(50) NOT NULL,
    UserId VARCHAR(50) NOT NULL,
    RelatedUserId VARCHAR(50) NULL,
    TransactionType VARCHAR(50) NOT NULL,
    -- ví dụ TOPUP, DONATE, GIFT, PURCHASE, WITHDRAW.
    Direction VARCHAR(10) NOT NULL,
    -- IN hoặc OUT
    Amount DECIMAL(12,2) NOT NULL,
    -- số tiền giao dịch
    BalanceBefore DECIMAL(12,2) NOT NULL DEFAULT 0,
    -- Số dư trước giao dịch
    BalanceAfter DECIMAL(12,2) NOT NULL DEFAULT 0,
    -- Số dư sau giao dịch
    RelatedRefType VARCHAR(50) NULL,
    RelatedRefId VARCHAR(50) NULL,
    DescriptionText VARCHAR(255) NULL,
    TransactionStatus VARCHAR(30) NOT NULL DEFAULT 'SUCCESS',
    CreatedAt DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (WalletId) REFERENCES Wallets(WalletId),
    FOREIGN KEY (UserId) REFERENCES Users(UserId),
    FOREIGN KEY (RelatedUserId) REFERENCES Users(UserId),
    CHECK (Amount > 0)
)
ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE INDEX idx_wallet_txn_user ON WalletTransactions(UserId);
CREATE INDEX idx_wallet_txn_type ON WalletTransactions(TransactionType);

CREATE TABLE TopUpOrders
(
    -- đơn nạp tiền vào ví.
    TopUpOrderId VARCHAR(50) PRIMARY KEY,
    UserId VARCHAR(50) NOT NULL,
    WalletId VARCHAR(50) NOT NULL,
    Amount DECIMAL(12,2) NOT NULL,
    PaymentProvider VARCHAR(50) NULL,
    -- cổng thanh toán, ví dụ MOMO, VNPAY, BANK_TRANSFER.
    ExternalTransactionCode VARCHAR(100) NULL,
    -- mã giao dịch từ bên ngoài.
    OrderStatus VARCHAR(30) NOT NULL DEFAULT 'PENDING',
    -- PENDING, PAID, FAILED, CANCELLED.
    CreatedAt DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PaidAt DATETIME NULL,
    -- thời điểm thanh toán thành công
    FOREIGN KEY (UserId) REFERENCES Users(UserId),
    FOREIGN KEY (WalletId) REFERENCES Wallets(WalletId),
    CHECK (Amount > 0)
)
ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE WithdrawRequests
(
    -- yêu cầu rút tiền
    WithdrawRequestId VARCHAR(50) PRIMARY KEY,
    UserId VARCHAR(50) NOT NULL,
    WalletId VARCHAR(50) NOT NULL,
    Amount DECIMAL(12,2) NOT NULL,
    FeePercent DECIMAL(5,2) NOT NULL DEFAULT 0,
    FeeAmount DECIMAL(12,2) NOT NULL DEFAULT 0,
    NetAmount DECIMAL(12,2) NOT NULL DEFAULT 0,
    BankName VARCHAR(100) NOT NULL,
    BankAccountNumber VARCHAR(50) NOT NULL,
    BankAccountName VARCHAR(100) NOT NULL,
    RequestStatus VARCHAR(30) NOT NULL DEFAULT 'PENDING',
    RejectReason VARCHAR(255) NULL,
    RequestedAt DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    ReviewedAt DATETIME NULL,
    FOREIGN KEY (UserId) REFERENCES Users(UserId),
    FOREIGN KEY (WalletId) REFERENCES Wallets(WalletId)
)
ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE Gifts
(
    GiftId VARCHAR(50) PRIMARY KEY,
    GiftName VARCHAR(100) NOT NULL,
    PriceAmount DECIMAL(12,2) NOT NULL,
    IconUrl VARCHAR(255) NULL,
    IsActive TINYINT NOT NULL DEFAULT 1,
    CreatedAt DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
)
ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE Donations
(
    -- lịch sử donate tiền trực tiếp
    DonationId VARCHAR(50) PRIMARY KEY,
    FromUserId VARCHAR(50) NOT NULL,
    -- Tiền từ ai
    ToUserId VARCHAR(50) NOT NULL,
    -- Tiền tới ai
    RoomId VARCHAR(50) NULL,
    Amount DECIMAL(12,2) NOT NULL,
    MessageText VARCHAR(255) NULL,
    FromWalletTransactionId VARCHAR(50) NULL,
    ToWalletTransactionId VARCHAR(50) NULL,
    CreatedAt DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (FromUserId) REFERENCES Users(UserId),
    FOREIGN KEY (ToUserId) REFERENCES Users(UserId),
    FOREIGN KEY (RoomId) REFERENCES Rooms(RoomId),
    FOREIGN KEY (FromWalletTransactionId) REFERENCES WalletTransactions(WalletTransactionId),
    FOREIGN KEY (ToWalletTransactionId) REFERENCES WalletTransactions(WalletTransactionId)
)
ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE GiftTransactions
(
    -- Lịch sử tặng quà ảo
    GiftTransactionId VARCHAR(50) PRIMARY KEY,
    GiftId VARCHAR(50) NOT NULL,
    FromUserId VARCHAR(50) NOT NULL,
    ToUserId VARCHAR(50) NOT NULL,
    RoomId VARCHAR(50) NULL,
    Quantity INT NOT NULL DEFAULT 1,
    TotalAmount DECIMAL(12,2) NOT NULL,
    -- tổng tiền quy đổi.
    FromWalletTransactionId VARCHAR(50) NULL,
    ToWalletTransactionId VARCHAR(50) NULL,
    CreatedAt DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (GiftId) REFERENCES Gifts(GiftId),
    FOREIGN KEY (FromUserId) REFERENCES Users(UserId),
    FOREIGN KEY (ToUserId) REFERENCES Users(UserId),
    FOREIGN KEY (RoomId) REFERENCES Rooms(RoomId),
    FOREIGN KEY (FromWalletTransactionId) REFERENCES WalletTransactions(WalletTransactionId),
    FOREIGN KEY (ToWalletTransactionId) REFERENCES WalletTransactions(WalletTransactionId),
    CHECK (Quantity > 0),
    CHECK (TotalAmount > 0)
)
ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE LiveRecordings
(
    RecordingId VARCHAR(50) PRIMARY KEY,
    RoomId VARCHAR(50) NOT NULL,
    CreatorUserId VARCHAR(50) NOT NULL,
    AudioUrl VARCHAR(255) NULL,
    DurationMinutes INT NOT NULL DEFAULT 0,
    -- Thời lượng bản ghi
    RecordingStatus VARCHAR(30) NOT NULL DEFAULT 'PROCESSING',
    CreatedAt DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    -- Bắt đầu record khi nào
    CompletedAt DATETIME NULL,
    -- Hoàn thành record khi nào
    FOREIGN KEY (RoomId) REFERENCES Rooms(RoomId),
    FOREIGN KEY (CreatorUserId) REFERENCES Users(UserId)
)
ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE PaidContents
(
    ContentId VARCHAR(50) PRIMARY KEY,
    CreatorUserId VARCHAR(50) NOT NULL,
    RoomId VARCHAR(50) NULL,
    RecordingId VARCHAR(50) NULL,
    ContentType VARCHAR(30) NOT NULL,
    -- PODCAST, PAID_LIVE, COURSE.
    Title VARCHAR(150) NOT NULL,
    DescriptionText TEXT NULL,
    ThumbnailUrl VARCHAR(255) NULL,
    -- Ảnh bản ghi
    AudioUrl VARCHAR(255) NULL,
    -- Đường dẫn bản ghi
    PriceAmount DECIMAL(12,2) NOT NULL DEFAULT 0,
    ContentStatus VARCHAR(30) NOT NULL DEFAULT 'DRAFT',
    PublishedAt DATETIME NULL,
    -- thời điểm đăng bán.
    FOREIGN KEY (CreatorUserId) REFERENCES Users(UserId),
    FOREIGN KEY (RoomId) REFERENCES Rooms(RoomId),
    FOREIGN KEY (RecordingId) REFERENCES LiveRecordings(RecordingId)
)
ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE PaymentSettings
(
    PaymentSettingId VARCHAR(50) PRIMARY KEY,
    ProviderCode VARCHAR(50) NOT NULL,
    ReceiverUserId VARCHAR(50) NOT NULL,
    ReceiverName VARCHAR(100) NOT NULL,
    ReceiverPhone VARCHAR(20) NOT NULL,
    QrImageUrl VARCHAR(255) NULL,
    TransferContentTemplate VARCHAR(255) NOT NULL,
    IsActive TINYINT NOT NULL DEFAULT 1,
    CreatedAt DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UpdatedAt DATETIME NULL,
    FOREIGN KEY (ReceiverUserId) REFERENCES Users(UserId)
);

CREATE INDEX idx_paid_contents_creator ON PaidContents(CreatorUserId);
CREATE INDEX idx_paid_contents_status ON PaidContents(ContentStatus);

CREATE TABLE ContentPurchases
(
    -- Lịch sử người học mua nội dung trả phí podcast.
    PurchaseId VARCHAR(50) PRIMARY KEY,
    ContentId VARCHAR(50) NOT NULL,
    BuyerUserId VARCHAR(50) NOT NULL,
    SellerUserId VARCHAR(50) NOT NULL,
    PriceAmount DECIMAL(12,2) NOT NULL,
    BuyerWalletTransactionId VARCHAR(50) NULL,
    SellerWalletTransactionId VARCHAR(50) NULL,
    PurchasedAt DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (ContentId) REFERENCES PaidContents(ContentId),
    FOREIGN KEY (BuyerUserId) REFERENCES Users(UserId),
    FOREIGN KEY (SellerUserId) REFERENCES Users(UserId),
    FOREIGN KEY (BuyerWalletTransactionId) REFERENCES WalletTransactions(WalletTransactionId),
    FOREIGN KEY (SellerWalletTransactionId) REFERENCES WalletTransactions(WalletTransactionId)
)
ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE LiveAccessTickets
(
    -- Vé vào phiên live trả phí
    TicketId VARCHAR(50) PRIMARY KEY,
    RoomId VARCHAR(50) NOT NULL,
    UserId VARCHAR(50) NOT NULL,
    PurchaseId VARCHAR(50) NULL,
    TicketStatus VARCHAR(30) NOT NULL DEFAULT 'ACTIVE',
    CreatedAt DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (RoomId) REFERENCES Rooms(RoomId),
    FOREIGN KEY (UserId) REFERENCES Users(UserId),
    FOREIGN KEY (PurchaseId) REFERENCES ContentPurchases(PurchaseId)
)
ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE Notifications
(
    NotificationId VARCHAR(50) PRIMARY KEY,
    UserId VARCHAR(50) NOT NULL,
    Title VARCHAR(150) NOT NULL,
    BodyText VARCHAR(255) NOT NULL,
    NotificationType VARCHAR(50) NOT NULL,
    RefType VARCHAR(50) NULL,
    -- liên quan tới loại dữ liệu nào, ví dụ ROOM, PAYMENT, APPLICATION.
    IsRead TINYINT NOT NULL DEFAULT 0,
    CreatedAt DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (UserId) REFERENCES Users(UserId)
)
ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE INDEX idx_notifications_user ON Notifications(UserId, IsRead);

CREATE TABLE RoomQuizzes
(
    -- lưu bài kiểm tra của một phòng
    QuizId VARCHAR(50) PRIMARY KEY,
    RoomId VARCHAR(50) NULL,
    LevelId VARCHAR(50) NOT NULL,
    CreatedBy VARCHAR(50) NOT NULL,
    QuizTitle VARCHAR(150) NOT NULL,
    DurationMinutes INT NULL,
    PassingScorePercent DECIMAL(5,2) NOT NULL DEFAULT 80,
    QuizStatus VARCHAR(30) NOT NULL DEFAULT 'DRAFT',
    PublishedAt DATETIME NULL,
    CreatedAt DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (RoomId) REFERENCES Rooms(RoomId),
    FOREIGN KEY (CreatedBy) REFERENCES Users(UserId)
)
ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE RoomQuizQuestions
(
    -- lưu câu hỏi trong quiz.
    RoomQuizQuestionId VARCHAR(50) PRIMARY KEY,
    QuizId VARCHAR(50) NOT NULL,
    QuestionText TEXT NOT NULL,
    QuestionType VARCHAR(50) NOT NULL DEFAULT 'MULTIPLE_CHOICE',
    -- loại câu hỏi, ví dụ MULTIPLE_CHOICE, TEXT.
    CorrectAnswerText TEXT NULL,
    -- đáp án đúng cho câu tự luận, dùng so sánh chuỗi thường hóa.
    QuestionOrder INT NOT NULL,
    -- Thứ tự câu hỏi
    FOREIGN KEY (QuizId) REFERENCES RoomQuizzes(QuizId)
)
ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE RoomQuizOptions
(
    -- lưu các đáp án lựa chọn của câu hỏi trắc nghiệm
    OptionId VARCHAR(50) PRIMARY KEY,
    RoomQuizQuestionId VARCHAR(50) NOT NULL,
    OptionText TEXT NOT NULL,
    -- nội dung đáp án.
    IsCorrect TINYINT NOT NULL DEFAULT 0,
    -- đáp án này đúng hay sai.
    OptionOrder INT NOT NULL,
    -- Thứ tự đáp án
    FOREIGN KEY (RoomQuizQuestionId) REFERENCES RoomQuizQuestions(RoomQuizQuestionId)
)
ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE RoomQuizAttempts
(
    -- Mốc đánh giá xem user nào vượt qua
    AttemptId VARCHAR(50) PRIMARY KEY,
    QuizId VARCHAR(50) NOT NULL,
    UserId VARCHAR(50) NOT NULL,
    ScorePercent DECIMAL(5,2) NOT NULL DEFAULT 0,
    -- Phần trăm điểm đạt được
    IsPassed TINYINT NOT NULL DEFAULT 0,
    -- Kết quả
    AttemptStatus VARCHAR(30) NOT NULL DEFAULT 'ASSIGNED',
    -- ASSIGNED, IN_PROGRESS, SUBMITTED, EXPIRED
    StartedAt DATETIME NULL,
    -- Làm bài lúc nào
    SubmittedAt DATETIME NULL,
    -- Nộp bài lúc nào
    FOREIGN KEY (QuizId) REFERENCES RoomQuizzes(QuizId),
    FOREIGN KEY (UserId) REFERENCES Users(UserId)
)
ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE RoomQuizAttemptAnswers
(
    -- Chi tiết đáp án user chọn
    AttemptAnswerId VARCHAR(50) PRIMARY KEY,
    AttemptId VARCHAR(50) NOT NULL,
    RoomQuizQuestionId VARCHAR(50) NOT NULL,
    SelectedOptionId VARCHAR(50) NULL,
    AnswerText TEXT NULL,
    IsCorrect TINYINT NOT NULL DEFAULT 0,
    FOREIGN KEY (AttemptId) REFERENCES RoomQuizAttempts(AttemptId),
    FOREIGN KEY (RoomQuizQuestionId) REFERENCES RoomQuizQuestions(RoomQuizQuestionId),
    FOREIGN KEY (SelectedOptionId) REFERENCES RoomQuizOptions(OptionId)
)
ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
