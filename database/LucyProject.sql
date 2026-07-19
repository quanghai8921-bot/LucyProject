CREATE DATABASE lucyProject

USE lucyProject;

CREATE TABLE Languages
(
    LanguageId VARCHAR(50) PRIMARY KEY,
    LanguageName VARCHAR(50) NOT NULL
)

CREATE TABLE Users
(
    UserId VARCHAR(50) PRIMARY KEY,
    FullName VARCHAR(50) NOT NULL,
    Email VARCHAR(50) UNIQUE NOT NULL,
    Passwords VARCHAR(255) NOT NULL,
    IsStatus INT NOT NULL
)

CREATE TABLE Roles
(
    RoleId VARCHAR(50) PRIMARY KEY,
    RoleName VARCHAR(50) NOT NULL
)
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
    PRIMARY KEY (UserId, RoleId),
    FOREIGN KEY (UserId) REFERENCES Users(UserId),
    FOREIGN KEY (RoleId) REFERENCES Roles(RoleId)
)

CREATE TABLE AvatarPersonas
(
    UserId VARCHAR(50) PRIMARY KEY,
    DisplayName VARCHAR(50) NOT NULL,
    AvatarUrl VARCHAR(255),
    IsAnonymous INT NOT NULL DEFAULT 1,
    FOREIGN KEY (UserId) REFERENCES Users(UserId)
)

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

CREATE TABLE ContentCreatorApplications
(
    -- Đơn đăng kí creator
    ApplicationId VARCHAR(50) PRIMARY KEY,
    UserId VARCHAR(50) NOT NULL,
    CertificateUrl VARCHAR(255) NULL,
    Status VARCHAR(30) NOT NULL DEFAULT 'PENDING',
    RejectReason VARCHAR(255) NULL,
    SubmittedAt DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (UserId) REFERENCES Users(UserId)
)

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
	SubDurationMinutes INT null,
	SubNumber INT null,
    CompletionOutcome NVARCHAR(MAX),
    Descriptions NVARCHAR(MAX),
    FOREIGN KEY (LanguageId) REFERENCES Languages(LanguageId)
)


CREATE TABLE LevelGroups
(
    GroupId VARCHAR(50) PRIMARY KEY,
    StageId VARCHAR(50) NOT NULL,
    GroupTitle NVARCHAR(255) NULL,
    GrCefrLevel VARCHAR(50) null,
    FOREIGN KEY (StageId) REFERENCES Stages(StageId)
)

CREATE TABLE Levels
(
    LevelId VARCHAR(50) PRIMARY KEY,
    GroupId VARCHAR(50) NULL,
    StageId VARCHAR(50) NOT NULL,
    LevelTitle NVARCHAR(255) null,
    LevelNumber INT NOT NULL,
    FOREIGN KEY (StageId) REFERENCES Stages(StageId),
    FOREIGN KEY (GroupId) REFERENCES LevelGroups(GroupId)
)

CREATE TABLE SubLevel
(
    SubLevelId VARCHAR(50) PRIMARY KEY,
    LevelId VARCHAR(50) NOT NULL,
    SubLevelNumber INT NULL,
    SublevelTitle NVARCHAR(255) NULL,
    MainTask NVARCHAR(MAX) null,
    FOREIGN KEY (LevelId) REFERENCES Levels(LevelId)
)

CREATE TABLE Rooms
(
    RoomId VARCHAR(50) PRIMARY KEY,
    HostUserId VARCHAR(50) NOT NULL,
    HostRole VARCHAR(30) NOT NULL,
    LevelId VARCHAR(50) NULL,
    LanguageId VARCHAR(50) NULL,
    RoomTitle VARCHAR(100) NOT NULL,
    RoomType varchar(100) null,
    -- MENTOR_CLASS, CREATOR_LIVE
    AccessType varchar(100) null,
    -- Free, Paid
    PriceAmount decimal(18,2) null,
    -- Giá tiền nếu phòng đó thu phí
    ScheduledStartAt DATETIME NOT NULL,
    -- Thời gian lên lịch phòng sẽ mở
    EndedAt DATETIME NULL,
    RoomStatus VARCHAR(30) NOT NULL,
    -- Trạng thái phòng OPEN, STUDYING, ENDED, CANCELLED  
    CreatedAt DATETIME DEFAULT CURRENT_TIMESTAMP,
    -- Thời gian mentor bắt đầu tạo Live
    FOREIGN KEY (HostUserId) REFERENCES Users(UserId),
    FOREIGN KEY (LanguageId) REFERENCES Languages(LanguageId),
    FOREIGN KEY (LevelId) REFERENCES Levels(LevelId)
)

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

CREATE TABLE RoomParticipants
(
    -- Danh sách người tham gia phòng
    ParticipantId VARCHAR(50) PRIMARY KEY,
    RoomId VARCHAR(50) NOT NULL,
    UserId VARCHAR(50) NOT NULL,
    JoinedAt DATETIME DEFAULT CURRENT_TIMESTAMP,
    LeftAt DATETIME NULL,
    ParticipantStatus VARCHAR(30) NOT NULL DEFAULT 'JOINED',
    FOREIGN KEY (RoomId) REFERENCES Rooms(RoomId),
    FOREIGN KEY (UserId) REFERENCES Users(UserId)
)

CREATE INDEX idx_room_participants_room ON RoomParticipants(RoomId);
CREATE INDEX idx_room_participants_user ON RoomParticipants(UserId);


CREATE TABLE LevelUpgradeRules
(
    -- Bảng này lưu luật lên level
    RuleId VARCHAR(50) PRIMARY KEY,
    LevelId VARCHAR(50) NOT NULL,
    RequiredSubLevelCount INT NOT NULL DEFAULT 6,
    -- cần hoàn thành bao nhiêu sublevel.
    MinQuizScorePercent DECIMAL(5,2) NOT NULL DEFAULT 80,
    -- điểm quiz tối thiểu, ví dụ 80%.
    IsActive TINYINT NOT NULL DEFAULT 1,
    FOREIGN KEY (LevelId) REFERENCES Levels(LevelId)
)

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

CREATE TABLE WalletTransactions
(
    WalletTransactionId VARCHAR(50) PRIMARY KEY,
    WalletId VARCHAR(50) NOT NULL,
    UserId VARCHAR(50) NOT NULL,
    TransactionType VARCHAR(50) NOT NULL,
    -- ví dụ TOPUP, DONATE, GIFT, PURCHASE, WITHDRAW.
    Direction VARCHAR(10) NOT NULL,
    -- IN hoặc OUT
    Amount DECIMAL(12,2) NOT NULL,
    -- số tiền giao dịch
    TransactionStatus VARCHAR(30) NOT NULL DEFAULT 'SUCCESS',
    CreatedAt DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (WalletId) REFERENCES Wallets(WalletId),
    FOREIGN KEY (UserId) REFERENCES Users(UserId)
)

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

CREATE TABLE WithdrawRequests
(
    -- yêu cầu rút tiền
    WithdrawRequestId VARCHAR(50) PRIMARY KEY,
    UserId VARCHAR(50) NOT NULL,
    WalletId VARCHAR(50) NOT NULL,
    Amount DECIMAL(12,2) NOT NULL,
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

CREATE TABLE Gifts
(
    GiftId VARCHAR(50) PRIMARY KEY,
    GiftName VARCHAR(100) NOT NULL,
    PriceAmount DECIMAL(12,2) NOT NULL,
    IconUrl VARCHAR(255) NULL,
    IsActive TINYINT NOT NULL DEFAULT 1,
    CreatedAt DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
)

CREATE TABLE Donations
(
    DonationId VARCHAR(50) PRIMARY KEY,

    GiftId VARCHAR(50) NOT NULL,

    FromUserId VARCHAR(50) NOT NULL,

    ToUserId VARCHAR(50) NOT NULL,

    RoomId VARCHAR(50) NOT NULL,

    Quantity INT NOT NULL DEFAULT 1,

    TotalAmount DECIMAL(12,2) NOT NULL,

    WalletTransactionId VARCHAR(50) NOT NULL,

    MessageText VARCHAR(255) NULL,

    CreatedAt DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY (GiftId) REFERENCES Gifts(GiftId),
    FOREIGN KEY (FromUserId) REFERENCES Users(UserId),
    FOREIGN KEY (ToUserId) REFERENCES Users(UserId),
    FOREIGN KEY (RoomId) REFERENCES Rooms(RoomId),
    FOREIGN KEY (WalletTransactionId)
        REFERENCES WalletTransactions(WalletTransactionId)
);

CREATE TABLE PinnedMaterials
(
    PinnedMaterialId VARCHAR(50) PRIMARY KEY,

    RoomId VARCHAR(50) NOT NULL,

    UploadedByUserId VARCHAR(50) NOT NULL,

    Title VARCHAR(255) NOT NULL,

    FileUrl VARCHAR(500) NOT NULL,

    FileType VARCHAR(50) NULL,
    -- PDF, DOCX, PPTX, IMAGE...

    FileSize BIGINT NULL,

    DisplayOrder INT DEFAULT 1,

    IsActive TINYINT DEFAULT 1,

    CreatedAt DATETIME DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY (RoomId) REFERENCES Rooms(RoomId),
    FOREIGN KEY (UploadedByUserId) REFERENCES Users(UserId)
);

CREATE TABLE PaidContents
(
    ContentId VARCHAR(50) PRIMARY KEY,
    CreatorUserId VARCHAR(50) NOT NULL,
    ContentType VARCHAR(30) NOT NULL,
    -- PODCAST, PAID_LIVE, COURSE.
    Title VARCHAR(150) NOT NULL,
    DescriptionText TEXT NULL,
    AudioUrl VARCHAR(255) NULL,
    -- Đường dẫn bản ghi
    PriceAmount DECIMAL(12,2) NOT NULL DEFAULT 0,
    ContentStatus VARCHAR(30) NOT NULL DEFAULT 'DRAFT',
    PublishedAt DATETIME NULL,
    -- thời điểm đăng bán.
    FOREIGN KEY (CreatorUserId) REFERENCES Users(UserId)
)

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


CREATE TABLE LiveAccessTickets
(
    -- Vé vào phiên live trả phí
    TicketId VARCHAR(50) PRIMARY KEY,
    RoomId VARCHAR(50) NULL,
    UserId VARCHAR(50) NOT NULL,
    WalletId VARCHAR(50) NULL,
    TicketStatus VARCHAR(30) NOT NULL DEFAULT 'ACTIVE',
    FOREIGN KEY (RoomId) REFERENCES Rooms(RoomId),
    FOREIGN KEY (UserId) REFERENCES Users(UserId),
    FOREIGN KEY (WalletId) REFERENCES WalletTransactions(WalletId)
)

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
