using Microsoft.EntityFrameworkCore.Migrations;
using Lucy.Auth.Api.Data;

#nullable disable

namespace Lucy.Auth.Api.Migrations;

[Migration("20260602022052_InitialCreate")]
[Microsoft.EntityFrameworkCore.Infrastructure.DbContext(typeof(AuthDbContext))]
public partial class InitialCreate : Migration
{
    protected override void Up(MigrationBuilder migrationBuilder)
    {
        migrationBuilder.Sql("""
CREATE TABLE Languages (
    LanguageId VARCHAR(50) PRIMARY KEY,
    LanguageName VARCHAR(50) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE Users (
    UserId VARCHAR(50) PRIMARY KEY,
    FullName VARCHAR(50) NOT NULL,
    PhoneNumber VARCHAR(10) UNIQUE NOT NULL,
    Email VARCHAR(50) UNIQUE NOT NULL,
    Passwords VARCHAR(255) NOT NULL,
    CreatedAt DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    IsStatus INT NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE Roles (
    RoleId VARCHAR(50) PRIMARY KEY,
    RoleName VARCHAR(50) NOT NULL,
    IsActive TINYINT NOT NULL DEFAULT 1
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT INTO Roles (RoleId, RoleName) VALUES
('R001', 'ADMINSTRATOR'),
('R002', 'LUCY ANONYMOUS'),
('R003', 'MENTOR'),
('R004', 'CONTENT CREATOR');

CREATE TABLE UserRoles (
    UserId VARCHAR(50) NOT NULL,
    RoleId VARCHAR(50) NOT NULL,
    AssignedDate DATETIME DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (UserId, RoleId),
    FOREIGN KEY (UserId) REFERENCES Users(UserId),
    FOREIGN KEY (RoleId) REFERENCES Roles(RoleId)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE AvatarPersonas (
    UserId VARCHAR(50) PRIMARY KEY,
    DisplayName VARCHAR(50) NOT NULL,
    AvatarUrl VARCHAR(255),
    IsAnonymous INT NOT NULL DEFAULT 1,
    CreatedAt DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (UserId) REFERENCES Users(UserId)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE MentorApplications (
    ApplicationId VARCHAR(50) PRIMARY KEY,
    UserId VARCHAR(50) NOT NULL,
    LanguageId VARCHAR(50) NULL,
    CertificateUrl VARCHAR(255) NULL,
    Status VARCHAR(30) NOT NULL DEFAULT 'PENDING',
    RejectReason VARCHAR(255) NULL,
    SubmittedAt DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (UserId) REFERENCES Users(UserId),
    FOREIGN KEY (LanguageId) REFERENCES Languages(LanguageId)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE CreatorUpgradeRequests (
    UpgradeRequestId VARCHAR(50) PRIMARY KEY,
    UserId VARCHAR(50) NOT NULL,
    TotalTeachingMinutes INT NOT NULL DEFAULT 0,
    AverageRating DECIMAL(3,2) NULL,
    LearnerCount INT NOT NULL DEFAULT 0,
    Status VARCHAR(30) NOT NULL DEFAULT 'PENDING',
    RejectReason VARCHAR(255) NULL,
    SubmittedAt DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (UserId) REFERENCES Users(UserId)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
""");
    }

    protected override void Down(MigrationBuilder migrationBuilder)
    {
        migrationBuilder.Sql("""
DROP TABLE IF EXISTS CreatorUpgradeRequests;
DROP TABLE IF EXISTS MentorApplications;
DROP TABLE IF EXISTS AvatarPersonas;
DROP TABLE IF EXISTS UserRoles;
DROP TABLE IF EXISTS Roles;
DROP TABLE IF EXISTS Users;
DROP TABLE IF EXISTS Languages;
""");
    }
}
