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
                table: "users",
                type: "uuid",
                nullable: true);

            migrationBuilder.AddColumn<DateTime>(
                name: "dateofbirth",
                table: "users",
                type: "timestamp with time zone",
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "domicile",
                table: "users",
                type: "text",
                nullable: true);

            // ── Questions: MindScore module/age-band columns ──────────────────
            migrationBuilder.AddColumn<Guid>(
                name: "agebandid",
                table: "questions",
                type: "uuid",
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "difficulty",
                table: "questions",
                type: "text",
                nullable: true);

            migrationBuilder.AddColumn<bool>(
                name: "isreversescored",
                table: "questions",
                type: "boolean",
                nullable: true);

            migrationBuilder.AddColumn<Guid>(
                name: "moduleid",
                table: "questions",
                type: "uuid",
                nullable: true);

            migrationBuilder.AddColumn<int>(
                name: "version",
                table: "questions",
                type: "integer",
                nullable: true);

            migrationBuilder.AddColumn<decimal>(
                name: "weight",
                table: "questions",
                type: "numeric",
                nullable: true);

            // ── Tests: rename to MindType Assessment ─────────────────────────
            migrationBuilder.UpdateData(
                table: "tests",
                keyColumn: "Id",
                keyValue: new Guid("00000000-0000-0000-0000-000000000001"),
                column: "Name",
                value: "MindType Assessment");

            // ── Indexes on new FK columns ─────────────────────────────────────
            migrationBuilder.CreateIndex(
                name: "IX_users_agebandid",
                table: "users",
                column: "agebandid");

            migrationBuilder.CreateIndex(
                name: "IX_questions_agebandid",
                table: "questions",
                column: "agebandid");

            migrationBuilder.CreateIndex(
                name: "IX_questions_moduleid",
                table: "questions",
                column: "moduleid");

            // ── FKs to pre-existing agebands / modules tables ─────────────────
            migrationBuilder.AddForeignKey(
                name: "FK_questions_agebands_agebandid",
                table: "questions",
                column: "agebandid",
                principalTable: "agebands",
                principalColumn: "id");

            migrationBuilder.AddForeignKey(
                name: "FK_questions_modules_moduleid",
                table: "questions",
                column: "moduleid",
                principalTable: "modules",
                principalColumn: "id");

            migrationBuilder.AddForeignKey(
                name: "FK_users_agebands_agebandid",
                table: "users",
                column: "agebandid",
                principalTable: "agebands",
                principalColumn: "id");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_questions_agebands_agebandid",
                table: "questions");

            migrationBuilder.DropForeignKey(
                name: "FK_questions_modules_moduleid",
                table: "questions");

            migrationBuilder.DropForeignKey(
                name: "FK_users_agebands_agebandid",
                table: "users");

            migrationBuilder.DropIndex(
                name: "IX_users_agebandid",
                table: "users");

            migrationBuilder.DropIndex(
                name: "IX_questions_agebandid",
                table: "questions");

            migrationBuilder.DropIndex(
                name: "IX_questions_moduleid",
                table: "questions");

            migrationBuilder.DropColumn(name: "agebandid",      table: "users");
            migrationBuilder.DropColumn(name: "dateofbirth",    table: "users");
            migrationBuilder.DropColumn(name: "domicile",       table: "users");

            migrationBuilder.DropColumn(name: "agebandid",      table: "questions");
            migrationBuilder.DropColumn(name: "difficulty",     table: "questions");
            migrationBuilder.DropColumn(name: "isreversescored",table: "questions");
            migrationBuilder.DropColumn(name: "moduleid",       table: "questions");
            migrationBuilder.DropColumn(name: "version",        table: "questions");
            migrationBuilder.DropColumn(name: "weight",         table: "questions");

            migrationBuilder.UpdateData(
                table: "tests",
                keyColumn: "Id",
                keyValue: new Guid("00000000-0000-0000-0000-000000000001"),
                column: "Name",
                value: "MPI Assessment");
        }
    }
}
