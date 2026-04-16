using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace MindScorePlatform.Infrastructure.Migrations
{
    /// <inheritdoc />
    public partial class FixContextQuestionOrders : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.UpdateData(
                table: "questions",
                keyColumn: "id",
                keyValue: new Guid("00000000-0000-0000-0002-000000000001"),
                column: "orderid",
                value: 500);

            migrationBuilder.UpdateData(
                table: "questions",
                keyColumn: "id",
                keyValue: new Guid("00000000-0000-0000-0002-000000000002"),
                column: "orderid",
                value: 501);

            migrationBuilder.UpdateData(
                table: "questions",
                keyColumn: "id",
                keyValue: new Guid("00000000-0000-0000-0002-000000000003"),
                column: "orderid",
                value: 502);

            migrationBuilder.UpdateData(
                table: "questions",
                keyColumn: "id",
                keyValue: new Guid("00000000-0000-0000-0002-000000000004"),
                column: "orderid",
                value: 503);

            migrationBuilder.UpdateData(
                table: "questions",
                keyColumn: "id",
                keyValue: new Guid("00000000-0000-0000-0002-000000000005"),
                column: "orderid",
                value: 21);

            migrationBuilder.UpdateData(
                table: "questions",
                keyColumn: "id",
                keyValue: new Guid("00000000-0000-0000-0002-000000000006"),
                column: "orderid",
                value: 22);

            migrationBuilder.UpdateData(
                table: "questions",
                keyColumn: "id",
                keyValue: new Guid("00000000-0000-0000-0002-000000000007"),
                column: "orderid",
                value: 23);

            migrationBuilder.UpdateData(
                table: "questions",
                keyColumn: "id",
                keyValue: new Guid("00000000-0000-0000-0002-000000000008"),
                column: "orderid",
                value: 24);

            migrationBuilder.UpdateData(
                table: "questions",
                keyColumn: "id",
                keyValue: new Guid("00000000-0000-0000-0002-000000000009"),
                column: "orderid",
                value: 25);

            migrationBuilder.UpdateData(
                table: "questions",
                keyColumn: "id",
                keyValue: new Guid("00000000-0000-0000-0002-000000000010"),
                column: "orderid",
                value: 26);

            migrationBuilder.UpdateData(
                table: "questions",
                keyColumn: "id",
                keyValue: new Guid("00000000-0000-0000-0002-000000000011"),
                column: "orderid",
                value: 30);

            migrationBuilder.UpdateData(
                table: "questions",
                keyColumn: "id",
                keyValue: new Guid("00000000-0000-0000-0002-000000000012"),
                column: "orderid",
                value: 31);

            migrationBuilder.UpdateData(
                table: "questions",
                keyColumn: "id",
                keyValue: new Guid("00000000-0000-0000-0002-000000000013"),
                column: "orderid",
                value: 32);

            migrationBuilder.UpdateData(
                table: "questions",
                keyColumn: "id",
                keyValue: new Guid("00000000-0000-0000-0002-000000000014"),
                column: "orderid",
                value: 33);

            migrationBuilder.UpdateData(
                table: "questions",
                keyColumn: "id",
                keyValue: new Guid("00000000-0000-0000-0002-000000000015"),
                column: "orderid",
                value: 34);

            migrationBuilder.UpdateData(
                table: "questions",
                keyColumn: "id",
                keyValue: new Guid("00000000-0000-0000-0002-000000000016"),
                column: "orderid",
                value: 35);

            migrationBuilder.UpdateData(
                table: "questions",
                keyColumn: "id",
                keyValue: new Guid("00000000-0000-0000-0002-000000000017"),
                column: "orderid",
                value: 40);

            migrationBuilder.UpdateData(
                table: "questions",
                keyColumn: "id",
                keyValue: new Guid("00000000-0000-0000-0002-000000000018"),
                column: "orderid",
                value: 41);

            migrationBuilder.UpdateData(
                table: "questions",
                keyColumn: "id",
                keyValue: new Guid("00000000-0000-0000-0002-000000000019"),
                column: "orderid",
                value: 42);

            migrationBuilder.UpdateData(
                table: "questions",
                keyColumn: "id",
                keyValue: new Guid("00000000-0000-0000-0002-000000000020"),
                column: "orderid",
                value: 43);

            migrationBuilder.UpdateData(
                table: "questions",
                keyColumn: "id",
                keyValue: new Guid("00000000-0000-0000-0002-000000000021"),
                column: "orderid",
                value: 44);

            migrationBuilder.UpdateData(
                table: "questions",
                keyColumn: "id",
                keyValue: new Guid("00000000-0000-0000-0002-000000000022"),
                column: "orderid",
                value: 45);

            migrationBuilder.UpdateData(
                table: "questions",
                keyColumn: "id",
                keyValue: new Guid("00000000-0000-0000-0002-000000000023"),
                column: "orderid",
                value: 50);

            migrationBuilder.UpdateData(
                table: "questions",
                keyColumn: "id",
                keyValue: new Guid("00000000-0000-0000-0002-000000000024"),
                column: "orderid",
                value: 51);

            migrationBuilder.UpdateData(
                table: "questions",
                keyColumn: "id",
                keyValue: new Guid("00000000-0000-0000-0002-000000000025"),
                column: "orderid",
                value: 52);

            migrationBuilder.UpdateData(
                table: "questions",
                keyColumn: "id",
                keyValue: new Guid("00000000-0000-0000-0002-000000000026"),
                column: "orderid",
                value: 53);

            migrationBuilder.UpdateData(
                table: "questions",
                keyColumn: "id",
                keyValue: new Guid("00000000-0000-0000-0002-000000000027"),
                column: "orderid",
                value: 54);

            migrationBuilder.UpdateData(
                table: "questions",
                keyColumn: "id",
                keyValue: new Guid("00000000-0000-0000-0002-000000000028"),
                column: "orderid",
                value: 55);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.UpdateData(
                table: "questions",
                keyColumn: "id",
                keyValue: new Guid("00000000-0000-0000-0002-000000000001"),
                column: "orderid",
                value: 21);

            migrationBuilder.UpdateData(
                table: "questions",
                keyColumn: "id",
                keyValue: new Guid("00000000-0000-0000-0002-000000000002"),
                column: "orderid",
                value: 22);

            migrationBuilder.UpdateData(
                table: "questions",
                keyColumn: "id",
                keyValue: new Guid("00000000-0000-0000-0002-000000000003"),
                column: "orderid",
                value: 23);

            migrationBuilder.UpdateData(
                table: "questions",
                keyColumn: "id",
                keyValue: new Guid("00000000-0000-0000-0002-000000000004"),
                column: "orderid",
                value: 24);

            migrationBuilder.UpdateData(
                table: "questions",
                keyColumn: "id",
                keyValue: new Guid("00000000-0000-0000-0002-000000000005"),
                column: "orderid",
                value: 100);

            migrationBuilder.UpdateData(
                table: "questions",
                keyColumn: "id",
                keyValue: new Guid("00000000-0000-0000-0002-000000000006"),
                column: "orderid",
                value: 101);

            migrationBuilder.UpdateData(
                table: "questions",
                keyColumn: "id",
                keyValue: new Guid("00000000-0000-0000-0002-000000000007"),
                column: "orderid",
                value: 102);

            migrationBuilder.UpdateData(
                table: "questions",
                keyColumn: "id",
                keyValue: new Guid("00000000-0000-0000-0002-000000000008"),
                column: "orderid",
                value: 103);

            migrationBuilder.UpdateData(
                table: "questions",
                keyColumn: "id",
                keyValue: new Guid("00000000-0000-0000-0002-000000000009"),
                column: "orderid",
                value: 104);

            migrationBuilder.UpdateData(
                table: "questions",
                keyColumn: "id",
                keyValue: new Guid("00000000-0000-0000-0002-000000000010"),
                column: "orderid",
                value: 105);

            migrationBuilder.UpdateData(
                table: "questions",
                keyColumn: "id",
                keyValue: new Guid("00000000-0000-0000-0002-000000000011"),
                column: "orderid",
                value: 110);

            migrationBuilder.UpdateData(
                table: "questions",
                keyColumn: "id",
                keyValue: new Guid("00000000-0000-0000-0002-000000000012"),
                column: "orderid",
                value: 111);

            migrationBuilder.UpdateData(
                table: "questions",
                keyColumn: "id",
                keyValue: new Guid("00000000-0000-0000-0002-000000000013"),
                column: "orderid",
                value: 112);

            migrationBuilder.UpdateData(
                table: "questions",
                keyColumn: "id",
                keyValue: new Guid("00000000-0000-0000-0002-000000000014"),
                column: "orderid",
                value: 113);

            migrationBuilder.UpdateData(
                table: "questions",
                keyColumn: "id",
                keyValue: new Guid("00000000-0000-0000-0002-000000000015"),
                column: "orderid",
                value: 114);

            migrationBuilder.UpdateData(
                table: "questions",
                keyColumn: "id",
                keyValue: new Guid("00000000-0000-0000-0002-000000000016"),
                column: "orderid",
                value: 115);

            migrationBuilder.UpdateData(
                table: "questions",
                keyColumn: "id",
                keyValue: new Guid("00000000-0000-0000-0002-000000000017"),
                column: "orderid",
                value: 120);

            migrationBuilder.UpdateData(
                table: "questions",
                keyColumn: "id",
                keyValue: new Guid("00000000-0000-0000-0002-000000000018"),
                column: "orderid",
                value: 121);

            migrationBuilder.UpdateData(
                table: "questions",
                keyColumn: "id",
                keyValue: new Guid("00000000-0000-0000-0002-000000000019"),
                column: "orderid",
                value: 122);

            migrationBuilder.UpdateData(
                table: "questions",
                keyColumn: "id",
                keyValue: new Guid("00000000-0000-0000-0002-000000000020"),
                column: "orderid",
                value: 123);

            migrationBuilder.UpdateData(
                table: "questions",
                keyColumn: "id",
                keyValue: new Guid("00000000-0000-0000-0002-000000000021"),
                column: "orderid",
                value: 124);

            migrationBuilder.UpdateData(
                table: "questions",
                keyColumn: "id",
                keyValue: new Guid("00000000-0000-0000-0002-000000000022"),
                column: "orderid",
                value: 125);

            migrationBuilder.UpdateData(
                table: "questions",
                keyColumn: "id",
                keyValue: new Guid("00000000-0000-0000-0002-000000000023"),
                column: "orderid",
                value: 130);

            migrationBuilder.UpdateData(
                table: "questions",
                keyColumn: "id",
                keyValue: new Guid("00000000-0000-0000-0002-000000000024"),
                column: "orderid",
                value: 131);

            migrationBuilder.UpdateData(
                table: "questions",
                keyColumn: "id",
                keyValue: new Guid("00000000-0000-0000-0002-000000000025"),
                column: "orderid",
                value: 132);

            migrationBuilder.UpdateData(
                table: "questions",
                keyColumn: "id",
                keyValue: new Guid("00000000-0000-0000-0002-000000000026"),
                column: "orderid",
                value: 133);

            migrationBuilder.UpdateData(
                table: "questions",
                keyColumn: "id",
                keyValue: new Guid("00000000-0000-0000-0002-000000000027"),
                column: "orderid",
                value: 134);

            migrationBuilder.UpdateData(
                table: "questions",
                keyColumn: "id",
                keyValue: new Guid("00000000-0000-0000-0002-000000000028"),
                column: "orderid",
                value: 135);
        }
    }
}
