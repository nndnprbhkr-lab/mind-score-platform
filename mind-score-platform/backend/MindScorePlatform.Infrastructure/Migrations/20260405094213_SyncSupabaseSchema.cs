using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace MindScorePlatform.Infrastructure.Migrations
{
    /// <inheritdoc />
    public partial class SyncSupabaseSchema : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<Guid>(
                name: "agebandid",
                table: "Questions",
                type: "uuid",
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "difficulty",
                table: "Questions",
                type: "text",
                nullable: true);

            migrationBuilder.AddColumn<bool>(
                name: "isreversescored",
                table: "Questions",
                type: "boolean",
                nullable: true);

            migrationBuilder.AddColumn<Guid>(
                name: "moduleid",
                table: "Questions",
                type: "uuid",
                nullable: true);

            migrationBuilder.AddColumn<int>(
                name: "version",
                table: "Questions",
                type: "integer",
                nullable: true);

            migrationBuilder.AddColumn<decimal>(
                name: "weight",
                table: "Questions",
                type: "numeric",
                nullable: true);

            migrationBuilder.CreateIndex(
                name: "IX_Questions_agebandid",
                table: "Questions",
                column: "agebandid");

            migrationBuilder.CreateIndex(
                name: "IX_Questions_moduleid",
                table: "Questions",
                column: "moduleid");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropIndex(
                name: "IX_Questions_agebandid",
                table: "Questions");

            migrationBuilder.DropIndex(
                name: "IX_Questions_moduleid",
                table: "Questions");

            migrationBuilder.DropColumn(
                name: "agebandid",
                table: "Questions");

            migrationBuilder.DropColumn(
                name: "difficulty",
                table: "Questions");

            migrationBuilder.DropColumn(
                name: "isreversescored",
                table: "Questions");

            migrationBuilder.DropColumn(
                name: "moduleid",
                table: "Questions");

            migrationBuilder.DropColumn(
                name: "version",
                table: "Questions");

            migrationBuilder.DropColumn(
                name: "weight",
                table: "Questions");
        }
    }
}
