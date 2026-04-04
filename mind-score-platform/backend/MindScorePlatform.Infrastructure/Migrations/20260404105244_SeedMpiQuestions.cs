using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

#pragma warning disable CA1814 // Prefer jagged arrays over multidimensional

namespace MindScorePlatform.Infrastructure.Migrations
{
    /// <inheritdoc />
    public partial class SeedMpiQuestions : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.InsertData(
                table: "Tests",
                columns: new[] { "Id", "CreatedAtUtc", "Name" },
                values: new object[] { new Guid("00000000-0000-0000-0000-000000000001"), new DateTime(2026, 1, 1, 0, 0, 0, 0, DateTimeKind.Utc), "MPI Assessment" });

            migrationBuilder.InsertData(
                table: "Questions",
                columns: new[] { "Id", "Code", "CreatedAtUtc", "Order", "TestId", "Text" },
                values: new object[,]
                {
                    { new Guid("00000000-0000-0000-0001-000000000001"), "EI_01", new DateTime(2026, 1, 1, 0, 0, 0, 0, DateTimeKind.Utc), 1, new Guid("00000000-0000-0000-0000-000000000001"), "I feel energised after spending time with friends or a group of people." },
                    { new Guid("00000000-0000-0000-0001-000000000002"), "EI_02_R", new DateTime(2026, 1, 1, 0, 0, 0, 0, DateTimeKind.Utc), 2, new Guid("00000000-0000-0000-0000-000000000001"), "After a busy social day, I need quiet time alone to feel like myself again." },
                    { new Guid("00000000-0000-0000-0001-000000000003"), "EI_03", new DateTime(2026, 1, 1, 0, 0, 0, 0, DateTimeKind.Utc), 3, new Guid("00000000-0000-0000-0000-000000000001"), "I enjoy starting conversations with people I've never met before." },
                    { new Guid("00000000-0000-0000-0001-000000000004"), "EI_04_R", new DateTime(2026, 1, 1, 0, 0, 0, 0, DateTimeKind.Utc), 4, new Guid("00000000-0000-0000-0000-000000000001"), "I find large gatherings draining, even when I enjoy the people there." },
                    { new Guid("00000000-0000-0000-0001-000000000005"), "EI_05", new DateTime(2026, 1, 1, 0, 0, 0, 0, DateTimeKind.Utc), 5, new Guid("00000000-0000-0000-0000-000000000001"), "I think better when I'm talking ideas through with someone rather than sitting with them alone." },
                    { new Guid("00000000-0000-0000-0001-000000000006"), "SN_01", new DateTime(2026, 1, 1, 0, 0, 0, 0, DateTimeKind.Utc), 6, new Guid("00000000-0000-0000-0000-000000000001"), "I prefer clear, step-by-step instructions over figuring things out as I go." },
                    { new Guid("00000000-0000-0000-0001-000000000007"), "SN_02_R", new DateTime(2026, 1, 1, 0, 0, 0, 0, DateTimeKind.Utc), 7, new Guid("00000000-0000-0000-0000-000000000001"), "I often find myself thinking about what could be, more than what currently is." },
                    { new Guid("00000000-0000-0000-0001-000000000008"), "SN_03", new DateTime(2026, 1, 1, 0, 0, 0, 0, DateTimeKind.Utc), 8, new Guid("00000000-0000-0000-0000-000000000001"), "I trust facts and direct experience more than gut feelings or hunches." },
                    { new Guid("00000000-0000-0000-0001-000000000009"), "SN_04_R", new DateTime(2026, 1, 1, 0, 0, 0, 0, DateTimeKind.Utc), 9, new Guid("00000000-0000-0000-0000-000000000001"), "I get excited by new ideas and possibilities, even when they're not fully formed yet." },
                    { new Guid("00000000-0000-0000-0001-000000000010"), "SN_05", new DateTime(2026, 1, 1, 0, 0, 0, 0, DateTimeKind.Utc), 10, new Guid("00000000-0000-0000-0000-000000000001"), "I focus on the task at hand rather than getting distracted by future possibilities." },
                    { new Guid("00000000-0000-0000-0001-000000000011"), "TF_01", new DateTime(2026, 1, 1, 0, 0, 0, 0, DateTimeKind.Utc), 11, new Guid("00000000-0000-0000-0000-000000000001"), "When solving a problem, I focus on what's logical and objective rather than what feels right." },
                    { new Guid("00000000-0000-0000-0001-000000000012"), "TF_02_R", new DateTime(2026, 1, 1, 0, 0, 0, 0, DateTimeKind.Utc), 12, new Guid("00000000-0000-0000-0000-000000000001"), "I find it difficult to make a decision if I know it will upset someone close to me." },
                    { new Guid("00000000-0000-0000-0001-000000000013"), "TF_03", new DateTime(2026, 1, 1, 0, 0, 0, 0, DateTimeKind.Utc), 13, new Guid("00000000-0000-0000-0000-000000000001"), "I believe being fair and consistent matters more than making exceptions for individuals." },
                    { new Guid("00000000-0000-0000-0001-000000000014"), "TF_04_R", new DateTime(2026, 1, 1, 0, 0, 0, 0, DateTimeKind.Utc), 14, new Guid("00000000-0000-0000-0000-000000000001"), "I consider how my decisions will affect the feelings of the people involved." },
                    { new Guid("00000000-0000-0000-0001-000000000015"), "TF_05", new DateTime(2026, 1, 1, 0, 0, 0, 0, DateTimeKind.Utc), 15, new Guid("00000000-0000-0000-0000-000000000001"), "I prefer a well-reasoned argument over an emotional appeal when making up my mind." },
                    { new Guid("00000000-0000-0000-0001-000000000016"), "JP_01", new DateTime(2026, 1, 1, 0, 0, 0, 0, DateTimeKind.Utc), 16, new Guid("00000000-0000-0000-0000-000000000001"), "I like having a clear plan before I start a task." },
                    { new Guid("00000000-0000-0000-0001-000000000017"), "JP_02_R", new DateTime(2026, 1, 1, 0, 0, 0, 0, DateTimeKind.Utc), 17, new Guid("00000000-0000-0000-0000-000000000001"), "I prefer to keep my options open rather than committing to a fixed plan." },
                    { new Guid("00000000-0000-0000-0001-000000000018"), "JP_03", new DateTime(2026, 1, 1, 0, 0, 0, 0, DateTimeKind.Utc), 18, new Guid("00000000-0000-0000-0000-000000000001"), "I feel unsettled when plans change unexpectedly at the last minute." },
                    { new Guid("00000000-0000-0000-0001-000000000019"), "JP_04_R", new DateTime(2026, 1, 1, 0, 0, 0, 0, DateTimeKind.Utc), 19, new Guid("00000000-0000-0000-0000-000000000001"), "I often decide things at the last moment and feel perfectly comfortable doing so." },
                    { new Guid("00000000-0000-0000-0001-000000000020"), "JP_05", new DateTime(2026, 1, 1, 0, 0, 0, 0, DateTimeKind.Utc), 20, new Guid("00000000-0000-0000-0000-000000000001"), "I prefer to have things resolved and settled rather than leaving them open-ended." }
                });
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DeleteData(
                table: "Questions",
                keyColumn: "Id",
                keyValue: new Guid("00000000-0000-0000-0001-000000000001"));

            migrationBuilder.DeleteData(
                table: "Questions",
                keyColumn: "Id",
                keyValue: new Guid("00000000-0000-0000-0001-000000000002"));

            migrationBuilder.DeleteData(
                table: "Questions",
                keyColumn: "Id",
                keyValue: new Guid("00000000-0000-0000-0001-000000000003"));

            migrationBuilder.DeleteData(
                table: "Questions",
                keyColumn: "Id",
                keyValue: new Guid("00000000-0000-0000-0001-000000000004"));

            migrationBuilder.DeleteData(
                table: "Questions",
                keyColumn: "Id",
                keyValue: new Guid("00000000-0000-0000-0001-000000000005"));

            migrationBuilder.DeleteData(
                table: "Questions",
                keyColumn: "Id",
                keyValue: new Guid("00000000-0000-0000-0001-000000000006"));

            migrationBuilder.DeleteData(
                table: "Questions",
                keyColumn: "Id",
                keyValue: new Guid("00000000-0000-0000-0001-000000000007"));

            migrationBuilder.DeleteData(
                table: "Questions",
                keyColumn: "Id",
                keyValue: new Guid("00000000-0000-0000-0001-000000000008"));

            migrationBuilder.DeleteData(
                table: "Questions",
                keyColumn: "Id",
                keyValue: new Guid("00000000-0000-0000-0001-000000000009"));

            migrationBuilder.DeleteData(
                table: "Questions",
                keyColumn: "Id",
                keyValue: new Guid("00000000-0000-0000-0001-000000000010"));

            migrationBuilder.DeleteData(
                table: "Questions",
                keyColumn: "Id",
                keyValue: new Guid("00000000-0000-0000-0001-000000000011"));

            migrationBuilder.DeleteData(
                table: "Questions",
                keyColumn: "Id",
                keyValue: new Guid("00000000-0000-0000-0001-000000000012"));

            migrationBuilder.DeleteData(
                table: "Questions",
                keyColumn: "Id",
                keyValue: new Guid("00000000-0000-0000-0001-000000000013"));

            migrationBuilder.DeleteData(
                table: "Questions",
                keyColumn: "Id",
                keyValue: new Guid("00000000-0000-0000-0001-000000000014"));

            migrationBuilder.DeleteData(
                table: "Questions",
                keyColumn: "Id",
                keyValue: new Guid("00000000-0000-0000-0001-000000000015"));

            migrationBuilder.DeleteData(
                table: "Questions",
                keyColumn: "Id",
                keyValue: new Guid("00000000-0000-0000-0001-000000000016"));

            migrationBuilder.DeleteData(
                table: "Questions",
                keyColumn: "Id",
                keyValue: new Guid("00000000-0000-0000-0001-000000000017"));

            migrationBuilder.DeleteData(
                table: "Questions",
                keyColumn: "Id",
                keyValue: new Guid("00000000-0000-0000-0001-000000000018"));

            migrationBuilder.DeleteData(
                table: "Questions",
                keyColumn: "Id",
                keyValue: new Guid("00000000-0000-0000-0001-000000000019"));

            migrationBuilder.DeleteData(
                table: "Questions",
                keyColumn: "Id",
                keyValue: new Guid("00000000-0000-0000-0001-000000000020"));

            migrationBuilder.DeleteData(
                table: "Tests",
                keyColumn: "Id",
                keyValue: new Guid("00000000-0000-0000-0000-000000000001"));
        }
    }
}
