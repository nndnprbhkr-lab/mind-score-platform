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
            // ── Users: new profile columns ────────────────────────────────────
            migrationBuilder.AddColumn<Guid>(
                name: "agebandid",
                table: "Users",
                type: "uuid",
                nullable: true);

            migrationBuilder.AddColumn<DateTime>(
                name: "dateofbirth",
                table: "Users",
                type: "timestamp with time zone",
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "domicile",
                table: "Users",
                type: "text",
                nullable: true);

            // ── Questions: MindScore module/age-band columns ──────────────────
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

            // ── Tests: rename to MindType Assessment ─────────────────────────
            migrationBuilder.UpdateData(
                table: "Tests",
                keyColumn: "Id",
                keyValue: new Guid("00000000-0000-0000-0000-000000000001"),
                column: "Name",
                value: "MindType Assessment");

            // ── Indexes on new FK columns ─────────────────────────────────────
            migrationBuilder.CreateIndex(
                name: "IX_Users_agebandid",
                table: "Users",
                column: "agebandid");

            migrationBuilder.CreateIndex(
                name: "IX_Questions_agebandid",
                table: "Questions",
                column: "agebandid");

            migrationBuilder.CreateIndex(
                name: "IX_Questions_moduleid",
                table: "Questions",
                column: "moduleid");

            // ── FKs to pre-existing agebands / modules tables ─────────────────
            migrationBuilder.AddForeignKey(
                name: "FK_Questions_agebands_agebandid",
                table: "Questions",
                column: "agebandid",
                principalTable: "agebands",
                principalColumn: "id");

            migrationBuilder.AddForeignKey(
                name: "FK_Questions_modules_moduleid",
                table: "Questions",
                column: "moduleid",
                principalTable: "modules",
                principalColumn: "id");

            migrationBuilder.AddForeignKey(
                name: "FK_Users_agebands_agebandid",
                table: "Users",
                column: "agebandid",
                principalTable: "agebands",
                principalColumn: "id");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_Questions_agebands_agebandid",
                table: "Questions");

            migrationBuilder.DropForeignKey(
                name: "FK_Questions_modules_moduleid",
                table: "Questions");

            migrationBuilder.DropForeignKey(
                name: "FK_Users_agebands_agebandid",
                table: "Users");

            migrationBuilder.DropIndex(
                name: "IX_Users_agebandid",
                table: "Users");

            migrationBuilder.DropIndex(
                name: "IX_Questions_agebandid",
                table: "Questions");

            migrationBuilder.DropIndex(
                name: "IX_Questions_moduleid",
                table: "Questions");

            migrationBuilder.DropColumn(name: "agebandid",      table: "Users");
            migrationBuilder.DropColumn(name: "dateofbirth",    table: "Users");
            migrationBuilder.DropColumn(name: "domicile",       table: "Users");

            migrationBuilder.DropColumn(name: "agebandid",      table: "Questions");
            migrationBuilder.DropColumn(name: "difficulty",     table: "Questions");
            migrationBuilder.DropColumn(name: "isreversescored",table: "Questions");
            migrationBuilder.DropColumn(name: "moduleid",       table: "Questions");
            migrationBuilder.DropColumn(name: "version",        table: "Questions");
            migrationBuilder.DropColumn(name: "weight",         table: "Questions");

            migrationBuilder.UpdateData(
                table: "Tests",
                keyColumn: "Id",
                keyValue: new Guid("00000000-0000-0000-0000-000000000001"),
                column: "Name",
                value: "MPI Assessment");
        }
    }
}
