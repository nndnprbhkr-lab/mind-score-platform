using Microsoft.EntityFrameworkCore.Migrations;
using MindScorePlatform.Infrastructure.Persistence;

#nullable disable

namespace MindScorePlatform.Infrastructure.Migrations;

public partial class AddRelationshipDynamicsAssessment : Migration
{
    protected override void Up(MigrationBuilder migrationBuilder)
    {
        var testId = new Guid("00000000-0000-0000-0000-000000000004");

        // Insert test
        migrationBuilder.InsertData(
            table: "tests",
            columns: new[] { "id", "name", "createdatutc" },
            values: new object[] { testId, "Relationship Dynamics Assessment", new DateTime(2026, 1, 1, 0, 0, 0, DateTimeKind.Utc) }
        );

        // Insert 22 questions
        var questions = RelationshipDynamicsSeed.Questions;
        foreach (var q in questions)
        {
            migrationBuilder.InsertData(
                table: "questions",
                columns: new[] { "id", "testid", "code", "text", "questiontype", "isreversescored", "order", "agebandid", "contexttags" },
                values: new object[] { q.Id, testId, q.Code, q.Text, q.QuestionType, q.IsReverseScored ?? false, q.Order, null, null }
            );
        }
    }

    protected override void Down(MigrationBuilder migrationBuilder)
    {
        var testId = new Guid("00000000-0000-0000-0000-000000000004");

        // Delete questions
        migrationBuilder.DeleteData(
            table: "questions",
            keyColumn: "testid",
            keyValue: testId
        );

        // Delete test
        migrationBuilder.DeleteData(
            table: "tests",
            keyColumn: "id",
            keyValue: testId
        );
    }
}
