using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace MindScorePlatform.Infrastructure.Migrations
{
    /// <inheritdoc />
    public partial class AddMpiFieldsToResult : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<string>(
                name: "DimensionScoresJson",
                table: "Results",
                type: "text",
                nullable: false,
                defaultValue: "");

            migrationBuilder.AddColumn<string>(
                name: "InsightsJson",
                table: "Results",
                type: "text",
                nullable: false,
                defaultValue: "");

            migrationBuilder.AddColumn<string>(
                name: "PersonalityEmoji",
                table: "Results",
                type: "text",
                nullable: false,
                defaultValue: "");

            migrationBuilder.AddColumn<string>(
                name: "PersonalityName",
                table: "Results",
                type: "text",
                nullable: false,
                defaultValue: "");

            migrationBuilder.AddColumn<string>(
                name: "PersonalityTagline",
                table: "Results",
                type: "text",
                nullable: false,
                defaultValue: "");

            migrationBuilder.AddColumn<string>(
                name: "PersonalityType",
                table: "Results",
                type: "text",
                nullable: false,
                defaultValue: "");

            migrationBuilder.AddColumn<string>(
                name: "Code",
                table: "Questions",
                type: "text",
                nullable: false,
                defaultValue: "");

            migrationBuilder.CreateIndex(
                name: "IX_Questions_TestId_Code",
                table: "Questions",
                columns: new[] { "TestId", "Code" },
                unique: true);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropIndex(
                name: "IX_Questions_TestId_Code",
                table: "Questions");

            migrationBuilder.DropColumn(
                name: "DimensionScoresJson",
                table: "Results");

            migrationBuilder.DropColumn(
                name: "InsightsJson",
                table: "Results");

            migrationBuilder.DropColumn(
                name: "PersonalityEmoji",
                table: "Results");

            migrationBuilder.DropColumn(
                name: "PersonalityName",
                table: "Results");

            migrationBuilder.DropColumn(
                name: "PersonalityTagline",
                table: "Results");

            migrationBuilder.DropColumn(
                name: "PersonalityType",
                table: "Results");

            migrationBuilder.DropColumn(
                name: "Code",
                table: "Questions");
        }
    }
}
