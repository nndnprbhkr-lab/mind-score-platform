using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

#pragma warning disable CA1814 // Prefer jagged arrays over multidimensional

namespace MindScorePlatform.Infrastructure.Migrations
{
    /// <inheritdoc />
    public partial class AddCareerFitAssessment : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.InsertData(
                table: "questions",
                columns: new[] { "id", "agebandid", "branchingrulesjson", "code", "contexttagsjson", "createdatutc", "difficulty", "isreversescored", "moduleid", "orderid", "questiontype", "scenariooptionsjson", "testid", "text", "version", "weight" },
                values: new object[,]
                {
                    { new Guid("00000000-0000-0000-0003-000000000001"), null, null, "CF_01", null, new DateTime(2026, 1, 1, 0, 0, 0, 0, DateTimeKind.Utc), null, null, null, 1, 1, "[{\"text\":\"Building something concrete \\u2014 a product, system, or solution that works.\",\"clusterImpact\":{\"BUILDER\":5,\"OPERATOR\":2}},{\"text\":\"Digging into data and uncovering insights that inform strategy.\",\"clusterImpact\":{\"ANALYST\":5,\"OPERATOR\":2}},{\"text\":\"Leading people toward a shared goal and watching them grow.\",\"clusterImpact\":{\"LEADER\":5,\"COMMUNICATOR\":2}},{\"text\":\"Creating something original that changes how people feel or think.\",\"clusterImpact\":{\"CREATOR\":5,\"ENTREPRENEUR\":2}}]", new Guid("00000000-0000-0000-0000-000000000002"), "Your ideal work setup energises you most when you are...", null, null },
                    { new Guid("00000000-0000-0000-0003-000000000002"), null, null, "CF_02", null, new DateTime(2026, 1, 1, 0, 0, 0, 0, DateTimeKind.Utc), null, null, null, 2, 1, "[{\"text\":\"Dive in, experiment, and iterate fast.\",\"clusterImpact\":{\"ENTREPRENEUR\":5,\"BUILDER\":3}},{\"text\":\"Research thoroughly before committing to a direction.\",\"clusterImpact\":{\"ANALYST\":5,\"OPERATOR\":3}},{\"text\":\"Rally the team and divide responsibilities across people.\",\"clusterImpact\":{\"LEADER\":5,\"COMMUNICATOR\":3}},{\"text\":\"Consider carefully how it will affect the people involved.\",\"clusterImpact\":{\"CAREGIVER\":5,\"COMMUNICATOR\":2}}]", new Guid("00000000-0000-0000-0000-000000000002"), "When a brand-new challenge lands on your desk, your first instinct is to...", null, null },
                    { new Guid("00000000-0000-0000-0003-000000000003"), null, null, "CF_03", null, new DateTime(2026, 1, 1, 0, 0, 0, 0, DateTimeKind.Utc), null, null, null, 3, 1, "[{\"text\":\"Shipping a product or system that millions of people rely on every day.\",\"clusterImpact\":{\"BUILDER\":5,\"OPERATOR\":2}},{\"text\":\"Discovering an insight that completely changed a strategy or market.\",\"clusterImpact\":{\"ANALYST\":5,\"ENTREPRENEUR\":3}},{\"text\":\"Watching someone you mentored become a leader in their own right.\",\"clusterImpact\":{\"CAREGIVER\":5,\"LEADER\":4}},{\"text\":\"Creating a piece of work that shifted culture or moved public opinion.\",\"clusterImpact\":{\"CREATOR\":5,\"COMMUNICATOR\":3}}]", new Guid("00000000-0000-0000-0000-000000000002"), "The achievement that would make you most proud is...", null, null },
                    { new Guid("00000000-0000-0000-0003-000000000004"), null, null, "CF_04", null, new DateTime(2026, 1, 1, 0, 0, 0, 0, DateTimeKind.Utc), null, null, null, 4, 1, "[{\"text\":\"Built, shipped, or fixed something real and tangible.\",\"clusterImpact\":{\"BUILDER\":5,\"OPERATOR\":2}},{\"text\":\"Solved a complex puzzle or learned something genuinely unexpected.\",\"clusterImpact\":{\"ANALYST\":5,\"CREATOR\":2}},{\"text\":\"Helped someone navigate a genuinely difficult situation.\",\"clusterImpact\":{\"CAREGIVER\":5,\"COMMUNICATOR\":3}},{\"text\":\"Inspired a room, closed a deal, or led a high-stakes conversation.\",\"clusterImpact\":{\"COMMUNICATOR\":5,\"LEADER\":3}}]", new Guid("00000000-0000-0000-0000-000000000002"), "At the end of a great workday, you feel best when you have...", null, null },
                    { new Guid("00000000-0000-0000-0003-000000000005"), null, null, "CF_05", null, new DateTime(2026, 1, 1, 0, 0, 0, 0, DateTimeKind.Utc), null, null, null, 5, 1, "[{\"text\":\"Engineer a technical workaround or a creative patch.\",\"clusterImpact\":{\"BUILDER\":5,\"ANALYST\":3}},{\"text\":\"Step up, make a call, and rally everyone forward.\",\"clusterImpact\":{\"LEADER\":5,\"ENTREPRENEUR\":4}},{\"text\":\"Uncover the human issue that is really blocking progress.\",\"clusterImpact\":{\"CAREGIVER\":5,\"COMMUNICATOR\":3}},{\"text\":\"Throw out the old plan and reimagine the approach entirely.\",\"clusterImpact\":{\"CREATOR\":5,\"ENTREPRENEUR\":3}}]", new Guid("00000000-0000-0000-0000-000000000002"), "When your team hits a serious roadblock, you tend to...", null, null },
                    { new Guid("00000000-0000-0000-0003-000000000006"), null, null, "CF_06", null, new DateTime(2026, 1, 1, 0, 0, 0, 0, DateTimeKind.Utc), null, null, null, 6, 1, "[{\"text\":\"Trust the data \\u2014 you build models and pressure-test options first.\",\"clusterImpact\":{\"ANALYST\":5,\"OPERATOR\":3}},{\"text\":\"Trust your gut and move before the picture is fully clear.\",\"clusterImpact\":{\"ENTREPRENEUR\":5,\"CREATOR\":3}},{\"text\":\"Build consensus \\u2014 a decision everyone owns beats a perfect top-down call.\",\"clusterImpact\":{\"LEADER\":5,\"CAREGIVER\":3}},{\"text\":\"Filter through values \\u2014 what is right, not just what is optimal.\",\"clusterImpact\":{\"CAREGIVER\":5,\"COMMUNICATOR\":2}}]", new Guid("00000000-0000-0000-0000-000000000002"), "When it comes to making important decisions, you typically...", null, null },
                    { new Guid("00000000-0000-0000-0003-000000000007"), null, null, "CF_07", null, new DateTime(2026, 1, 1, 0, 0, 0, 0, DateTimeKind.Utc), null, null, null, 7, 1, "[{\"text\":\"Designing and building a complex technical system from scratch.\",\"clusterImpact\":{\"BUILDER\":5,\"ANALYST\":3}},{\"text\":\"Launching a brand-new business or product from zero to market.\",\"clusterImpact\":{\"ENTREPRENEUR\":5,\"CREATOR\":3}},{\"text\":\"Coaching a high-potential team to peak performance.\",\"clusterImpact\":{\"LEADER\":5,\"CAREGIVER\":4}},{\"text\":\"Creating a product experience that genuinely delights people.\",\"clusterImpact\":{\"CREATOR\":5,\"BUILDER\":3}}]", new Guid("00000000-0000-0000-0000-000000000002"), "If you could pick your next project, your dream would be...", null, null },
                    { new Guid("00000000-0000-0000-0003-000000000008"), null, null, "CF_08", null, new DateTime(2026, 1, 1, 0, 0, 0, 0, DateTimeKind.Utc), null, null, null, 8, 1, "[{\"text\":\"Follow structured plans and resist unscheduled interruptions.\",\"clusterImpact\":{\"OPERATOR\":5,\"ANALYST\":3}},{\"text\":\"Stay fluid and re-prioritise constantly based on what matters most right now.\",\"clusterImpact\":{\"ENTREPRENEUR\":5,\"LEADER\":3}},{\"text\":\"Block long stretches for deep, uninterrupted thinking.\",\"clusterImpact\":{\"ANALYST\":5,\"BUILDER\":4}},{\"text\":\"Leave room for spontaneous collaboration and idea exchange.\",\"clusterImpact\":{\"COMMUNICATOR\":5,\"CREATOR\":3}}]", new Guid("00000000-0000-0000-0000-000000000002"), "When managing your time and workflow, you...", null, null },
                    { new Guid("00000000-0000-0000-0003-000000000009"), null, null, "CF_09", null, new DateTime(2026, 1, 1, 0, 0, 0, 0, DateTimeKind.Utc), null, null, null, 9, 1, "[{\"text\":\"Diagnose the root cause systematically before touching anything.\",\"clusterImpact\":{\"ANALYST\":5,\"BUILDER\":3}},{\"text\":\"Build a fix fast and put safeguards in place to prevent recurrence.\",\"clusterImpact\":{\"BUILDER\":5,\"OPERATOR\":4}},{\"text\":\"Coordinate the response \\u2014 communicate, assign roles, manage stakeholders.\",\"clusterImpact\":{\"LEADER\":5,\"COMMUNICATOR\":3}},{\"text\":\"Focus first on the people impacted and how to make things right for them.\",\"clusterImpact\":{\"CAREGIVER\":5,\"COMMUNICATOR\":3}}]", new Guid("00000000-0000-0000-0000-000000000002"), "When something fails or breaks badly at work, you...", null, null },
                    { new Guid("00000000-0000-0000-0003-000000000010"), null, null, "CF_10", null, new DateTime(2026, 1, 1, 0, 0, 0, 0, DateTimeKind.Utc), null, null, null, 10, 1, "[{\"text\":\"Infrastructure or systems that scale and outlast their creator.\",\"clusterImpact\":{\"BUILDER\":5,\"OPERATOR\":3}},{\"text\":\"Revenue growth, market leadership, or a thriving business.\",\"clusterImpact\":{\"ENTREPRENEUR\":5,\"ANALYST\":2}},{\"text\":\"Improving someone\\u0027s health, confidence, or life trajectory.\",\"clusterImpact\":{\"CAREGIVER\":5,\"COMMUNICATOR\":3}},{\"text\":\"Shifting how people think, feel, or experience the world around them.\",\"clusterImpact\":{\"CREATOR\":5,\"COMMUNICATOR\":4}}]", new Guid("00000000-0000-0000-0000-000000000002"), "The type of impact you care most about creating is...", null, null },
                    { new Guid("00000000-0000-0000-0003-000000000011"), null, null, "CF_11", null, new DateTime(2026, 1, 1, 0, 0, 0, 0, DateTimeKind.Utc), null, null, null, 11, 1, "[{\"text\":\"Study documentation, research, and theory before taking action.\",\"clusterImpact\":{\"ANALYST\":5,\"OPERATOR\":3}},{\"text\":\"Jump in and learn entirely by doing \\u2014 mistakes included.\",\"clusterImpact\":{\"BUILDER\":5,\"ENTREPRENEUR\":4}},{\"text\":\"Watch an expert do it, then teach it to someone else to lock it in.\",\"clusterImpact\":{\"COMMUNICATOR\":5,\"LEADER\":3}},{\"text\":\"Learn alongside a mentor who gives real-time personalised feedback.\",\"clusterImpact\":{\"CAREGIVER\":3,\"LEADER\":3,\"COMMUNICATOR\":4}}]", new Guid("00000000-0000-0000-0000-000000000002"), "When learning something completely new, you prefer to...", null, null },
                    { new Guid("00000000-0000-0000-0003-000000000012"), null, null, "CF_12", null, new DateTime(2026, 1, 1, 0, 0, 0, 0, DateTimeKind.Utc), null, null, null, 12, 1, "[{\"text\":\"Map out a clear plan with milestones, owners, and dependencies.\",\"clusterImpact\":{\"OPERATOR\":5,\"LEADER\":3}},{\"text\":\"Find the fastest path to delivering real value, even imperfectly.\",\"clusterImpact\":{\"ENTREPRENEUR\":5,\"BUILDER\":3}},{\"text\":\"Explore creative angles others have not considered yet.\",\"clusterImpact\":{\"CREATOR\":5,\"ENTREPRENEUR\":3}},{\"text\":\"Identify who you need and build a support network around the goal.\",\"clusterImpact\":{\"LEADER\":5,\"CAREGIVER\":3}}]", new Guid("00000000-0000-0000-0000-000000000002"), "When handed a significant new responsibility, your first move is to...", null, null },
                    { new Guid("00000000-0000-0000-0003-000000000013"), null, null, "CF_13", null, new DateTime(2026, 1, 1, 0, 0, 0, 0, DateTimeKind.Utc), null, null, null, 13, 1, "[{\"text\":\"Excited \\u2014 where there is risk, there is opportunity worth seizing.\",\"clusterImpact\":{\"ENTREPRENEUR\":5,\"CREATOR\":3}},{\"text\":\"Focused \\u2014 you model the downside and reduce it systematically.\",\"clusterImpact\":{\"ANALYST\":5,\"OPERATOR\":4}},{\"text\":\"Responsible \\u2014 your priority is protecting the people involved.\",\"clusterImpact\":{\"CAREGIVER\":5,\"LEADER\":2}},{\"text\":\"Curious \\u2014 you see it as a creative problem waiting to be reframed.\",\"clusterImpact\":{\"CREATOR\":5,\"ENTREPRENEUR\":2}}]", new Guid("00000000-0000-0000-0000-000000000002"), "Risk and uncertainty at work make you feel...", null, null },
                    { new Guid("00000000-0000-0000-0003-000000000014"), null, null, "CF_14", null, new DateTime(2026, 1, 1, 0, 0, 0, 0, DateTimeKind.Utc), null, null, null, 14, 1, "[{\"text\":\"Pair up with them to debug or solve the technical challenge together.\",\"clusterImpact\":{\"BUILDER\":5,\"ANALYST\":3}},{\"text\":\"Sit with them, listen deeply, and offer genuine emotional support.\",\"clusterImpact\":{\"CAREGIVER\":5,\"COMMUNICATOR\":3}},{\"text\":\"Connect them to someone better positioned to help solve the problem.\",\"clusterImpact\":{\"COMMUNICATOR\":5,\"LEADER\":3}},{\"text\":\"Step in, take ownership of the situation, and drive it to resolution.\",\"clusterImpact\":{\"LEADER\":5,\"ENTREPRENEUR\":3}}]", new Guid("00000000-0000-0000-0000-000000000002"), "A colleague is visibly struggling with a tough assignment. You...", null, null },
                    { new Guid("00000000-0000-0000-0003-000000000015"), null, null, "CF_15", null, new DateTime(2026, 1, 1, 0, 0, 0, 0, DateTimeKind.Utc), null, null, null, 15, 1, "[{\"text\":\"New product roadmap, engineering milestones, and technical innovations.\",\"clusterImpact\":{\"BUILDER\":5,\"ANALYST\":3}},{\"text\":\"Bold business growth targets and how the company plans to win the market.\",\"clusterImpact\":{\"ENTREPRENEUR\":5,\"ANALYST\":2}},{\"text\":\"Stories about employees or customers whose lives have been genuinely changed.\",\"clusterImpact\":{\"CAREGIVER\":5,\"COMMUNICATOR\":4}},{\"text\":\"Daring creative campaigns or brand moves that nobody saw coming.\",\"clusterImpact\":{\"CREATOR\":5,\"COMMUNICATOR\":3}}]", new Guid("00000000-0000-0000-0000-000000000002"), "At a company all-hands, you get most excited when you hear about...", null, null },
                    { new Guid("00000000-0000-0000-0003-000000000016"), null, null, "CF_16", null, new DateTime(2026, 1, 1, 0, 0, 0, 0, DateTimeKind.Utc), null, null, null, 16, 1, "[{\"text\":\"Deep solo focus \\u2014 no meetings, no interruptions, just you and the problem.\",\"clusterImpact\":{\"ANALYST\":5,\"BUILDER\":4}},{\"text\":\"Fast-paced cross-functional sprints where you juggle multiple moving parts.\",\"clusterImpact\":{\"ENTREPRENEUR\":5,\"COMMUNICATOR\":3}},{\"text\":\"Clear structures, accountable teams, and well-defined repeatable processes.\",\"clusterImpact\":{\"OPERATOR\":5,\"LEADER\":3}},{\"text\":\"Open, diverse collaboration where great ideas can come from anywhere.\",\"clusterImpact\":{\"CREATOR\":5,\"COMMUNICATOR\":4}}]", new Guid("00000000-0000-0000-0000-000000000002"), "The work setup where you consistently do your absolute best is...", null, null },
                    { new Guid("00000000-0000-0000-0003-000000000017"), null, null, "CF_17", null, new DateTime(2026, 1, 1, 0, 0, 0, 0, DateTimeKind.Utc), null, null, null, 17, 1, "[{\"text\":\"Having built products, tools, or infrastructure that millions depend on.\",\"clusterImpact\":{\"BUILDER\":5,\"ENTREPRENEUR\":2}},{\"text\":\"Running your own company, fund, or investment portfolio.\",\"clusterImpact\":{\"ENTREPRENEUR\":5,\"LEADER\":3}},{\"text\":\"Leading a large organisation or a mission-driven institution.\",\"clusterImpact\":{\"LEADER\":5,\"OPERATOR\":3}},{\"text\":\"Being recognised as the world\\u0027s leading expert in your field.\",\"clusterImpact\":{\"ANALYST\":5,\"COMMUNICATOR\":3}}]", new Guid("00000000-0000-0000-0000-000000000002"), "Looking further ahead, you would feel most fulfilled if your career led to...", null, null },
                    { new Guid("00000000-0000-0000-0003-000000000018"), null, null, "CF_18", null, new DateTime(2026, 1, 1, 0, 0, 0, 0, DateTimeKind.Utc), null, null, null, 18, 1, "[{\"text\":\"What you built, shipped, or delivered that still runs reliably today.\",\"clusterImpact\":{\"BUILDER\":5,\"OPERATOR\":4}},{\"text\":\"The growth in revenue, users, or market share you personally drove.\",\"clusterImpact\":{\"ENTREPRENEUR\":5,\"ANALYST\":2}},{\"text\":\"The lives you changed or the problems you permanently solved for people.\",\"clusterImpact\":{\"CAREGIVER\":5,\"COMMUNICATOR\":3}},{\"text\":\"The new ideas, categories, or experiences you introduced to the world.\",\"clusterImpact\":{\"CREATOR\":5,\"ENTREPRENEUR\":3}}]", new Guid("00000000-0000-0000-0000-000000000002"), "At the end of it all, you measure success by...", null, null }
                });

            migrationBuilder.InsertData(
                table: "tests",
                columns: new[] { "id", "createdatutc", "name" },
                values: new object[] { new Guid("00000000-0000-0000-0000-000000000002"), new DateTime(2026, 1, 1, 0, 0, 0, 0, DateTimeKind.Utc), "Career Fit Assessment" });
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DeleteData(
                table: "questions",
                keyColumn: "id",
                keyValue: new Guid("00000000-0000-0000-0003-000000000001"));

            migrationBuilder.DeleteData(
                table: "questions",
                keyColumn: "id",
                keyValue: new Guid("00000000-0000-0000-0003-000000000002"));

            migrationBuilder.DeleteData(
                table: "questions",
                keyColumn: "id",
                keyValue: new Guid("00000000-0000-0000-0003-000000000003"));

            migrationBuilder.DeleteData(
                table: "questions",
                keyColumn: "id",
                keyValue: new Guid("00000000-0000-0000-0003-000000000004"));

            migrationBuilder.DeleteData(
                table: "questions",
                keyColumn: "id",
                keyValue: new Guid("00000000-0000-0000-0003-000000000005"));

            migrationBuilder.DeleteData(
                table: "questions",
                keyColumn: "id",
                keyValue: new Guid("00000000-0000-0000-0003-000000000006"));

            migrationBuilder.DeleteData(
                table: "questions",
                keyColumn: "id",
                keyValue: new Guid("00000000-0000-0000-0003-000000000007"));

            migrationBuilder.DeleteData(
                table: "questions",
                keyColumn: "id",
                keyValue: new Guid("00000000-0000-0000-0003-000000000008"));

            migrationBuilder.DeleteData(
                table: "questions",
                keyColumn: "id",
                keyValue: new Guid("00000000-0000-0000-0003-000000000009"));

            migrationBuilder.DeleteData(
                table: "questions",
                keyColumn: "id",
                keyValue: new Guid("00000000-0000-0000-0003-000000000010"));

            migrationBuilder.DeleteData(
                table: "questions",
                keyColumn: "id",
                keyValue: new Guid("00000000-0000-0000-0003-000000000011"));

            migrationBuilder.DeleteData(
                table: "questions",
                keyColumn: "id",
                keyValue: new Guid("00000000-0000-0000-0003-000000000012"));

            migrationBuilder.DeleteData(
                table: "questions",
                keyColumn: "id",
                keyValue: new Guid("00000000-0000-0000-0003-000000000013"));

            migrationBuilder.DeleteData(
                table: "questions",
                keyColumn: "id",
                keyValue: new Guid("00000000-0000-0000-0003-000000000014"));

            migrationBuilder.DeleteData(
                table: "questions",
                keyColumn: "id",
                keyValue: new Guid("00000000-0000-0000-0003-000000000015"));

            migrationBuilder.DeleteData(
                table: "questions",
                keyColumn: "id",
                keyValue: new Guid("00000000-0000-0000-0003-000000000016"));

            migrationBuilder.DeleteData(
                table: "questions",
                keyColumn: "id",
                keyValue: new Guid("00000000-0000-0000-0003-000000000017"));

            migrationBuilder.DeleteData(
                table: "questions",
                keyColumn: "id",
                keyValue: new Guid("00000000-0000-0000-0003-000000000018"));

            migrationBuilder.DeleteData(
                table: "tests",
                keyColumn: "id",
                keyValue: new Guid("00000000-0000-0000-0000-000000000002"));
        }
    }
}
