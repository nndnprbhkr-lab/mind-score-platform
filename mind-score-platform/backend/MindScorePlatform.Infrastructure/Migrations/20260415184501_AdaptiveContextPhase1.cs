using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace MindScorePlatform.Infrastructure.Migrations
{
    /// <inheritdoc />
    public partial class AdaptiveContextPhase1 : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            // IX_users_agebandid was already created lowercase in SyncSupabaseSchema — no rename needed.
            // IX_Questions_* were created with PascalCase Q and need lowercasing for consistency.
            migrationBuilder.RenameIndex(
                name: "IX_Questions_moduleid",
                table: "questions",
                newName: "IX_questions_moduleid");

            migrationBuilder.RenameIndex(
                name: "IX_Questions_agebandid",
                table: "questions",
                newName: "IX_questions_agebandid");

            migrationBuilder.AddColumn<string>(
                name: "adaptivepathjson",
                table: "results",
                type: "text",
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "aifollowupjson",
                table: "results",
                type: "text",
                nullable: true);

            migrationBuilder.AddColumn<int>(
                name: "context",
                table: "results",
                type: "integer",
                nullable: false,
                defaultValue: 0);

            migrationBuilder.AddColumn<string>(
                name: "contextinsightsjson",
                table: "results",
                type: "text",
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "dimensionconfidencejson",
                table: "results",
                type: "text",
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "branchingrulesjson",
                table: "questions",
                type: "text",
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "contexttagsjson",
                table: "questions",
                type: "text",
                nullable: true);

            migrationBuilder.AddColumn<int>(
                name: "questiontype",
                table: "questions",
                type: "integer",
                nullable: false,
                defaultValue: 0);

            migrationBuilder.AddColumn<string>(
                name: "scenariooptionsjson",
                table: "questions",
                type: "text",
                nullable: true);

            migrationBuilder.UpdateData(
                table: "questions",
                keyColumn: "id",
                keyValue: new Guid("00000000-0000-0000-0001-000000000001"),
                columns: new[] { "branchingrulesjson", "contexttagsjson", "scenariooptionsjson" },
                values: new object[] { null, null, null });

            migrationBuilder.UpdateData(
                table: "questions",
                keyColumn: "id",
                keyValue: new Guid("00000000-0000-0000-0001-000000000002"),
                columns: new[] { "branchingrulesjson", "contexttagsjson", "scenariooptionsjson" },
                values: new object[] { null, null, null });

            migrationBuilder.UpdateData(
                table: "questions",
                keyColumn: "id",
                keyValue: new Guid("00000000-0000-0000-0001-000000000003"),
                columns: new[] { "branchingrulesjson", "contexttagsjson", "scenariooptionsjson" },
                values: new object[] { null, null, null });

            migrationBuilder.UpdateData(
                table: "questions",
                keyColumn: "id",
                keyValue: new Guid("00000000-0000-0000-0001-000000000004"),
                columns: new[] { "branchingrulesjson", "contexttagsjson", "scenariooptionsjson" },
                values: new object[] { null, null, null });

            migrationBuilder.UpdateData(
                table: "questions",
                keyColumn: "id",
                keyValue: new Guid("00000000-0000-0000-0001-000000000005"),
                columns: new[] { "branchingrulesjson", "contexttagsjson", "scenariooptionsjson" },
                values: new object[] { null, null, null });

            migrationBuilder.UpdateData(
                table: "questions",
                keyColumn: "id",
                keyValue: new Guid("00000000-0000-0000-0001-000000000006"),
                columns: new[] { "branchingrulesjson", "contexttagsjson", "scenariooptionsjson" },
                values: new object[] { null, null, null });

            migrationBuilder.UpdateData(
                table: "questions",
                keyColumn: "id",
                keyValue: new Guid("00000000-0000-0000-0001-000000000007"),
                columns: new[] { "branchingrulesjson", "contexttagsjson", "scenariooptionsjson" },
                values: new object[] { null, null, null });

            migrationBuilder.UpdateData(
                table: "questions",
                keyColumn: "id",
                keyValue: new Guid("00000000-0000-0000-0001-000000000008"),
                columns: new[] { "branchingrulesjson", "contexttagsjson", "scenariooptionsjson" },
                values: new object[] { null, null, null });

            migrationBuilder.UpdateData(
                table: "questions",
                keyColumn: "id",
                keyValue: new Guid("00000000-0000-0000-0001-000000000009"),
                columns: new[] { "branchingrulesjson", "contexttagsjson", "scenariooptionsjson" },
                values: new object[] { null, null, null });

            migrationBuilder.UpdateData(
                table: "questions",
                keyColumn: "id",
                keyValue: new Guid("00000000-0000-0000-0001-000000000010"),
                columns: new[] { "branchingrulesjson", "contexttagsjson", "scenariooptionsjson" },
                values: new object[] { null, null, null });

            migrationBuilder.UpdateData(
                table: "questions",
                keyColumn: "id",
                keyValue: new Guid("00000000-0000-0000-0001-000000000011"),
                columns: new[] { "branchingrulesjson", "contexttagsjson", "scenariooptionsjson" },
                values: new object[] { null, null, null });

            migrationBuilder.UpdateData(
                table: "questions",
                keyColumn: "id",
                keyValue: new Guid("00000000-0000-0000-0001-000000000012"),
                columns: new[] { "branchingrulesjson", "contexttagsjson", "scenariooptionsjson" },
                values: new object[] { null, null, null });

            migrationBuilder.UpdateData(
                table: "questions",
                keyColumn: "id",
                keyValue: new Guid("00000000-0000-0000-0001-000000000013"),
                columns: new[] { "branchingrulesjson", "contexttagsjson", "scenariooptionsjson" },
                values: new object[] { null, null, null });

            migrationBuilder.UpdateData(
                table: "questions",
                keyColumn: "id",
                keyValue: new Guid("00000000-0000-0000-0001-000000000014"),
                columns: new[] { "branchingrulesjson", "contexttagsjson", "scenariooptionsjson" },
                values: new object[] { null, null, null });

            migrationBuilder.UpdateData(
                table: "questions",
                keyColumn: "id",
                keyValue: new Guid("00000000-0000-0000-0001-000000000015"),
                columns: new[] { "branchingrulesjson", "contexttagsjson", "scenariooptionsjson" },
                values: new object[] { null, null, null });

            migrationBuilder.UpdateData(
                table: "questions",
                keyColumn: "id",
                keyValue: new Guid("00000000-0000-0000-0001-000000000016"),
                columns: new[] { "branchingrulesjson", "contexttagsjson", "scenariooptionsjson" },
                values: new object[] { null, null, null });

            migrationBuilder.UpdateData(
                table: "questions",
                keyColumn: "id",
                keyValue: new Guid("00000000-0000-0000-0001-000000000017"),
                columns: new[] { "branchingrulesjson", "contexttagsjson", "scenariooptionsjson" },
                values: new object[] { null, null, null });

            migrationBuilder.UpdateData(
                table: "questions",
                keyColumn: "id",
                keyValue: new Guid("00000000-0000-0000-0001-000000000018"),
                columns: new[] { "branchingrulesjson", "contexttagsjson", "scenariooptionsjson" },
                values: new object[] { null, null, null });

            migrationBuilder.UpdateData(
                table: "questions",
                keyColumn: "id",
                keyValue: new Guid("00000000-0000-0000-0001-000000000019"),
                columns: new[] { "branchingrulesjson", "contexttagsjson", "scenariooptionsjson" },
                values: new object[] { null, null, null });

            migrationBuilder.UpdateData(
                table: "questions",
                keyColumn: "id",
                keyValue: new Guid("00000000-0000-0000-0001-000000000020"),
                columns: new[] { "branchingrulesjson", "contexttagsjson", "scenariooptionsjson" },
                values: new object[] { null, null, null });
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "adaptivepathjson",
                table: "results");

            migrationBuilder.DropColumn(
                name: "aifollowupjson",
                table: "results");

            migrationBuilder.DropColumn(
                name: "context",
                table: "results");

            migrationBuilder.DropColumn(
                name: "contextinsightsjson",
                table: "results");

            migrationBuilder.DropColumn(
                name: "dimensionconfidencejson",
                table: "results");

            migrationBuilder.DropColumn(
                name: "branchingrulesjson",
                table: "questions");

            migrationBuilder.DropColumn(
                name: "contexttagsjson",
                table: "questions");

            migrationBuilder.DropColumn(
                name: "questiontype",
                table: "questions");

            migrationBuilder.DropColumn(
                name: "scenariooptionsjson",
                table: "questions");

            migrationBuilder.RenameIndex(
                name: "IX_questions_moduleid",
                table: "questions",
                newName: "IX_Questions_moduleid");

            migrationBuilder.RenameIndex(
                name: "IX_questions_agebandid",
                table: "questions",
                newName: "IX_Questions_agebandid");
        }
    }
}
