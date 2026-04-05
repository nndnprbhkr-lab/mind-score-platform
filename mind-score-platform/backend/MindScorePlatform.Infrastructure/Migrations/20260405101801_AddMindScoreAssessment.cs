using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace MindScorePlatform.Infrastructure.Migrations
{
    /// <inheritdoc />
    public partial class AddMindScoreAssessment : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
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

            migrationBuilder.CreateTable(
                name: "age_band_module_weights",
                columns: table => new
                {
                    Id = table.Column<Guid>(type: "uuid", nullable: false),
                    agebandid = table.Column<Guid>(type: "uuid", nullable: false),
                    moduleid = table.Column<Guid>(type: "uuid", nullable: false),
                    weight = table.Column<double>(type: "double precision", nullable: false),
                    createdat = table.Column<DateTime>(type: "timestamp with time zone", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_age_band_module_weights", x => x.Id);
                    table.ForeignKey(
                        name: "FK_age_band_module_weights_agebands_agebandid",
                        column: x => x.agebandid,
                        principalTable: "agebands",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                    table.ForeignKey(
                        name: "FK_age_band_module_weights_modules_moduleid",
                        column: x => x.moduleid,
                        principalTable: "modules",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "norm_references",
                columns: table => new
                {
                    Id = table.Column<Guid>(type: "uuid", nullable: false),
                    moduleid = table.Column<Guid>(type: "uuid", nullable: false),
                    agebandid = table.Column<Guid>(type: "uuid", nullable: false),
                    mean = table.Column<double>(type: "double precision", nullable: false),
                    standarddeviation = table.Column<double>(type: "double precision", nullable: false),
                    samplesize = table.Column<int>(type: "integer", nullable: false),
                    createdat = table.Column<DateTime>(type: "timestamp with time zone", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_norm_references", x => x.Id);
                    table.ForeignKey(
                        name: "FK_norm_references_agebands_agebandid",
                        column: x => x.agebandid,
                        principalTable: "agebands",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                    table.ForeignKey(
                        name: "FK_norm_references_modules_moduleid",
                        column: x => x.moduleid,
                        principalTable: "modules",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.UpdateData(
                table: "Tests",
                keyColumn: "Id",
                keyValue: new Guid("00000000-0000-0000-0000-000000000001"),
                column: "Name",
                value: "MindType Assessment");

            migrationBuilder.CreateIndex(
                name: "IX_Users_agebandid",
                table: "Users",
                column: "agebandid");

            migrationBuilder.CreateIndex(
                name: "IX_age_band_module_weights_agebandid",
                table: "age_band_module_weights",
                column: "agebandid");

            migrationBuilder.CreateIndex(
                name: "IX_age_band_module_weights_moduleid",
                table: "age_band_module_weights",
                column: "moduleid");

            migrationBuilder.CreateIndex(
                name: "IX_norm_references_agebandid",
                table: "norm_references",
                column: "agebandid");

            migrationBuilder.CreateIndex(
                name: "IX_norm_references_moduleid",
                table: "norm_references",
                column: "moduleid");

            migrationBuilder.AddForeignKey(
                name: "FK_Users_agebands_agebandid",
                table: "Users",
                column: "agebandid",
                principalTable: "agebands",
                principalColumn: "Id");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_Users_agebands_agebandid",
                table: "Users");

            migrationBuilder.DropTable(
                name: "age_band_module_weights");

            migrationBuilder.DropTable(
                name: "norm_references");

            migrationBuilder.DropIndex(
                name: "IX_Users_agebandid",
                table: "Users");

            migrationBuilder.DropColumn(
                name: "agebandid",
                table: "Users");

            migrationBuilder.DropColumn(
                name: "dateofbirth",
                table: "Users");

            migrationBuilder.DropColumn(
                name: "domicile",
                table: "Users");

            migrationBuilder.UpdateData(
                table: "Tests",
                keyColumn: "Id",
                keyValue: new Guid("00000000-0000-0000-0000-000000000001"),
                column: "Name",
                value: "MPI Assessment");
        }
    }
}
