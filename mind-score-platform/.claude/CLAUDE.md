# Mind-Score Platform — Project Intelligence

## FIRST THING EVERY SESSION

Read these memory files in order before touching any file:

1. `/Users/nandan/.claude/projects/-Users-nandan-Documents-Self-Help/memory/project_mindscore_architecture.md`
2. `/Users/nandan/.claude/projects/-Users-nandan-Documents-Self-Help/memory/project_mindscore_requirements.md`
3. `/Users/nandan/.claude/projects/-Users-nandan-Documents-Self-Help/memory/project_mindscore_mpi_engine.md`
4. `/Users/nandan/.claude/projects/-Users-nandan-Documents-Self-Help/memory/project_mindscore_phase4.md`
5. `/Users/nandan/.claude/projects/-Users-nandan-Documents-Self-Help/memory/project_mindscore_context_results.md`
6. `/Users/nandan/.claude/projects/-Users-nandan-Documents-Self-Help/memory/project_mindscore_devservers.md`
7. `/Users/nandan/.claude/projects/-Users-nandan-Documents-Self-Help/memory/user_profile.md`

Only read source files if a memory file is missing something you need. Update memory when done.

---

## Project Overview

Mind-Score is an adaptive, context-aware, AI-personalised psychological assessment platform.
**Owner:** Nandan (solo founder — no dev team, builds entirely with Claude Code).
**Vision:** Transform from static personality test to skilled-interviewer assessment engine.

### Assessment Portfolio
| # | Name | Status |
|---|---|---|
| 1 | MindType Assessment (MPI) | ✅ Live |
| 2 | MindScore Assessment (Cognitive) | ✅ Live |
| 3 | Career Fit Assessment | ✅ Built — pending deploy |
| 4 | Relationship Dynamics | ❌ Next |
| 5 | Team & Leadership | ❌ Planned |
| 6 | Stress & Resilience | ❌ Planned |
| 7 | Values & Life Purpose | ❌ Planned |

---

## Tech Stack

| Layer | Technology |
|---|---|
| Frontend | Flutter 3.24.5, Riverpod (StateNotifier), GoRouter |
| Backend | .NET 8 / ASP.NET Core, Clean Architecture |
| Database | PostgreSQL via Supabase, EF Core 8 |
| Auth | JWT Bearer tokens |
| AI | Claude API (claude-sonnet-4-6) via raw HttpClient |
| Deployment | Docker on Render (backend), Flutter web/iOS/Android |

### Flutter 3.24.5 Constraints — MUST FOLLOW
- Use `withOpacity()` NOT `Color.withValues()` (withValues added in 3.27)
- Use `CardTheme` NOT `CardThemeData`
- Use `DialogTheme` NOT `DialogThemeData`
- Flutter SDK path: `/Users/nandan/CascadeProjects/windsurf-project/flutter/bin/flutter`

---

## Project Root

```
/Users/nandan/CascadeProjects/windsurf-project/mind-score-platform/
├── backend/
│   ├── MindScorePlatform.Domain/          — entities, enums, no dependencies
│   ├── MindScorePlatform.Application/     — interfaces, DTOs
│   ├── MindScorePlatform.Infrastructure/  — EF Core, services, repos, seed, migrations
│   └── MindScorePlatform.WebApi/          — controllers, Program.cs
└── frontend/mindscore/lib/
    ├── core/                              — constants, models, network, theme
    ├── features/                          — auth, test, results, dashboard, profile, admin
    ├── router/                            — GoRouter with auth guards
    └── widgets/                           — shared UI components
```

---

## Backend Architecture

### Clean Architecture Rules
- Domain has zero external dependencies
- Application depends only on Domain
- Infrastructure implements Application interfaces
- WebApi depends on Application + Infrastructure
- Never skip layers — no direct Infrastructure calls from WebApi controllers

### Dependency Injection
All registrations live in `Infrastructure/DependencyInjection.cs` → `AddInfrastructure()`.

```csharp
// Singletons
IMpiScoringEngine, IMpiActionPlanEngine, IJwtTokenService

// Scoped (everything else)
IUserRepository, IAuthService, ITestRepository, IQuestionRepository,
IResponseRepository, IResultRepository, IReportRepository,
ITestService, IQuestionService, IAdaptiveQuestionService,
IResponseService, IResultService, IReportService, IAiFollowUpService

// Scoring Pipelines — ORDER MATTERS (specific before catch-all)
IScoringPipeline → MindScoreScoringPipeline   // handles "MindScore Assessment"
IScoringPipeline → CareerFitScoringPipeline   // handles "Career Fit Assessment"
IScoringPipeline → MpiScoringPipeline         // catch-all (CanHandle always true)
IScoringPipelineFactory → ScoringPipelineFactory
```

### Database Column Naming Convention
All PostgreSQL columns are **lowercase, no underscores** (e.g. `createdatutc`, `userid`, `dimensionscoresjson`).
EF Core `HasColumnName()` must be explicit for every property — never rely on conventions.

---

## Domain Entities — Key Fields

### Result
```csharp
Guid Id, UserId, TestId
decimal Score
string PersonalityType, PersonalityName, PersonalityEmoji, PersonalityTagline
string DimensionScoresJson    // varies by pipeline (see below)
string InsightsJson           // varies by pipeline
DateTime CreatedAtUtc
AssessmentContext Context      // General=0, Career=1, Relationships=2, Leadership=3, PersonalDevelopment=4
string? ContextInsightsJson
string? AdaptivePathJson
string? AiFollowUpJson        // {tensions[], questions[{id,text,options[{text,dimensionImpact}]}], answers[]}
string? DimensionConfidenceJson // {EnergySource:87, ...}
```

### Question
```csharp
Guid Id, TestId
string Code, Text
int Order
QuestionType QuestionType   // Likert=0, Scenario=1, FollowUp=2
bool? IsReverseScored
Guid? AgeBandId             // null = all users
string? BranchingRulesJson  // adaptive branching rules
string? ContextTagsJson     // null = all contexts; ["Career"] = career only
string? ScenarioOptionsJson // options for Scenario questions
```

### ScenarioOptionsJson Shapes by Assessment
- **MPI:** `[{ "text": "...", "traitMappings": { "LifeApproach": 5, "DecisionStyle": 4 } }]`
- **Career Fit:** `[{ "text": "...", "clusterImpact": { "BUILDER": 5, "ANALYST": 2 } }]`

---

## Scoring Pipelines

### IScoringPipeline Pattern
```csharp
bool CanHandle(string testName)          // return true to claim this test
Task<ResultDto> ExecuteAsync(...)        // full scoring logic
```
`ScoringPipelineBase` provides `BuildQuestionMapAsync` and `PersistResponsesAsync`.
`ResultDtoMapper.ToDto` is the shared Result → ResultDto converter (all pipelines use it).

### MPI Pipeline (MindType Assessment)
- Input: Likert 1–5 per question. `_R` suffix = reverse score (6 − value).
- Dimensions: EnergySource (EI_), PerceptionMode (SN_), DecisionStyle (TF_), LifeApproach (JP_)
- Normalise → pole (≥50 = high) → strength (Slight ≤10, Moderate ≤20, Clear ≤35, Strong >35 deviation)
- Type code: `{E|R}{O|I}{L|V}{S|A}` — 16 types in `MpiTypeProfileLibrary`
- Tension detection → AI follow-up via Claude API
- DimensionScoresJson: `{ "EnergySource": { percentage, dominantPole, strength }, ... }`

### MindScore Pipeline (Cognitive)
- Input: Likert 1–5 per question, grouped by ModuleId
- Age-normed percentiles per module, weighted overall score
- Tier: Developing < Proficient < Advanced < Elite
- DimensionScoresJson: list of module scores (not a map)

### Career Fit Pipeline
- Input: Scenario questions. `Value` = selected option index (0–3) as string.
- 8 clusters: BUILDER, ANALYST, LEADER, CREATOR, CAREGIVER, COMMUNICATOR, ENTREPRENEUR, OPERATOR
- Scoring: sum `clusterImpact` weights for each selected option → normalise to % of grand total
- PersonalityType = primary cluster code (e.g. "ANALYST")
- DimensionScoresJson: `{ "ANALYST": { "percentage": 32.5 }, ... }` (8 entries, ranked)
- InsightsJson: `{ top3Clusters: [{code,name,emoji,fitPercentage}], primaryCluster: {code,name,emoji,tagline,strengths[],growthAreas[],idealRoles[]} }`

---

## Seed Data Conventions

### Fixed Test GUIDs
| Test | GUID |
|---|---|
| MindType Assessment | `00000000-0000-0000-0000-000000000001` |
| Career Fit Assessment | `00000000-0000-0000-0000-000000000002` |

### Question GUID Ranges
| Range | Content |
|---|---|
| `00000000-0000-0000-0001-XXXXXXXXXXXX` | MPI universal anchors (Orders 1–20) |
| `00000000-0000-0000-0002-XXXXXXXXXXXX` | MPI context-aware + branch targets |
| `00000000-0000-0000-0003-XXXXXXXXXXXX` | Career Fit questions (Orders 1–18) |

### Seeding Pattern
In `AppDbContext.OnModelCreating`:
```csharp
entity.HasData(MpiSeed.Test);           // inside Test entity config
entity.HasData(CareerFitSeed.Test);
entity.HasData(MpiSeed.Questions);      // inside Question entity config
entity.HasData(CareerFitSeed.Questions);
```

### Migration Workflow
```bash
cd backend
dotnet ef migrations add <MigrationName> \
  --project MindScorePlatform.Infrastructure \
  --startup-project MindScorePlatform.WebApi
dotnet ef database update \
  --project MindScorePlatform.Infrastructure \
  --startup-project MindScorePlatform.WebApi
```

---

## Frontend Architecture

### State Management — Riverpod
- `testProvider` — `StateNotifier<TestState>` — drives the active test session
- `resultsProvider` — `StateNotifier<ResultsState>` — historical results
- `mpiResultProvider` — convenience provider for most recent MPI result
- `authProvider` — authentication state

### Routing — GoRouter (`router/app_router.dart`)
| Route | Screen | Notes |
|---|---|---|
| `/results` | `ResultsScreen` | MPI results |
| `/results/mindscore` | `MindScoreResultsScreen` | Cognitive results |
| `/results/career-fit` | `CareerFitResultsScreen` | Career Fit results |
| `/test/:testId` | `TestScreen` | Adaptive test runner |
| `/context-selection` | `ContextSelectionScreen` | Context picker |

### Result Routing Logic (`test_screen.dart`)
```dart
// _navigateToResults(typeCode, testName) — called when result arrives
typeCode == 'MIND_SCORE'                → /results/mindscore
testName == 'Career Fit Assessment'     → /results/career-fit
otherwise                               → /results (MPI)
```

### ResultModel Key Fields (auth_models.dart)
```dart
String id, testId, testName
double score
String? typeCode    // 'MIND_SCORE' | 4-letter MPI code | cluster code for Career Fit
String? typeName, emoji, tagline
dynamic dimensionScores    // shape varies by assessment
Map<String, dynamic>? insights
AssessmentContext context
Map<String, dynamic>? aiFollowUp
Map<String, dynamic>? contextInsights
```

### UI Standards — Project-Specific
- Colour palette from `core/constants/app_colors.dart` — never hardcode hex values
- Background: `AppColors.backgroundDark` (`0xFF150A28`)
- Cards: `AppColors.primaryMid` with `AppColors.cardBorder`
- Accent: `AppColors.accent` (`0xFF6B35C8`)
- All new screens must follow the existing dark-theme card pattern
- Animations via `flutter_animate` — use `.animate().fadeIn().slideY()` pattern

---

## API Reference

| Endpoint | Method | Auth | Purpose |
|---|---|---|---|
| `/api/auth/register` | POST | No | Register |
| `/api/auth/login` | POST | No | Login |
| `/api/auth/guest` | POST | No | Guest session |
| `/api/tests` | GET | Yes | List assessments |
| `/api/questions` | GET | Yes | Questions for test |
| `/api/questions/next` | POST | Yes | Adaptive engine |
| `/api/responses/submit` | POST | Yes | Submit + score |
| `/api/results` | GET | Yes | User history |
| `/api/results/{id}` | GET | Yes | Single result |
| `/api/results/{id}/follow-up` | POST | Yes | Submit MPI follow-up answers |
| `/api/users/me` | GET/PATCH | Yes | Profile |
| `/health` | GET | No | Health check |

---

## Configuration

### appsettings.json
```json
{
  "ConnectionStrings": { "Default": "" },
  "Jwt": { "Issuer": "", "Audience": "", "Key": "" },
  "Anthropic": { "ApiKey": "" },
  "Cors": { "AllowedOrigins": [] }
}
```

### Environment Variables (Render)
- `Anthropic__ApiKey` — double underscore = nested .NET config (⚠️ NOT YET SET as of 2026-04-18)

---

## AI Follow-Up System (MPI Only)

**When triggered:** After MPI scoring, if any dimension has Strength = "Slight" (deviation ≤10 from 50).

**Claude call:** `POST https://api.anthropic.com/v1/messages`
- Model: `claude-sonnet-4-6`, max_tokens: 1024, timeout: 10s
- Prompt includes: context label, age band, dimension scores, detected tensions
- N questions = number of tensions (not hardcoded)
- Any failure silently absorbed — result saves without follow-up

**Reclassification:** After user answers follow-up:
- Average DimensionImpact values per dimension (scale 1–5: 5=high pole, 1=low pole, 3=neutral)
- >3 = high pole wins, <3 = low pole wins, ≈3 = no change
- If vote contradicts current pole: `newPct = 100 − oldPct` (mirror, preserves Strength)
- Rebuild type code → re-fetch profile → 7-column `ExecuteUpdateAsync`

---

## Dev Servers

### Backend
```bash
dotnet run --project backend/MindScorePlatform.WebApi
# Port: 5041 | Swagger: http://localhost:5041/swagger
```

### Flutter Web
```bash
cd frontend/mindscore
/Users/nandan/CascadeProjects/windsurf-project/flutter/bin/flutter run \
  -d web-server --web-port 8080 --web-renderer html
# Open http://localhost:8080 in Chrome (preview tool cannot render Flutter)
```

---

## Commenting Standards — Project-Specific

- Every new service method: one-line summary of what it does and why it exists
- Every non-trivial algorithm step: inline comment on the WHY (e.g. `// mirror around 50 — preserves Strength classification, flips pole`)
- Every JSON column assignment: comment naming the schema (e.g. `// {code, name, emoji, fitPercentage} × top 3`)
- Seed data files: header comment block documenting GUID ranges and field conventions
- Never document what the variable name already says

---

## What NOT to Do

- Do not re-read `AppDbContext.cs`, `Question.cs`, `Result.cs`, `DependencyInjection.cs`, or any seed file to check column names or field shapes — it is in memory
- Do not explore the folder structure cold — it is in memory
- Do not ask Nandan for project context that can be found in memory or code
- Do not add features, refactor, or clean up code beyond what the task requires
- Do not leave a migration un-applied after writing it — always note when `dotnet ef database update` is needed

---

## Codebase Cleanup — April 2026

Six-track cleanup pass completed. Summary of every change made.

### Track 1 — Deduplication

**`JsonSerializerOptions` consolidated.**
A single `internal static readonly JsonSerializerOptions CamelCase` now lives in `ResultDtoMapper`. All pipelines and services reference `ResultDtoMapper.CamelCase`. Do NOT create new local copies.
Removed from: `MpiScoringPipeline`, `MindScoreScoringPipeline`, `CareerFitScoringPipeline`, `ResultService`, `AiFollowUpService`.

**`ClassifyStrength` consolidated.**
Canonical implementation is `TensionDetector.ClassifyStrength(double percentage)` (`internal static`). Returns `"Strong" | "Moderate" | "Slight"`. Do NOT duplicate this logic.
Removed private copies from: `MpiScoringEngine.Score()`, `ResultService`.

**`IResultRepository` pruned.**
Removed 3 dead interface members that no service ever called:
- `AddAsync` — responses are persisted via `IResponseRepository`, not here
- `UpdateFollowUpAsync` — follow-up reclassification uses `ExecuteUpdateAsync` directly
- `GetByUserAndTestAsync` — never called

Corresponding implementations removed from `ResultRepository.cs`.

---

### Track 2 — Type Consolidation

**`MpiDimensionScoreData` deleted.**
Was a duplicate of `MpiDimensionScore` defined inside `IMpiActionPlanEngine.cs`. Removed entirely.
All three affected files updated to use `MpiDimensionScore` (from `IMpiScoringEngine.cs`):
- `IMpiActionPlanEngine.Generate(...)` parameter type
- `IRelationshipInsightsGenerator.Generate(...)` parameter type
- `MpiActionPlanEngine.Generate(...)` implementation parameter type

---

### Track 3 — Dead Code (DEFERRED — not yet deleted)

Confirmed dead but left in place. Remove in a future session:

| File | Why dead |
|---|---|
| `Application/Interfaces/IRelationshipInsightsGenerator.cs` | Interface only — no implementation exists, no callers |
| `Application/Interfaces/IMpiActionPlanEngine.cs` | Interface — only DI registration, never injected into any service or controller |
| `Infrastructure/Services/Mpi/MpiActionPlanEngine.cs` | Implementation of the dead interface |
| `WebApi/Controllers/Mpi/MpiController.cs` | `POST /api/mpi/score` — frontend never calls `/api/mpi`, no test projects exist |
| `DependencyInjection.cs` line 38 | `AddSingleton<IMpiActionPlanEngine, MpiActionPlanEngine>()` — registers dead pair |

**Important:** The DI list in this file's "Dependency Injection" section still shows `IMpiActionPlanEngine` as a Singleton — this reflects the current code state, which includes the deferred dead code. Once the dead code is removed, update the DI list here too.

Action plan is generated **client-side** in Flutter (`lib/core/services/action_plan_service.dart`), not by the backend engine.

---

### Track 4 — Circular Dependencies

**No cycles found anywhere.** Full graph stored at `docs/dependency-graph.md`.
- Assembly graph is a strict DAG: Domain ← Application ← Infrastructure ← WebApi
- `Services/Mpi/` is a leaf namespace — it never imports from `Services/Scoring/` or `Services/`
- Flutter provider graph is a DAG: `core/* ← auth_provider ← results_provider ← mpi_result_provider`

---

### Track 5 — Type Strengthening

**C# — `object?` → `JsonElement?`**
`JsonSerializer.Deserialize<object>()` returns a `JsonElement` at runtime in .NET 5+. The static type now matches the runtime type. Zero wire-format impact.

Changed fields in `ResultDto`:
- `DimensionScores: JsonElement?`
- `Insights: JsonElement?`
- `ContextInsights: JsonElement?`
- `AiFollowUp: JsonElement?`
- `DimensionConfidence: JsonElement?`

Changed field in `QuestionDto`:
- `ScenarioOptions: JsonElement?`

Changed `Deserialize<object>()` → `Deserialize<JsonElement>()` call sites:
- `ResultDtoMapper.ToDto()` — local helper function
- `QuestionService.ToDto()` — ScenarioOptions
- `AdaptiveQuestionService.ToDto()` — ScenarioOptions

**⚠️ Update this file's `ResultModel Key Fields` section:**
Line `dynamic dimensionScores` is now `Object? dimensionScores` (see below).

**Dart — `dynamic` → `Object?`**
`ResultModel.dimensionScores` is now typed `Object?` (not `dynamic`).
At call sites: always cast explicitly before use — `model.dimensionScores as List<dynamic>` or `as Map<String, dynamic>`. The `as` operator works identically on `Object?`.

---

### Track 6 — Error Handling Cleanup

**Fixed silent failure in `mpi_share_modal.dart`.**

`_captureCard()` previously: `catch (_) { return null; }` — swallowed any render exception.
Both callers then did `if (bytes == null) return;` — user saw spinner disappear, no feedback.

Fix applied:
- `_captureCard()` — removed the `catch` block entirely. Exceptions now propagate.
- `_shareToPlaftorm()` — added `catch (_)` that shows `SnackBar('Failed to capture card. Please try again.')`.
- `_saveAsImage()` — added `catch (_)` that shows `SnackBar('Failed to save image. Please try again.')`.

All other try/catch blocks audited and confirmed legitimate:
- `AiFollowUpService` — `catch (Exception ex)` logs via `ILogger` and returns null. Documented boundary — Claude API failure must never break the main submit pipeline.
- All provider catches (`auth_provider`, `tests_provider`, `results_provider`, `test_provider`) — surface user-facing `error` state.
- All screen catches (`results_screen`, `history_screen`, `mpi_follow_up_screen`) — show SnackBar or `_error` field.

---

### Updated: ResultModel Key Fields (corrected from earlier section)

```dart
// auth_models.dart — CURRENT STATE after Track 5
Object? dimensionScores    // was: dynamic — now Object? (callers must cast explicitly)
Map<String, dynamic>? insights
AssessmentContext context
Map<String, dynamic>? aiFollowUp
Map<String, dynamic>? contextInsights
Map<String, dynamic>? dimensionConfidence
```

---

### Pre-existing Warnings (do not investigate these)

**Backend** — 4 `CS8604` nullable warnings in `ResultRepository.cs` (`ExecuteSqlRawAsync` params). Pre-existing, benign.

**Flutter** — `_kAccent` unused field in `mpi_share_modal.dart`; `prefer_const_constructors` infos across widget files; `withOpacity` deprecation hints. All pre-existing. Note: the Flutter 3.24.5 constraint (line 51 above) says to use `withOpacity()` — so the deprecation warnings are expected and intentional given the locked SDK version.
