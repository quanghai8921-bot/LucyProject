using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace lucy_auth_payment.Migrations
{
    /// <inheritdoc />
    public partial class AddBankAccounts : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AlterDatabase()
                .Annotation("MySql:CharSet", "utf8mb4");

            // Bảng UserBankAccounts đã được tạo trong lần chạy bị lỗi trước đó
            // nên ta không tạo lại nữa để tránh lỗi 'already exists'.

            migrationBuilder.AddColumn<string>(
                name: "RecipientBankAccountId",
                table: "Transactions",
                type: "varchar(50)",
                nullable: true)
                .Annotation("MySql:CharSet", "utf8mb4");

            migrationBuilder.AddColumn<string>(
                name: "Note",
                table: "Transactions",
                type: "longtext",
                nullable: true)
                .Annotation("MySql:CharSet", "utf8mb4");

            migrationBuilder.CreateIndex(
                name: "IX_Transactions_RecipientBankAccountId",
                table: "Transactions",
                column: "RecipientBankAccountId");

            migrationBuilder.AddForeignKey(
                name: "FK_Transactions_UserBankAccounts_RecipientBankAccountId",
                table: "Transactions",
                column: "RecipientBankAccountId",
                principalTable: "UserBankAccounts",
                principalColumn: "Id",
                onDelete: ReferentialAction.SetNull);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_Transactions_UserBankAccounts_RecipientBankAccountId",
                table: "Transactions");

            migrationBuilder.DropIndex(
                name: "IX_Transactions_RecipientBankAccountId",
                table: "Transactions");

            migrationBuilder.DropColumn(
                name: "RecipientBankAccountId",
                table: "Transactions");

            migrationBuilder.DropColumn(
                name: "Note",
                table: "Transactions");

            migrationBuilder.DropTable(
                name: "UserBankAccounts");
        }
    }
}
