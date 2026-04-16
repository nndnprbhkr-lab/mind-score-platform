using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

#pragma warning disable CA1814 // Prefer jagged arrays over multidimensional

namespace MindScorePlatform.Infrastructure.Migrations
{
    /// <inheritdoc />
    public partial class SeedContextAwareQuestions : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.UpdateData(
                table: "questions",
                keyColumn: "id",
                keyValue: new Guid("00000000-0000-0000-0001-000000000002"),
                column: "isreversescored",
                value: true);

            migrationBuilder.UpdateData(
                table: "questions",
                keyColumn: "id",
                keyValue: new Guid("00000000-0000-0000-0001-000000000004"),
                column: "isreversescored",
                value: true);

            migrationBuilder.UpdateData(
                table: "questions",
                keyColumn: "id",
                keyValue: new Guid("00000000-0000-0000-0001-000000000005"),
                column: "branchingrulesjson",
                value: "{\"conditions\":[{\"answerRange\":[1,2],\"nextQuestionCode\":\"EI_DEEP_R\"},{\"answerRange\":[4,5],\"nextQuestionCode\":\"EI_DEEP_E\"}]}");

            migrationBuilder.UpdateData(
                table: "questions",
                keyColumn: "id",
                keyValue: new Guid("00000000-0000-0000-0001-000000000007"),
                column: "isreversescored",
                value: true);

            migrationBuilder.UpdateData(
                table: "questions",
                keyColumn: "id",
                keyValue: new Guid("00000000-0000-0000-0001-000000000009"),
                column: "isreversescored",
                value: true);

            migrationBuilder.UpdateData(
                table: "questions",
                keyColumn: "id",
                keyValue: new Guid("00000000-0000-0000-0001-000000000012"),
                column: "isreversescored",
                value: true);

            migrationBuilder.UpdateData(
                table: "questions",
                keyColumn: "id",
                keyValue: new Guid("00000000-0000-0000-0001-000000000014"),
                column: "isreversescored",
                value: true);

            migrationBuilder.UpdateData(
                table: "questions",
                keyColumn: "id",
                keyValue: new Guid("00000000-0000-0000-0001-000000000015"),
                column: "branchingrulesjson",
                value: "{\"conditions\":[{\"answerRange\":[1,2],\"nextQuestionCode\":\"TF_DEEP_V\"},{\"answerRange\":[4,5],\"nextQuestionCode\":\"TF_DEEP_L\"}]}");

            migrationBuilder.UpdateData(
                table: "questions",
                keyColumn: "id",
                keyValue: new Guid("00000000-0000-0000-0001-000000000017"),
                column: "isreversescored",
                value: true);

            migrationBuilder.UpdateData(
                table: "questions",
                keyColumn: "id",
                keyValue: new Guid("00000000-0000-0000-0001-000000000019"),
                column: "isreversescored",
                value: true);

            migrationBuilder.InsertData(
                table: "questions",
                columns: new[] { "id", "agebandid", "branchingrulesjson", "code", "contexttagsjson", "createdatutc", "difficulty", "isreversescored", "moduleid", "orderid", "scenariooptionsjson", "testid", "text", "version", "weight" },
                values: new object[,]
                {
                    { new Guid("00000000-0000-0000-0002-000000000001"), null, null, "EI_DEEP_E", null, new DateTime(2026, 1, 1, 0, 0, 0, 0, DateTimeKind.Utc), null, false, null, 21, null, new Guid("00000000-0000-0000-0000-000000000001"), "When I need to recharge, I gravitate toward busy social events rather than spending time alone.", null, null },
                    { new Guid("00000000-0000-0000-0002-000000000002"), null, null, "EI_DEEP_R", null, new DateTime(2026, 1, 1, 0, 0, 0, 0, DateTimeKind.Utc), null, true, null, 22, null, new Guid("00000000-0000-0000-0000-000000000001"), "Extended periods of solitude feel essential to my wellbeing, even when life is going well.", null, null },
                    { new Guid("00000000-0000-0000-0002-000000000003"), null, null, "TF_DEEP_L", null, new DateTime(2026, 1, 1, 0, 0, 0, 0, DateTimeKind.Utc), null, false, null, 23, null, new Guid("00000000-0000-0000-0000-000000000001"), "When solving problems, I focus on root causes and system efficiency rather than who is affected.", null, null },
                    { new Guid("00000000-0000-0000-0002-000000000004"), null, null, "TF_DEEP_V", null, new DateTime(2026, 1, 1, 0, 0, 0, 0, DateTimeKind.Utc), null, true, null, 24, null, new Guid("00000000-0000-0000-0000-000000000001"), "The emotional impact of a decision on others weighs more heavily on me than its logical merits.", null, null },
                    { new Guid("00000000-0000-0000-0002-000000000005"), null, null, "EI_CAR_01", "[\"Career\"]", new DateTime(2026, 1, 1, 0, 0, 0, 0, DateTimeKind.Utc), null, false, null, 100, null, new Guid("00000000-0000-0000-0000-000000000001"), "Collaborative brainstorming sessions at work leave me more energized than focused solo work.", null, null },
                    { new Guid("00000000-0000-0000-0002-000000000006"), null, null, "SN_CAR_01_R", "[\"Career\"]", new DateTime(2026, 1, 1, 0, 0, 0, 0, DateTimeKind.Utc), null, true, null, 101, null, new Guid("00000000-0000-0000-0000-000000000001"), "I often find myself pitching future possibilities at work rather than refining existing processes.", null, null },
                    { new Guid("00000000-0000-0000-0002-000000000007"), null, null, "TF_CAR_01_R", "[\"Career\"]", new DateTime(2026, 1, 1, 0, 0, 0, 0, DateTimeKind.Utc), null, true, null, 102, null, new Guid("00000000-0000-0000-0000-000000000001"), "When workplace decisions affect team morale, I weight personal impact over operational logic.", null, null },
                    { new Guid("00000000-0000-0000-0002-000000000008"), null, null, "JP_CAR_01", "[\"Career\"]", new DateTime(2026, 1, 1, 0, 0, 0, 0, DateTimeKind.Utc), null, false, null, 103, null, new Guid("00000000-0000-0000-0000-000000000001"), "I plan my workweek in detail and resist changes to my scheduled priorities.", null, null }
                });

            migrationBuilder.InsertData(
                table: "questions",
                columns: new[] { "id", "agebandid", "branchingrulesjson", "code", "contexttagsjson", "createdatutc", "difficulty", "isreversescored", "moduleid", "orderid", "questiontype", "scenariooptionsjson", "testid", "text", "version", "weight" },
                values: new object[,]
                {
                    { new Guid("00000000-0000-0000-0002-000000000009"), null, null, "SCEN_CAR_01", "[\"Career\"]", new DateTime(2026, 1, 1, 0, 0, 0, 0, DateTimeKind.Utc), null, null, null, 104, 1, "[{\"text\":\"Call a working meeting first thing, gather everyone's views aloud, and push the group toward a shared direction through open discussion.\",\"traitMappings\":{\"EnergySource\":5,\"LifeApproach\":4}},{\"text\":\"Research how similar teams solved comparable problems, gather concrete data, and draft a detailed proposal based on what has worked before.\",\"traitMappings\":{\"PerceptionMode\":5,\"LifeApproach\":4}},{\"text\":\"Spend time alone thinking through emerging patterns, then share a conceptual framework exploring possibilities the team may not have considered yet.\",\"traitMappings\":{\"EnergySource\":2,\"PerceptionMode\":1}},{\"text\":\"Check in individually with teammates to understand how each is affected, then propose an approach balancing the group's emotional and practical needs.\",\"traitMappings\":{\"DecisionStyle\":1,\"EnergySource\":3}}]", new Guid("00000000-0000-0000-0000-000000000001"), "Your team has been asked to recommend a new approach for an ongoing project, but the brief is vague and stakeholders disagree on priorities. You have one week before presenting a proposal, and your manager has delegated the decision to the team. How do you most naturally engage with this situation?", null, null },
                    { new Guid("00000000-0000-0000-0002-000000000010"), null, null, "SCEN_CAR_02", "[\"Career\"]", new DateTime(2026, 1, 1, 0, 0, 0, 0, DateTimeKind.Utc), null, null, null, 105, 1, "[{\"text\":\"Build a detailed hour-by-hour schedule that protects the non-negotiable deadlines first, then scope down the lower-impact project to fit within remaining hours.\",\"traitMappings\":{\"LifeApproach\":5,\"DecisionStyle\":4}},{\"text\":\"Talk it through with both project stakeholders to understand what each needs emotionally, then propose a middle path everyone can accept.\",\"traitMappings\":{\"DecisionStyle\":1,\"EnergySource\":4}},{\"text\":\"Keep both options open and adapt day by day, trusting I can shift attention as each project's actual urgency becomes clearer.\",\"traitMappings\":{\"LifeApproach\":1,\"PerceptionMode\":2}},{\"text\":\"Map the underlying system — who needs what, by when, and why — then make the most logically efficient cut even if it disappoints someone.\",\"traitMappings\":{\"DecisionStyle\":5,\"PerceptionMode\":4}}]", new Guid("00000000-0000-0000-0000-000000000001"), "Two important projects are due the same week and you cannot fully deliver both to your usual standard. Your manager leaves the trade-off to you, and neither project has an obvious priority. You have a full day before you need to commit to a plan. What is your most likely response?", null, null }
                });

            migrationBuilder.InsertData(
                table: "questions",
                columns: new[] { "id", "agebandid", "branchingrulesjson", "code", "contexttagsjson", "createdatutc", "difficulty", "isreversescored", "moduleid", "orderid", "scenariooptionsjson", "testid", "text", "version", "weight" },
                values: new object[,]
                {
                    { new Guid("00000000-0000-0000-0002-000000000011"), null, null, "EI_REL_01", "[\"Relationships\"]", new DateTime(2026, 1, 1, 0, 0, 0, 0, DateTimeKind.Utc), null, false, null, 110, null, new Guid("00000000-0000-0000-0000-000000000001"), "I stay energized after long social gatherings with close friends, even when they run late.", null, null },
                    { new Guid("00000000-0000-0000-0002-000000000012"), null, null, "SN_REL_01_R", "[\"Relationships\"]", new DateTime(2026, 1, 1, 0, 0, 0, 0, DateTimeKind.Utc), null, true, null, 111, null, new Guid("00000000-0000-0000-0000-000000000001"), "I often sense unspoken meanings in a partner's words before I notice the literal facts.", null, null },
                    { new Guid("00000000-0000-0000-0002-000000000013"), null, null, "TF_REL_01", "[\"Relationships\"]", new DateTime(2026, 1, 1, 0, 0, 0, 0, DateTimeKind.Utc), null, false, null, 112, null, new Guid("00000000-0000-0000-0000-000000000001"), "During relationship conflicts, I focus on identifying what is objectively fair rather than comforting feelings first.", null, null },
                    { new Guid("00000000-0000-0000-0002-000000000014"), null, null, "JP_REL_01_R", "[\"Relationships\"]", new DateTime(2026, 1, 1, 0, 0, 0, 0, DateTimeKind.Utc), null, true, null, 113, null, new Guid("00000000-0000-0000-0000-000000000001"), "I prefer spontaneous plans with close people over keeping fixed routines or scheduled commitments.", null, null }
                });

            migrationBuilder.InsertData(
                table: "questions",
                columns: new[] { "id", "agebandid", "branchingrulesjson", "code", "contexttagsjson", "createdatutc", "difficulty", "isreversescored", "moduleid", "orderid", "questiontype", "scenariooptionsjson", "testid", "text", "version", "weight" },
                values: new object[,]
                {
                    { new Guid("00000000-0000-0000-0002-000000000015"), null, null, "SCEN_REL_01", "[\"Relationships\"]", new DateTime(2026, 1, 1, 0, 0, 0, 0, DateTimeKind.Utc), null, null, null, 114, 1, "[{\"text\":\"Suggest meeting in person to talk it through openly — you process through conversation and would rather hash it out than sit with uncertainty.\",\"traitMappings\":{\"EnergySource\":5,\"LifeApproach\":4}},{\"text\":\"Sit with the situation for several days, noticing patterns in their behaviour and replaying past interactions before deciding how to respond.\",\"traitMappings\":{\"EnergySource\":1,\"PerceptionMode\":4}},{\"text\":\"Focus on what you can logically observe — their actions, not assumed intent — and wait for concrete information before investing emotional energy.\",\"traitMappings\":{\"DecisionStyle\":5,\"PerceptionMode\":4}},{\"text\":\"Send a warm, open message acknowledging you sense something is off and making space for whatever they need to share.\",\"traitMappings\":{\"DecisionStyle\":1,\"EnergySource\":3}}]", new Guid("00000000-0000-0000-0000-000000000001"), "A close friend has grown distant over the past month, cancelling plans and giving short replies. You do not know the cause, and when you last asked, they deflected. You are starting to feel hurt and uncertain whether to press further. What do you most likely do next?", null, null },
                    { new Guid("00000000-0000-0000-0002-000000000016"), null, null, "SCEN_REL_02", "[\"Relationships\"]", new DateTime(2026, 1, 1, 0, 0, 0, 0, DateTimeKind.Utc), null, null, null, 115, 1, "[{\"text\":\"Work through a written pros-and-cons analysis covering finances, career trajectories, and logistics — decide based on which option objectively maximizes combined outcomes.\",\"traitMappings\":{\"DecisionStyle\":5,\"LifeApproach\":4}},{\"text\":\"Have a long, feelings-first conversation — what it means for each of you, what fears are surfacing — and let the emotional truth lead.\",\"traitMappings\":{\"DecisionStyle\":1,\"EnergySource\":4}},{\"text\":\"Hold off committing either way, stay open, and see what new information or intuition emerges over the next couple of weeks.\",\"traitMappings\":{\"LifeApproach\":1,\"PerceptionMode\":2}},{\"text\":\"Take time alone to imagine both futures vividly, then share the deeper patterns and possibilities you noticed before deciding together.\",\"traitMappings\":{\"EnergySource\":1,\"PerceptionMode\":1}}]", new Guid("00000000-0000-0000-0000-000000000001"), "Your partner has been offered a career opportunity that would require you both to relocate within three months. The move is exciting for them but disruptive for your own career and social life. A decision is needed this weekend. How do you most naturally engage?", null, null }
                });

            migrationBuilder.InsertData(
                table: "questions",
                columns: new[] { "id", "agebandid", "branchingrulesjson", "code", "contexttagsjson", "createdatutc", "difficulty", "isreversescored", "moduleid", "orderid", "scenariooptionsjson", "testid", "text", "version", "weight" },
                values: new object[,]
                {
                    { new Guid("00000000-0000-0000-0002-000000000017"), null, null, "EI_LEA_01", "[\"Leadership\"]", new DateTime(2026, 1, 1, 0, 0, 0, 0, DateTimeKind.Utc), null, false, null, 120, null, new Guid("00000000-0000-0000-0000-000000000001"), "As a leader, I prefer visible front-line roles that involve speaking to large groups and rallying people.", null, null },
                    { new Guid("00000000-0000-0000-0002-000000000018"), null, null, "SN_LEA_01", "[\"Leadership\"]", new DateTime(2026, 1, 1, 0, 0, 0, 0, DateTimeKind.Utc), null, false, null, 121, null, new Guid("00000000-0000-0000-0000-000000000001"), "When leading, I rely on concrete performance data and track records rather than long-term vision statements.", null, null },
                    { new Guid("00000000-0000-0000-0002-000000000019"), null, null, "TF_LEA_01_R", "[\"Leadership\"]", new DateTime(2026, 1, 1, 0, 0, 0, 0, DateTimeKind.Utc), null, true, null, 122, null, new Guid("00000000-0000-0000-0000-000000000001"), "When leading, I weigh each team member's personal circumstances more heavily than strict performance standards.", null, null },
                    { new Guid("00000000-0000-0000-0002-000000000020"), null, null, "JP_LEA_01", "[\"Leadership\"]", new DateTime(2026, 1, 1, 0, 0, 0, 0, DateTimeKind.Utc), null, false, null, 123, null, new Guid("00000000-0000-0000-0000-000000000001"), "I set clear goals, milestones, and deadlines for my team and hold people firmly to them.", null, null }
                });

            migrationBuilder.InsertData(
                table: "questions",
                columns: new[] { "id", "agebandid", "branchingrulesjson", "code", "contexttagsjson", "createdatutc", "difficulty", "isreversescored", "moduleid", "orderid", "questiontype", "scenariooptionsjson", "testid", "text", "version", "weight" },
                values: new object[,]
                {
                    { new Guid("00000000-0000-0000-0002-000000000021"), null, null, "SCEN_LEA_01", "[\"Leadership\"]", new DateTime(2026, 1, 1, 0, 0, 0, 0, DateTimeKind.Utc), null, null, null, 124, 1, "[{\"text\":\"Schedule a direct one-on-one this week, lay out the performance facts clearly, and agree on measurable expectations with firm deadlines.\",\"traitMappings\":{\"DecisionStyle\":5,\"LifeApproach\":5}},{\"text\":\"Create space for an open conversation focused on how they are doing as a person — something is likely going on beneath the surface.\",\"traitMappings\":{\"DecisionStyle\":1,\"EnergySource\":4}},{\"text\":\"Observe quietly for another week, gather more data points and context from others, then decide once the pattern is clearer.\",\"traitMappings\":{\"EnergySource\":2,\"PerceptionMode\":4}},{\"text\":\"Hold a team discussion about workload and shared standards, letting the group itself shape how to address the drift.\",\"traitMappings\":{\"EnergySource\":5,\"LifeApproach\":3}}]", new Guid("00000000-0000-0000-0000-000000000001"), "A previously high-performing team member has missed three consecutive deadlines and is withdrawing in meetings. Other teammates are starting to pick up the slack and grumble quietly. You have not yet spoken directly with the person, and a quarterly review is two weeks away. How do you proceed?", null, null },
                    { new Guid("00000000-0000-0000-0002-000000000022"), null, null, "SCEN_LEA_02", "[\"Leadership\"]", new DateTime(2026, 1, 1, 0, 0, 0, 0, DateTimeKind.Utc), null, null, null, 125, 1, "[{\"text\":\"Convene a cross-functional working group, debate both options openly in a full-day session, and push toward a shared decision through rapid group dialogue.\",\"traitMappings\":{\"EnergySource\":5,\"LifeApproach\":4}},{\"text\":\"Commission a deep dive into historical data and comparable cases, then recommend the option the evidence most concretely supports.\",\"traitMappings\":{\"PerceptionMode\":5,\"DecisionStyle\":4}},{\"text\":\"Pick the unfamiliar opportunity — the pattern feels right, the upside matters, and waiting for full certainty will cost momentum.\",\"traitMappings\":{\"PerceptionMode\":1,\"LifeApproach\":2}},{\"text\":\"Consider how each option affects the team's wellbeing and growth, and pick the one people can believe in and commit to.\",\"traitMappings\":{\"DecisionStyle\":1,\"EnergySource\":3}}]", new Guid("00000000-0000-0000-0000-000000000001"), "Your team must choose between two strategic directions for the next quarter, each with incomplete information. One is a proven safe bet with modest gains; the other is an unfamiliar opportunity with bigger potential upside and real risk. A recommendation is due by Friday. How do you approach the choice?", null, null }
                });

            migrationBuilder.InsertData(
                table: "questions",
                columns: new[] { "id", "agebandid", "branchingrulesjson", "code", "contexttagsjson", "createdatutc", "difficulty", "isreversescored", "moduleid", "orderid", "scenariooptionsjson", "testid", "text", "version", "weight" },
                values: new object[,]
                {
                    { new Guid("00000000-0000-0000-0002-000000000023"), null, null, "EI_PD_01_R", "[\"PersonalDevelopment\"]", new DateTime(2026, 1, 1, 0, 0, 0, 0, DateTimeKind.Utc), null, true, null, 130, null, new Guid("00000000-0000-0000-0000-000000000001"), "My most meaningful personal growth happens during extended solitude rather than in groups or conversations.", null, null },
                    { new Guid("00000000-0000-0000-0002-000000000024"), null, null, "SN_PD_01", "[\"PersonalDevelopment\"]", new DateTime(2026, 1, 1, 0, 0, 0, 0, DateTimeKind.Utc), null, false, null, 131, null, new Guid("00000000-0000-0000-0000-000000000001"), "I prefer tracking concrete habits and measurable progress over exploring abstract themes about who I am becoming.", null, null },
                    { new Guid("00000000-0000-0000-0002-000000000025"), null, null, "TF_PD_01", "[\"PersonalDevelopment\"]", new DateTime(2026, 1, 1, 0, 0, 0, 0, DateTimeKind.Utc), null, false, null, 132, null, new Guid("00000000-0000-0000-0000-000000000001"), "When reflecting on myself, I diagnose what is inefficient or irrational rather than sitting with emotions first.", null, null },
                    { new Guid("00000000-0000-0000-0002-000000000026"), null, null, "JP_PD_01_R", "[\"PersonalDevelopment\"]", new DateTime(2026, 1, 1, 0, 0, 0, 0, DateTimeKind.Utc), null, true, null, 133, null, new Guid("00000000-0000-0000-0000-000000000001"), "I let my personal growth unfold organically rather than committing to structured routines or plans.", null, null }
                });

            migrationBuilder.InsertData(
                table: "questions",
                columns: new[] { "id", "agebandid", "branchingrulesjson", "code", "contexttagsjson", "createdatutc", "difficulty", "isreversescored", "moduleid", "orderid", "questiontype", "scenariooptionsjson", "testid", "text", "version", "weight" },
                values: new object[,]
                {
                    { new Guid("00000000-0000-0000-0002-000000000027"), null, null, "SCEN_PD_01", "[\"PersonalDevelopment\"]", new DateTime(2026, 1, 1, 0, 0, 0, 0, DateTimeKind.Utc), null, null, null, 134, 1, "[{\"text\":\"Journal alone for hours, mapping connections between current behaviours and deeper themes you have been noticing over the past months.\",\"traitMappings\":{\"EnergySource\":1,\"PerceptionMode\":1}},{\"text\":\"Reach out to a trusted friend or coach, talk it through aloud, and let the conversation surface what you could not see alone.\",\"traitMappings\":{\"EnergySource\":5,\"DecisionStyle\":2}},{\"text\":\"Build a structured weekend plan — specific reading, specific exercises, specific reflection prompts — and work through it step by step.\",\"traitMappings\":{\"LifeApproach\":5,\"DecisionStyle\":4}},{\"text\":\"Research proven frameworks for this kind of pattern, identify the mechanism causing it, and design a logical intervention to test.\",\"traitMappings\":{\"DecisionStyle\":5,\"PerceptionMode\":4}}]", new Guid("00000000-0000-0000-0000-000000000001"), "You have been feeling stuck in a recurring personal pattern — one that surfaces in work, relationships, and your own self-talk. You have noticed it clearly this week and know you want to address it. You have a free weekend ahead to work on it. What do you most naturally reach for?", null, null },
                    { new Guid("00000000-0000-0000-0002-000000000028"), null, null, "SCEN_PD_02", "[\"PersonalDevelopment\"]", new DateTime(2026, 1, 1, 0, 0, 0, 0, DateTimeKind.Utc), null, null, null, 135, 1, "[{\"text\":\"Write a detailed weekly plan with specific times, metrics, and milestones, then commit publicly to maintain accountability through clear structure.\",\"traitMappings\":{\"LifeApproach\":5,\"DecisionStyle\":4}},{\"text\":\"Start loosely, see what feels right in practice, and adapt the approach as you go without committing to a rigid plan.\",\"traitMappings\":{\"LifeApproach\":1,\"PerceptionMode\":2}},{\"text\":\"Research behaviour-change science, identify the mechanisms most likely to work for someone like you, and design a system based on evidence.\",\"traitMappings\":{\"PerceptionMode\":5,\"DecisionStyle\":5}},{\"text\":\"Involve close friends or a group — shared energy, public commitment, and social reinforcement are what actually make things stick for you.\",\"traitMappings\":{\"EnergySource\":5,\"DecisionStyle\":2}}]", new Guid("00000000-0000-0000-0000-000000000001"), "You have decided to make a significant lifestyle change — a new sleep schedule, exercise routine, and reading practice — starting next month. You have three weeks to prepare. You know from experience that some change strategies work better for you than others. How do you set yourself up?", null, null }
                });
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DeleteData(
                table: "questions",
                keyColumn: "id",
                keyValue: new Guid("00000000-0000-0000-0002-000000000001"));

            migrationBuilder.DeleteData(
                table: "questions",
                keyColumn: "id",
                keyValue: new Guid("00000000-0000-0000-0002-000000000002"));

            migrationBuilder.DeleteData(
                table: "questions",
                keyColumn: "id",
                keyValue: new Guid("00000000-0000-0000-0002-000000000003"));

            migrationBuilder.DeleteData(
                table: "questions",
                keyColumn: "id",
                keyValue: new Guid("00000000-0000-0000-0002-000000000004"));

            migrationBuilder.DeleteData(
                table: "questions",
                keyColumn: "id",
                keyValue: new Guid("00000000-0000-0000-0002-000000000005"));

            migrationBuilder.DeleteData(
                table: "questions",
                keyColumn: "id",
                keyValue: new Guid("00000000-0000-0000-0002-000000000006"));

            migrationBuilder.DeleteData(
                table: "questions",
                keyColumn: "id",
                keyValue: new Guid("00000000-0000-0000-0002-000000000007"));

            migrationBuilder.DeleteData(
                table: "questions",
                keyColumn: "id",
                keyValue: new Guid("00000000-0000-0000-0002-000000000008"));

            migrationBuilder.DeleteData(
                table: "questions",
                keyColumn: "id",
                keyValue: new Guid("00000000-0000-0000-0002-000000000009"));

            migrationBuilder.DeleteData(
                table: "questions",
                keyColumn: "id",
                keyValue: new Guid("00000000-0000-0000-0002-000000000010"));

            migrationBuilder.DeleteData(
                table: "questions",
                keyColumn: "id",
                keyValue: new Guid("00000000-0000-0000-0002-000000000011"));

            migrationBuilder.DeleteData(
                table: "questions",
                keyColumn: "id",
                keyValue: new Guid("00000000-0000-0000-0002-000000000012"));

            migrationBuilder.DeleteData(
                table: "questions",
                keyColumn: "id",
                keyValue: new Guid("00000000-0000-0000-0002-000000000013"));

            migrationBuilder.DeleteData(
                table: "questions",
                keyColumn: "id",
                keyValue: new Guid("00000000-0000-0000-0002-000000000014"));

            migrationBuilder.DeleteData(
                table: "questions",
                keyColumn: "id",
                keyValue: new Guid("00000000-0000-0000-0002-000000000015"));

            migrationBuilder.DeleteData(
                table: "questions",
                keyColumn: "id",
                keyValue: new Guid("00000000-0000-0000-0002-000000000016"));

            migrationBuilder.DeleteData(
                table: "questions",
                keyColumn: "id",
                keyValue: new Guid("00000000-0000-0000-0002-000000000017"));

            migrationBuilder.DeleteData(
                table: "questions",
                keyColumn: "id",
                keyValue: new Guid("00000000-0000-0000-0002-000000000018"));

            migrationBuilder.DeleteData(
                table: "questions",
                keyColumn: "id",
                keyValue: new Guid("00000000-0000-0000-0002-000000000019"));

            migrationBuilder.DeleteData(
                table: "questions",
                keyColumn: "id",
                keyValue: new Guid("00000000-0000-0000-0002-000000000020"));

            migrationBuilder.DeleteData(
                table: "questions",
                keyColumn: "id",
                keyValue: new Guid("00000000-0000-0000-0002-000000000021"));

            migrationBuilder.DeleteData(
                table: "questions",
                keyColumn: "id",
                keyValue: new Guid("00000000-0000-0000-0002-000000000022"));

            migrationBuilder.DeleteData(
                table: "questions",
                keyColumn: "id",
                keyValue: new Guid("00000000-0000-0000-0002-000000000023"));

            migrationBuilder.DeleteData(
                table: "questions",
                keyColumn: "id",
                keyValue: new Guid("00000000-0000-0000-0002-000000000024"));

            migrationBuilder.DeleteData(
                table: "questions",
                keyColumn: "id",
                keyValue: new Guid("00000000-0000-0000-0002-000000000025"));

            migrationBuilder.DeleteData(
                table: "questions",
                keyColumn: "id",
                keyValue: new Guid("00000000-0000-0000-0002-000000000026"));

            migrationBuilder.DeleteData(
                table: "questions",
                keyColumn: "id",
                keyValue: new Guid("00000000-0000-0000-0002-000000000027"));

            migrationBuilder.DeleteData(
                table: "questions",
                keyColumn: "id",
                keyValue: new Guid("00000000-0000-0000-0002-000000000028"));

            migrationBuilder.UpdateData(
                table: "questions",
                keyColumn: "id",
                keyValue: new Guid("00000000-0000-0000-0001-000000000002"),
                column: "isreversescored",
                value: null);

            migrationBuilder.UpdateData(
                table: "questions",
                keyColumn: "id",
                keyValue: new Guid("00000000-0000-0000-0001-000000000004"),
                column: "isreversescored",
                value: null);

            migrationBuilder.UpdateData(
                table: "questions",
                keyColumn: "id",
                keyValue: new Guid("00000000-0000-0000-0001-000000000005"),
                column: "branchingrulesjson",
                value: null);

            migrationBuilder.UpdateData(
                table: "questions",
                keyColumn: "id",
                keyValue: new Guid("00000000-0000-0000-0001-000000000007"),
                column: "isreversescored",
                value: null);

            migrationBuilder.UpdateData(
                table: "questions",
                keyColumn: "id",
                keyValue: new Guid("00000000-0000-0000-0001-000000000009"),
                column: "isreversescored",
                value: null);

            migrationBuilder.UpdateData(
                table: "questions",
                keyColumn: "id",
                keyValue: new Guid("00000000-0000-0000-0001-000000000012"),
                column: "isreversescored",
                value: null);

            migrationBuilder.UpdateData(
                table: "questions",
                keyColumn: "id",
                keyValue: new Guid("00000000-0000-0000-0001-000000000014"),
                column: "isreversescored",
                value: null);

            migrationBuilder.UpdateData(
                table: "questions",
                keyColumn: "id",
                keyValue: new Guid("00000000-0000-0000-0001-000000000015"),
                column: "branchingrulesjson",
                value: null);

            migrationBuilder.UpdateData(
                table: "questions",
                keyColumn: "id",
                keyValue: new Guid("00000000-0000-0000-0001-000000000017"),
                column: "isreversescored",
                value: null);

            migrationBuilder.UpdateData(
                table: "questions",
                keyColumn: "id",
                keyValue: new Guid("00000000-0000-0000-0001-000000000019"),
                column: "isreversescored",
                value: null);
        }
    }
}
