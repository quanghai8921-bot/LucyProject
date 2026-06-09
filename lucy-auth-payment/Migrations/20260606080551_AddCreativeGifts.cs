using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

#pragma warning disable CA1814 // Prefer jagged arrays over multidimensional

namespace lucy_auth_payment.Migrations
{
    /// <inheritdoc />
    public partial class AddCreativeGifts : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.UpdateData(
                table: "Gifts",
                keyColumn: "Id",
                keyValue: new Guid("00000000-0000-0000-0000-000000000001"),
                columns: new[] { "Name", "Price" },
                values: new object[] { "Cây Bút Thần Kỳ", 1m });

            migrationBuilder.UpdateData(
                table: "Gifts",
                keyColumn: "Id",
                keyValue: new Guid("00000000-0000-0000-0000-000000000002"),
                columns: new[] { "Name", "Price" },
                values: new object[] { "Cục Tẩy \"Xóa Deadline\"", 2m });

            migrationBuilder.UpdateData(
                table: "Gifts",
                keyColumn: "Id",
                keyValue: new Guid("00000000-0000-0000-0000-000000000003"),
                columns: new[] { "Name", "Price" },
                values: new object[] { "Ly Cà Phê 24/7", 5m });

            migrationBuilder.InsertData(
                table: "Gifts",
                columns: new[] { "Id", "AnimationUrl", "ImageUrl", "Name", "Price" },
                values: new object[,]
                {
                    { new Guid("00000000-0000-0000-0000-000000000004"), null, null, "Quyển Bí Kíp Tận Thế", 10m },
                    { new Guid("00000000-0000-0000-0000-000000000005"), null, null, "Vòng Đèn Led Chống Cận", 20m },
                    { new Guid("00000000-0000-0000-0000-000000000006"), null, null, "Bộ Não Thiên Tài", 50m },
                    { new Guid("00000000-0000-0000-0000-000000000007"), null, null, "Chiếc Cúp Thủ Khoa", 100m },
                    { new Guid("00000000-0000-0000-0000-000000000008"), null, null, "Vương Miện Học Bá", 200m },
                    { new Guid("00000000-0000-0000-0000-000000000009"), null, null, "Tàu Vũ Trụ Vượt Vũ Môn", 500m }
                });
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DeleteData(
                table: "Gifts",
                keyColumn: "Id",
                keyValue: new Guid("00000000-0000-0000-0000-000000000004"));

            migrationBuilder.DeleteData(
                table: "Gifts",
                keyColumn: "Id",
                keyValue: new Guid("00000000-0000-0000-0000-000000000005"));

            migrationBuilder.DeleteData(
                table: "Gifts",
                keyColumn: "Id",
                keyValue: new Guid("00000000-0000-0000-0000-000000000006"));

            migrationBuilder.DeleteData(
                table: "Gifts",
                keyColumn: "Id",
                keyValue: new Guid("00000000-0000-0000-0000-000000000007"));

            migrationBuilder.DeleteData(
                table: "Gifts",
                keyColumn: "Id",
                keyValue: new Guid("00000000-0000-0000-0000-000000000008"));

            migrationBuilder.DeleteData(
                table: "Gifts",
                keyColumn: "Id",
                keyValue: new Guid("00000000-0000-0000-0000-000000000009"));

            migrationBuilder.UpdateData(
                table: "Gifts",
                keyColumn: "Id",
                keyValue: new Guid("00000000-0000-0000-0000-000000000001"),
                columns: new[] { "Name", "Price" },
                values: new object[] { "Bông hồng", 10m });

            migrationBuilder.UpdateData(
                table: "Gifts",
                keyColumn: "Id",
                keyValue: new Guid("00000000-0000-0000-0000-000000000002"),
                columns: new[] { "Name", "Price" },
                values: new object[] { "Sách", 50m });

            migrationBuilder.UpdateData(
                table: "Gifts",
                keyColumn: "Id",
                keyValue: new Guid("00000000-0000-0000-0000-000000000003"),
                columns: new[] { "Name", "Price" },
                values: new object[] { "Siêu xe", 1000m });
        }
    }
}
