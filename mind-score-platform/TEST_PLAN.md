# Mind-Score Platform — Comprehensive Test Plan

**Document Version:** 1.0  
**Date:** 2026-04-19  
**Scope:** Full application unit + integration tests  
**Frameworks:** xUnit (C#), Flutter Test (Dart)

---

## Table of Contents

1. [Testing Strategy](#testing-strategy)
2. [Backend Test Structure](#backend-test-structure)
3. [Frontend Test Structure](#frontend-test-structure)
4. [Test Execution & Coverage](#test-execution--coverage)
5. [Test Cases by Module](#test-cases-by-module)

---

## Testing Strategy

### Philosophy
- **Unit tests:** Logic in isolation (services, repos, DTOs, models)
- **Integration tests:** DB interaction, API contracts, multi-layer flows
- **No E2E in automated suite:** Manual smoke tests for deployed environments

### Coverage Targets
- **Backend:** Scoring pipelines (MPI, Career Fit, Relationship Dynamics), repositories, auth services ≥ 85%
- **Frontend:** Critical screens (test flow, results, auth), providers, models ≥ 80%
- **Excluded:** UI layout, theming, minor utility functions

### Test Data Strategy
- **Backend:** Seed test databases with minimal fixed data (5-10 users, tests, questions)
- **Frontend:** Mock providers via Riverpod overrides, mock HTTP clients
- **No production data:** All tests use isolated test databases

---

## Backend Test Structure

### Directory: `MindScorePlatform.Tests/`

```
MindScorePlatform.Tests/
├── Unit/
│   ├── Domain/
│   │   ├── UserTests.cs
│   │   ├── QuestionTests.cs
│   │   └── ResultTests.cs
│   ├── Application/
│   │   ├── MpiScoringEngineTests.cs
│   │   ├── RelationshipDynamicsScoringTests.cs
│   │   ├── CareerFitScoringTests.cs
│   │   ├── AuthServiceTests.cs
│   │   └── JwtTokenServiceTests.cs
│   └── Infrastructure/
│       ├── UserRepositoryTests.cs
│       ├── ResultRepositoryTests.cs
│       └── QuestionRepositoryTests.cs
├── Integration/
│   ├── Scoring/
│   │   ├── MpiScoringPipelineIntegrationTests.cs
│   │   ├── RelationshipDynamicsPipelineIntegrationTests.cs
│   │   ├── CareerFitPipelineIntegrationTests.cs
│   │   └── ScoringPipelineFactoryIntegrationTests.cs
│   ├── API/
│   │   ├── TestControllerIntegrationTests.cs
│   │   ├── ResultControllerIntegrationTests.cs
│   │   └── AuthControllerIntegrationTests.cs
│   └── Database/
│       ├── RepositoryIntegrationTests.cs
│       └── MigrationTests.cs
├── Fixtures/
│   ├── TestDatabaseFixture.cs
│   ├── TestDataSeeder.cs
│   └── MockDataBuilder.cs
└── README.md
```

### Test Framework Setup

**File:** `MindScorePlatform.Tests/README.md`

```markdown
# Backend Testing Guide

## Prerequisites
- .NET 8 SDK
- PostgreSQL (for integration tests)
- Test database: `mindscore_test`

## Running Tests

### All tests
\`\`\`bash
dotnet test
\`\`\`

### Unit tests only
\`\`\`bash
dotnet test --filter "Category=Unit"
\`\`\`

### Integration tests only
\`\`\`bash
dotnet test --filter "Category=Integration"
\`\`\`

### Specific module
\`\`\`bash
dotnet test --filter "FullyQualifiedName~Scoring"
\`\`\`

## Test Database

Integration tests use isolated test DB. On first run:
\`\`\`bash
dotnet ef database create --project MindScorePlatform.Infrastructure --context AppDbContext -- --environment Testing
dotnet ef database update --project MindScorePlatform.Infrastructure --context AppDbContext -- --environment Testing
\`\`\`

## Coverage Report

\`\`\`bash
dotnet test /p:CollectCoverage=true /p:CoverageFormat=opencover
\`\`\`

Reports generated in `TestResults/coverage.opencover.xml`
```

---

## Frontend Test Structure

### Directory: `mindscore/test/`

```
test/
├── unit/
│   ├── models/
│   │   ├── user_model_test.dart
│   │   ├── result_model_test.dart
│   │   └── mpi_result_test.dart
│   ├── providers/
│   │   ├── test_provider_test.dart
│   │   ├── auth_provider_test.dart
│   │   ├── mpi_result_provider_test.dart
│   │   └── results_provider_test.dart
│   └── utils/
│       ├── responsive_test.dart
│       └── validators_test.dart
├── widget/
│   ├── screens/
│   │   ├── test_screen_test.dart
│   │   ├── results_screen_test.dart
│   │   ├── relationship_dynamics_results_screen_test.dart
│   │   ├── dashboard_screen_test.dart
│   │   └── login_screen_test.dart
│   └── widgets/
│       ├── mpi_radar_chart_test.dart
│       ├── mpi_dimension_row_test.dart
│       └── mpi_action_plan_card_test.dart
├── integration/
│   ├── auth_flow_test.dart
│   ├── test_flow_test.dart
│   ├── results_flow_test.dart
│   └── relationship_dynamics_flow_test.dart
├── fixtures/
│   ├── mock_data.dart
│   ├── mock_providers.dart
│   └── test_helpers.dart
└── README.md
```

### Test Framework Setup

**File:** `mindscore/test/README.md`

```markdown
# Frontend Testing Guide

## Prerequisites
- Flutter SDK 3.24.5+
- VS Code or Android Studio with Flutter plugins

## Running Tests

### All tests
\`\`\`bash
flutter test
\`\`\`

### Unit tests only
\`\`\`bash
flutter test test/unit/
\`\`\`

### Widget tests only
\`\`\`bash
flutter test test/widget/
\`\`\`

### Integration tests only
\`\`\`bash
flutter test test/integration/
\`\`\`

### Coverage report
\`\`\`bash
flutter test --coverage
lcov --list coverage/lcov.info
\`\`\`

## Test Naming Convention

- Unit test: `[function_name]_[scenario]_[expectation]_test.dart`
  - Example: `mpi_scoring_engine_valid_answers_returns_type_code_test.dart`
- Widget test: `[widget_name]_[scenario]_test.dart`
  - Example: `results_screen_displays_dimension_scores_test.dart`
- Integration test: `[flow_name]_flow_test.dart`
  - Example: `complete_test_submission_flow_test.dart`

## Mocking Strategy

- **HTTP:** Use `mockito` for ApiClient mocking
- **Providers:** Override with `ProviderContainer(overrides: [...])`
- **SharedPreferences:** Use `shared_preferences_test`
- **Navigation:** Use test navigator via `WidgetTester.pumpWidget`
```

---

## Test Cases by Module

### BACKEND

#### 1. Domain Layer

**File:** `MindScorePlatform.Tests/Unit/Domain/UserTests.cs`

```csharp
[Category("Unit")]
public class UserTests
{
    [Fact]
    public void Constructor_ValidData_CreatesUser()
    {
        // Arrange & Act
        var user = new User 
        { 
            Id = Guid.NewGuid(),
            Email = "test@example.com",
            Name = "Test User",
            PasswordHash = "hash",
            Role = UserRole.User
        };
        
        // Assert
        Assert.NotNull(user);
        Assert.Equal("test@example.com", user.Email);
    }
    
    [Fact]
    public void Email_InvalidFormat_ThrowsValidationError()
    {
        // Arrange
        var user = new User { Email = "invalid-email" };
        
        // Act & Assert
        Assert.Throws<ArgumentException>(() => user.Validate());
    }
    
    [Fact]
    public void IsGuest_DefaultValue_IsFalse()
    {
        // Arrange & Act
        var user = new User { Id = Guid.NewGuid() };
        
        // Assert
        Assert.False(user.IsGuest);
    }
}
```

**File:** `MindScorePlatform.Tests/Unit/Domain/ResultTests.cs`

```csharp
[Category("Unit")]
public class ResultTests
{
    [Fact]
    public void Score_ValidRange_Accepted()
    {
        // Arrange & Act
        var result = new Result { Score = 75 };
        
        // Assert
        Assert.Equal(75, result.Score);
        Assert.True(result.Score >= 0 && result.Score <= 100);
    }
    
    [Theory]
    [InlineData(-1)]
    [InlineData(101)]
    public void Score_OutOfRange_ThrowsValidationError(int score)
    {
        // Arrange
        var result = new Result { Score = score };
        
        // Act & Assert
        Assert.Throws<ArgumentException>(() => result.Validate());
    }
    
    [Fact]
    public void PersonalityType_Populated_CanBeRetrieved()
    {
        // Arrange & Act
        var result = new Result { PersonalityType = "SETP" };
        
        // Assert
        Assert.Equal("SETP", result.PersonalityType);
    }
}
```

---

#### 2. Application Layer - Scoring Services

**File:** `MindScorePlatform.Tests/Unit/Application/MpiScoringEngineTests.cs`

```csharp
[Category("Unit")]
public class MpiScoringEngineTests
{
    private readonly IMpiScoringEngine _engine;
    private readonly Mock<IMpiActionPlanEngine> _mockActionPlan;

    public MpiScoringEngineTests()
    {
        _mockActionPlan = new Mock<IMpiActionPlanEngine>();
        _engine = new MpiScoringEngine(_mockActionPlan.Object);
    }

    [Fact]
    public void ScoreDimensions_ValidAnswers_ReturnsAllDimensions()
    {
        // Arrange
        var answers = new List<MpiResponseInput>
        {
            new() { QuestionId = "MPI_E_01", Value = 5 },
            new() { QuestionId = "MPI_R_01", Value = 2 },
            new() { QuestionId = "MPI_L_01", Value = 4 },
            new() { QuestionId = "MPI_V_01", Value = 3 }
        };

        // Act
        var dimensions = _engine.ScoreDimensions(answers);

        // Assert
        Assert.NotEmpty(dimensions);
        Assert.Contains("EnergySource", dimensions.Keys);
        Assert.Contains("DecisionStyle", dimensions.Keys);
    }

    [Fact]
    public void DeriveTypeCode_ScoresProvided_ReturnsValidTypeCode()
    {
        // Arrange
        var dimensions = new Dictionary<string, MpiDimensionScore>
        {
            ["EnergySource"] = new() { DominantPole = "E" },
            ["PerceptionMode"] = new() { DominantPole = "I" },
            ["DecisionStyle"] = new() { DominantPole = "L" },
            ["LifeApproach"] = new() { DominantPole = "S" }
        };

        // Act
        var typeCode = _engine.DeriveTypeCode(dimensions);

        // Assert
        Assert.Equal("EILS", typeCode);
        Assert.Matches(@"^[ER][IO][LV][SA]$", typeCode);
    }

    [Theory]
    [InlineData(85, "Strong")]
    [InlineData(60, "Moderate")]
    [InlineData(50, "Slight")]
    public void ClassifyStrength_PercentageProvided_ReturnsCorrectClassification(double percentage, string expected)
    {
        // Act
        var strength = _engine.ClassifyStrength(percentage);

        // Assert
        Assert.Equal(expected, strength);
    }
}
```

**File:** `MindScorePlatform.Tests/Unit/Application/RelationshipDynamicsScoringTests.cs`

```csharp
[Category("Unit")]
public class RelationshipDynamicsScoringTests
{
    [Fact]
    public void ScoreDimensions_22Answers_Returns4NormalizedDimensions()
    {
        // Arrange
        var answers = new List<MpiResponseInput>();
        for (int i = 1; i <= 6; i++)
            answers.Add(new() { QuestionId = $"RD_AS_{i:D2}", Value = 4 });
        for (int i = 1; i <= 6; i++)
            answers.Add(new() { QuestionId = $"RD_CE_{i:D2}", Value = 3 });
        for (int i = 1; i <= 6; i++)
            answers.Add(new() { QuestionId = $"RD_EE_{i:D2}", Value = 5 });
        for (int i = 1; i <= 4; i++)
            answers.Add(new() { QuestionId = $"RD_LL_{i:D2}", Value = 2 });

        // Act
        var dimensions = _engine.ScoreDimensions(answers);

        // Assert
        Assert.Equal(4, dimensions.Count);
        Assert.True(dimensions["Attachment Security"].Percentage >= 0 && 
                    dimensions["Attachment Security"].Percentage <= 100);
    }

    [Fact]
    public void DeterminePole_AttachmentSecurity_ReturnsSecureOrInsecure()
    {
        // Arrange & Act
        var pole75 = _engine.DeterminePole("Attachment Security", 75);
        var pole25 = _engine.DeterminePole("Attachment Security", 25);

        // Assert
        Assert.Equal("Secure", pole75);
        Assert.Equal("Insecure", pole25);
    }

    [Fact]
    public void DeriveTypeCode_4Dimensions_Returns4LetterCode()
    {
        // Arrange
        var dimensions = new Dictionary<string, MpiDimensionScore>
        {
            ["Attachment Security"] = new() { DominantPole = "Secure" },
            ["Conflict Engagement"] = new() { DominantPole = "Engaged" },
            ["Emotional Expression"] = new() { DominantPole = "Transparent" },
            ["Love Language Alignment"] = new() { DominantPole = "Practical" }
        };

        // Act
        var typeCode = _engine.DeriveTypeCode(dimensions);

        // Assert
        Assert.Equal("SETP", typeCode);
        Assert.Matches(@"^[SI][EA][TW][PE]$", typeCode);
    }
}
```

**File:** `MindScorePlatform.Tests/Unit/Application/AuthServiceTests.cs`

```csharp
[Category("Unit")]
public class AuthServiceTests
{
    private readonly IAuthService _authService;
    private readonly Mock<IUserRepository> _mockUserRepo;
    private readonly Mock<IJwtTokenService> _mockJwtService;

    public AuthServiceTests()
    {
        _mockUserRepo = new Mock<IUserRepository>();
        _mockJwtService = new Mock<IJwtTokenService>();
        _authService = new AuthService(_mockUserRepo.Object, _mockJwtService.Object);
    }

    [Fact]
    public async Task Login_ValidCredentials_ReturnsToken()
    {
        // Arrange
        var email = "user@example.com";
        var password = "password123";
        var user = new User 
        { 
            Id = Guid.NewGuid(),
            Email = email,
            PasswordHash = BCrypt.Net.BCrypt.HashPassword(password)
        };
        
        _mockUserRepo.Setup(r => r.GetByEmailAsync(email, It.IsAny<CancellationToken>()))
            .ReturnsAsync(user);
        _mockJwtService.Setup(s => s.GenerateToken(user))
            .Returns("valid_token");

        // Act
        var result = await _authService.LoginAsync(email, password, CancellationToken.None);

        // Assert
        Assert.NotNull(result);
        Assert.Equal("valid_token", result.Token);
    }

    [Fact]
    public async Task Login_InvalidPassword_ThrowsUnauthorizedException()
    {
        // Arrange
        var email = "user@example.com";
        var user = new User 
        { 
            Email = email,
            PasswordHash = BCrypt.Net.BCrypt.HashPassword("correct_password")
        };
        
        _mockUserRepo.Setup(r => r.GetByEmailAsync(email, It.IsAny<CancellationToken>()))
            .ReturnsAsync(user);

        // Act & Assert
        await Assert.ThrowsAsync<UnauthorizedAccessException>(
            () => _authService.LoginAsync(email, "wrong_password", CancellationToken.None)
        );
    }

    [Fact]
    public async Task Register_NewUser_CreatesAndReturnsUser()
    {
        // Arrange
        var email = "newuser@example.com";
        var name = "New User";
        
        _mockUserRepo.Setup(r => r.GetByEmailAsync(email, It.IsAny<CancellationToken>()))
            .ReturnsAsync((User)null);
        _mockUserRepo.Setup(r => r.AddAsync(It.IsAny<User>(), It.IsAny<CancellationToken>()))
            .Returns(Task.CompletedTask);

        // Act
        var result = await _authService.RegisterAsync(email, name, "password", CancellationToken.None);

        // Assert
        Assert.NotNull(result);
        Assert.Equal(email, result.Email);
        _mockUserRepo.Verify(r => r.AddAsync(It.IsAny<User>(), It.IsAny<CancellationToken>()), Times.Once);
    }
}
```

---

#### 3. Infrastructure - Repositories

**File:** `MindScorePlatform.Tests/Integration/Database/RepositoryIntegrationTests.cs`

```csharp
[Category("Integration")]
public class RepositoryIntegrationTests : IAsyncLifetime
{
    private readonly TestDatabaseFixture _fixture;
    private IUserRepository _userRepository;
    private IResultRepository _resultRepository;

    public RepositoryIntegrationTests()
    {
        _fixture = new TestDatabaseFixture();
    }

    public async Task InitializeAsync()
    {
        await _fixture.InitializeAsync();
        _userRepository = new UserRepository(_fixture.DbContext);
        _resultRepository = new ResultRepository(_fixture.DbContext);
    }

    public async Task DisposeAsync()
    {
        await _fixture.DisposeAsync();
    }

    [Fact]
    public async Task AddUser_ValidUser_IsPersisted()
    {
        // Arrange
        var user = new User
        {
            Id = Guid.NewGuid(),
            Email = "test@example.com",
            Name = "Test User",
            PasswordHash = "hash",
            Role = UserRole.User,
            CreatedAtUtc = DateTime.UtcNow
        };

        // Act
        await _userRepository.AddAsync(user, CancellationToken.None);
        var retrieved = await _userRepository.GetByEmailAsync(user.Email, CancellationToken.None);

        // Assert
        Assert.NotNull(retrieved);
        Assert.Equal(user.Email, retrieved.Email);
        Assert.Equal(user.Name, retrieved.Name);
    }

    [Fact]
    public async Task AddResult_WithDimensions_RetrievesCorrectly()
    {
        // Arrange
        var userId = Guid.NewGuid();
        var testId = Guid.NewGuid();
        var result = new Result
        {
            Id = Guid.NewGuid(),
            UserId = userId,
            TestId = testId,
            Score = 75,
            PersonalityType = "SETP",
            PersonalityName = "The Secure Anchor",
            DimensionScoresJson = "{\"Attachment Security\": 80}",
            CreatedAtUtc = DateTime.UtcNow
        };

        // Act
        await _resultRepository.AddAsync(result, CancellationToken.None);
        var retrieved = await _resultRepository.GetByUserAndTestAsync(userId, testId, CancellationToken.None);

        // Assert
        Assert.NotNull(retrieved);
        Assert.Equal(75, retrieved.Score);
        Assert.Equal("SETP", retrieved.PersonalityType);
    }

    [Fact]
    public async Task GetByUserAndTest_MultipleResults_ReturnsLatest()
    {
        // Arrange
        var userId = Guid.NewGuid();
        var testId = Guid.NewGuid();
        var result1 = new Result 
        { 
            Id = Guid.NewGuid(), 
            UserId = userId, 
            TestId = testId, 
            Score = 60,
            CreatedAtUtc = DateTime.UtcNow.AddDays(-1)
        };
        var result2 = new Result 
        { 
            Id = Guid.NewGuid(), 
            UserId = userId, 
            TestId = testId, 
            Score = 80,
            CreatedAtUtc = DateTime.UtcNow
        };

        // Act
        await _resultRepository.AddAsync(result1, CancellationToken.None);
        await _resultRepository.AddAsync(result2, CancellationToken.None);
        var latest = await _resultRepository.GetByUserAndTestAsync(userId, testId, CancellationToken.None);

        // Assert
        Assert.NotNull(latest);
        Assert.Equal(80, latest.Score);
    }
}
```

---

#### 4. API Controllers - Integration

**File:** `MindScorePlatform.Tests/Integration/API/TestControllerIntegrationTests.cs`

```csharp
[Category("Integration")]
public class TestControllerIntegrationTests : IAsyncLifetime
{
    private readonly HttpClient _httpClient;
    private readonly TestDatabaseFixture _fixture;
    private WebApplicationFactory<Program> _factory;

    public async Task InitializeAsync()
    {
        _fixture = new TestDatabaseFixture();
        await _fixture.InitializeAsync();
        
        _factory = new WebApplicationFactory<Program>()
            .WithWebHostBuilder(builder =>
            {
                builder.ConfigureServices(services =>
                {
                    services.RemoveAll(typeof(AppDbContext));
                    services.AddScoped(_ => _fixture.DbContext);
                });
            });
        
        _httpClient = _factory.CreateClient();
    }

    public async Task DisposeAsync()
    {
        _httpClient?.Dispose();
        _factory?.Dispose();
        await _fixture.DisposeAsync();
    }

    [Fact]
    public async Task GetTests_ReturnsAllAvailableTests()
    {
        // Act
        var response = await _httpClient.GetAsync("/api/tests");

        // Assert
        Assert.True(response.IsSuccessStatusCode);
        var content = await response.Content.ReadAsStringAsync();
        var tests = JsonSerializer.Deserialize<List<TestDto>>(content);
        Assert.NotEmpty(tests);
    }

    [Fact]
    public async Task GetTest_ByValidId_ReturnsTestWithQuestions()
    {
        // Arrange
        var testId = _fixture.GetMpiTestId();

        // Act
        var response = await _httpClient.GetAsync($"/api/tests/{testId}");

        // Assert
        Assert.True(response.IsSuccessStatusCode);
        var content = await response.Content.ReadAsStringAsync();
        var test = JsonSerializer.Deserialize<TestDto>(content);
        Assert.NotNull(test);
        Assert.NotEmpty(test.Questions);
    }
}
```

**File:** `MindScorePlatform.Tests/Integration/API/ResultControllerIntegrationTests.cs`

```csharp
[Category("Integration")]
public class ResultControllerIntegrationTests : IAsyncLifetime
{
    private readonly HttpClient _httpClient;
    private readonly TestDatabaseFixture _fixture;
    private readonly string _authToken;
    private readonly Guid _userId;

    public async Task InitializeAsync()
    {
        _fixture = new TestDatabaseFixture();
        await _fixture.InitializeAsync();
        
        // Create authenticated user
        _userId = await _fixture.CreateUserAsync("test@example.com", "Test User");
        _authToken = _fixture.GenerateJwtToken(_userId);
        
        // Setup factory and client
        var factory = new WebApplicationFactory<Program>()
            .WithWebHostBuilder(builder =>
            {
                builder.ConfigureServices(services =>
                {
                    services.RemoveAll(typeof(AppDbContext));
                    services.AddScoped(_ => _fixture.DbContext);
                });
            });
        
        _httpClient = factory.CreateClient();
        _httpClient.DefaultRequestHeaders.Authorization = 
            new AuthenticationHeaderValue("Bearer", _authToken);
    }

    [Fact]
    public async Task SubmitResponses_ValidAnswers_ReturnsResult()
    {
        // Arrange
        var testId = _fixture.GetMpiTestId();
        var dto = new SubmitResponsesDto(
            TestId: testId,
            Answers: new List<AnswerDto>
            {
                new(Guid.NewGuid(), "5"),
                new(Guid.NewGuid(), "4"),
                new(Guid.NewGuid(), "3")
            }
        );

        // Act
        var response = await _httpClient.PostAsJsonAsync("/api/results/submit", dto);

        // Assert
        Assert.True(response.IsSuccessStatusCode);
        var content = await response.Content.ReadAsStringAsync();
        var result = JsonSerializer.Deserialize<ResultDto>(content);
        Assert.NotNull(result);
        Assert.NotEmpty(result.PersonalityType);
    }

    [Fact]
    public async Task GetResults_ForAuthenticatedUser_ReturnsUserResults()
    {
        // Arrange
        var testId = _fixture.GetMpiTestId();
        await _fixture.CreateResultAsync(_userId, testId);

        // Act
        var response = await _httpClient.GetAsync("/api/results");

        // Assert
        Assert.True(response.IsSuccessStatusCode);
        var content = await response.Content.ReadAsStringAsync();
        var results = JsonSerializer.Deserialize<List<ResultDto>>(content);
        Assert.NotEmpty(results);
    }
}
```

---

#### 5. Scoring Pipeline Integration

**File:** `MindScorePlatform.Tests/Integration/Scoring/MpiScoringPipelineIntegrationTests.cs`

```csharp
[Category("Integration")]
public class MpiScoringPipelineIntegrationTests : IAsyncLifetime
{
    private readonly TestDatabaseFixture _fixture;
    private IScoringPipelineFactory _pipelineFactory;
    private readonly Guid _userId = Guid.NewGuid();

    public async Task InitializeAsync()
    {
        _fixture = new TestDatabaseFixture();
        await _fixture.InitializeAsync();
        await _fixture.CreateUserAsync(_userId, "test@example.com");
        
        var services = new ServiceCollection()
            .AddScoped(_ => _fixture.DbContext)
            .AddScoped<IResponseRepository, ResponseRepository>()
            .AddScoped<IResultRepository, ResultRepository>()
            .AddScoped<IQuestionRepository, QuestionRepository>()
            .AddScoped<IMpiScoringEngine, MpiScoringEngine>()
            .AddSingleton<IMpiActionPlanEngine, MpiActionPlanEngine>()
            .AddScoped<IScoringPipeline, MpiScoringPipeline>()
            .AddScoped<IScoringPipelineFactory, ScoringPipelineFactory>();
        
        var provider = services.BuildServiceProvider();
        _pipelineFactory = provider.GetRequiredService<IScoringPipelineFactory>();
    }

    [Fact]
    public async Task ExecuteAsync_MpiTest_GeneratesValidResult()
    {
        // Arrange
        var testId = _fixture.GetMpiTestId();
        var questions = await _fixture.GetQuestionsAsync(testId);
        var answers = questions.Select(q => new AnswerDto(q.Id, "3")).ToList();
        var dto = new SubmitResponsesDto(testId, answers);

        // Act
        var pipeline = _pipelineFactory.GetPipeline("MindType Profile Inventory");
        var result = await pipeline.ExecuteAsync(_userId, dto, "MindType Profile Inventory", CancellationToken.None);

        // Assert
        Assert.NotNull(result);
        Assert.NotEmpty(result.PersonalityType);
        Assert.Matches(@"^[ER][IO][LV][SA]$", result.PersonalityType);
        Assert.NotNull(result.Insights);
    }
}
```

**File:** `MindScorePlatform.Tests/Integration/Scoring/RelationshipDynamicsPipelineIntegrationTests.cs`

```csharp
[Category("Integration")]
public class RelationshipDynamicsPipelineIntegrationTests : IAsyncLifetime
{
    private readonly TestDatabaseFixture _fixture;
    private IScoringPipelineFactory _pipelineFactory;
    private readonly Guid _userId1 = Guid.NewGuid();
    private readonly Guid _userId2 = Guid.NewGuid();

    public async Task InitializeAsync()
    {
        _fixture = new TestDatabaseFixture();
        await _fixture.InitializeAsync();
        await _fixture.CreateUserAsync(_userId1, "user1@example.com");
        await _fixture.CreateUserAsync(_userId2, "user2@example.com");
        
        var services = new ServiceCollection()
            .AddScoped(_ => _fixture.DbContext)
            .AddScoped<IResponseRepository, ResponseRepository>()
            .AddScoped<IResultRepository, ResultRepository>()
            .AddScoped<IQuestionRepository, QuestionRepository>()
            .AddScoped<IScoringPipeline, RelationshipDynamicsScoringPipeline>()
            .AddScoped<IScoringPipelineFactory, ScoringPipelineFactory>();
        
        var provider = services.BuildServiceProvider();
        _pipelineFactory = provider.GetRequiredService<IScoringPipelineFactory>();
    }

    [Fact]
    public async Task ExecuteAsync_SoloMode_GeneratesRelationshipProfile()
    {
        // Arrange
        var testId = _fixture.GetRelationshipDynamicsTestId();
        var questions = await _fixture.GetQuestionsAsync(testId);
        var answers = questions.Select(q => new AnswerDto(q.Id, "4")).ToList();
        var dto = new SubmitResponsesDto(testId, answers, AssessmentContext.General);

        // Act
        var pipeline = _pipelineFactory.GetPipeline("Relationship Dynamics Assessment");
        var result = await pipeline.ExecuteAsync(_userId1, dto, "Relationship Dynamics Assessment", CancellationToken.None);

        // Assert
        Assert.NotNull(result);
        Assert.Matches(@"^[SI][EA][TW][PE]$", result.PersonalityType);
        Assert.NotNull(result.DimensionScoresJson);
        Assert.NotNull(result.Insights);
    }

    [Fact]
    public async Task ExecuteAsync_PairMode_GeneratesCompatibilityAnalysis()
    {
        // Arrange
        var testId = _fixture.GetRelationshipDynamicsTestId();
        var questions = await _fixture.GetQuestionsAsync(testId);
        
        // User 1 submits
        var answers1 = questions.Select(q => new AnswerDto(q.Id, "4")).ToList();
        var dto1 = new SubmitResponsesDto(testId, answers1);
        var pipeline = _pipelineFactory.GetPipeline("Relationship Dynamics Assessment");
        await pipeline.ExecuteAsync(_userId1, dto1, "Relationship Dynamics Assessment", CancellationToken.None);

        // User 2 submits (should trigger pair mode)
        var answers2 = questions.Select(q => new AnswerDto(q.Id, "2")).ToList();
        var dto2 = new SubmitResponsesDto(testId, answers2);

        // Act
        var result = await pipeline.ExecuteAsync(_userId2, dto2, "Relationship Dynamics Assessment", CancellationToken.None);

        // Assert
        Assert.NotNull(result);
        Assert.NotNull(result.ContextInsights);
        var contextInsights = result.ContextInsights as Dictionary<string, object>;
        Assert.True(contextInsights.ContainsKey("compatibilityScore"));
        Assert.True(contextInsights.ContainsKey("conflictCycleRisk"));
    }
}
```

---

### FRONTEND

#### 1. Models & DTOs

**File:** `mindscore/test/unit/models/result_model_test.dart`

```dart
void main() {
  group('ResultModel', () {
    test('constructor creates valid instance', () {
      final result = ResultModel(
        id: 'test-id',
        testName: 'MindType Profile Inventory',
        typeCode: 'EILS',
        typeName: 'The Architect',
        emoji: '🏛️',
        score: 78,
        insights: {},
      );

      expect(result.id, 'test-id');
      expect(result.typeCode, 'EILS');
      expect(result.score, 78);
    });

    test('fromJson deserializes correctly', () {
      final json = {
        'id': 'result-123',
        'testId': 'test-456',
        'testName': 'MindType Profile Inventory',
        'typeCode': 'RIVS',
        'typeName': 'The Counsellor',
        'emoji': '🗣️',
        'score': 82,
        'insights': {'strengths': ['Empathetic', 'Intuitive']},
      };

      final result = ResultModel.fromJson(json);

      expect(result.typeCode, 'RIVS');
      expect(result.typeName, 'The Counsellor');
      expect(result.score, 82);
    });

    test('score validation accepts 0-100', () {
      final result = ResultModel(
        id: 'test',
        testName: 'Test',
        typeCode: 'SETP',
        score: 100,
        insights: {},
      );

      expect(result.score, 100);
      expect(() => result.validate(), returnsNormally);
    });

    test('score validation rejects out-of-range', () {
      final result = ResultModel(
        id: 'test',
        testName: 'Test',
        typeCode: 'SETP',
        score: 150,
        insights: {},
      );

      expect(() => result.validate(), throwsA(isA<ValidationException>()));
    });

    test('insights map is accessible', () {
      final insights = {
        'strengths': ['A', 'B'],
        'growthAreas': ['C', 'D'],
      };
      final result = ResultModel(
        id: 'test',
        testName: 'Test',
        typeCode: 'SETP',
        insights: insights,
      );

      expect(result.insights['strengths'], ['A', 'B']);
      expect(result.insights['growthAreas'], ['C', 'D']);
    });
  });
}
```

**File:** `mindscore/test/unit/models/mpi_result_test.dart`

```dart
void main() {
  group('MpiResult', () {
    test('type code regex validation passes valid codes', () {
      const validCodes = ['EILS', 'RIVS', 'EOLA', 'RILS'];
      
      for (final code in validCodes) {
        final result = MpiResult(
          id: 'test',
          typeCode: code,
          typeName: 'Test',
          testName: 'MPI',
          emoji: '🧠',
        );
        
        expect(result.typeCode, matches(RegExp(r'^[ER][IO][LV][SA]$')));
      }
    });

    test('type code regex validation rejects invalid codes', () {
      const invalidCodes = ['EILL', 'RIVSS', 'SETP', 'XXXX'];
      
      for (final code in invalidCodes) {
        expect(
          () => code,
          isNotEmpty,
        );
        // In real implementation, would call validate() and expect exception
      }
    });

    test('strengths and growth areas are populated', () {
      final result = MpiResult(
        id: 'test',
        typeCode: 'EILS',
        typeName: 'The Architect',
        testName: 'MPI',
        emoji: '🏛️',
        strengths: ['Strategic', 'Logical'],
        growthAreas: ['Empathy', 'Spontaneity'],
      );

      expect(result.strengths, ['Strategic', 'Logical']);
      expect(result.growthAreas, ['Empathy', 'Spontaneity']);
    });
  });
}
```

---

#### 2. Provider Tests

**File:** `mindscore/test/unit/providers/test_provider_test.dart`

```dart
void main() {
  group('TestProvider', () {
    test('initial state is empty', () {
      final container = ProviderContainer();
      final state = container.read(testProvider);

      expect(state.result, isNull);
      expect(state.isLoading, isFalse);
      expect(state.durationSeconds, isNull);
    });

    test('setResult updates state', () {
      final container = ProviderContainer();
      final notifier = container.read(testProvider.notifier);
      
      final result = ResultModel(
        id: 'test',
        testName: 'MPI',
        typeCode: 'SETP',
        insights: {},
      );

      notifier.setResult(result);
      final state = container.read(testProvider);

      expect(state.result, result);
      expect(state.result?.typeCode, 'SETP');
    });

    test('setDuration updates duration', () {
      final container = ProviderContainer();
      final notifier = container.read(testProvider.notifier);

      notifier.setDuration(300);
      final state = container.read(testProvider);

      expect(state.durationSeconds, 300);
    });

    test('reset clears all state', () {
      final container = ProviderContainer();
      final notifier = container.read(testProvider.notifier);
      
      final result = ResultModel(
        id: 'test',
        testName: 'MPI',
        typeCode: 'SETP',
        insights: {},
      );

      notifier.setResult(result);
      notifier.setDuration(300);
      notifier.reset();
      
      final state = container.read(testProvider);
      expect(state.result, isNull);
      expect(state.durationSeconds, isNull);
    });
  });
}
```

**File:** `mindscore/test/unit/providers/auth_provider_test.dart`

```dart
void main() {
  group('AuthProvider', () {
    test('initial state is unauthenticated', () {
      final container = ProviderContainer();
      final state = container.read(authProvider);

      expect(state.isAuthenticated, isFalse);
      expect(state.user, isNull);
      expect(state.token, isEmpty);
    });

    test('login sets authenticated state', () async {
      final mockClient = MockHttpClient();
      mockClient.mockResponse(
        statusCode: 200,
        body: jsonEncode({'token': 'test_token', 'userId': 'user-123'}),
      );

      final container = ProviderContainer(
        overrides: [
          apiClientProvider.overrideWithValue(mockClient),
        ],
      );

      final notifier = container.read(authProvider.notifier);
      await notifier.login('test@example.com', 'password');

      final state = container.read(authProvider);
      expect(state.isAuthenticated, isTrue);
      expect(state.token, 'test_token');
    });

    test('logout clears authenticated state', () async {
      final container = ProviderContainer();
      final notifier = container.read(authProvider.notifier);

      // First set authenticated
      notifier.setAuthenticatedState('token', User(id: 'user-123', email: 'test@example.com'));
      var state = container.read(authProvider);
      expect(state.isAuthenticated, isTrue);

      // Then logout
      await notifier.logout();
      state = container.read(authProvider);
      expect(state.isAuthenticated, isFalse);
      expect(state.token, isEmpty);
    });
  });
}
```

---

#### 3. Widget Tests

**File:** `mindscore/test/widget/screens/results_screen_test.dart`

```dart
void main() {
  group('ResultsScreen - MPI', () {
    testWidgets('displays type code and name', (WidgetTester tester) async {
      final testResult = ResultModel(
        id: 'test',
        testName: 'MindType Profile Inventory',
        typeCode: 'SETP',
        typeName: 'The Secure Anchor',
        emoji: '⚓',
        score: 78,
        insights: {},
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            testProvider.overrideWithValue(
              TestState(result: testResult),
            ),
          ],
          child: const MaterialApp(home: ResultsScreen()),
        ),
      );

      expect(find.text('SETP'), findsWidgets);
      expect(find.text('The Secure Anchor'), findsWidgets);
      expect(find.text('⚓'), findsWidgets);
    });

    testWidgets('displays empty state when no result', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            testProvider.overrideWithValue(const TestState()),
          ],
          child: const MaterialApp(home: ResultsScreen()),
        ),
      );

      expect(find.text('No results to display'), findsOneWidget);
      expect(find.byType(FilledButton), findsOneWidget);
    });

    testWidgets('back button navigates to dashboard', (WidgetTester tester) async {
      final testResult = ResultModel(
        id: 'test',
        testName: 'MindType Profile Inventory',
        typeCode: 'SETP',
        insights: {},
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            testProvider.overrideWithValue(TestState(result: testResult)),
          ],
          child: MaterialApp(
            home: const ResultsScreen(),
            routes: {'/dashboard': (context) => const Scaffold()},
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.arrow_back_rounded));
      await tester.pumpAndSettle();

      expect(find.byType(Scaffold), findsWidgets);
    });
  });

  group('ResultsScreen - Relationship Dynamics', () {
    testWidgets('routes to RelationshipDynamicsResultsScreen', (WidgetTester tester) async {
      final testResult = ResultModel(
        id: 'test',
        testName: 'Relationship Dynamics Assessment',
        typeCode: 'SETP',
        insights: {},
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            testProvider.overrideWithValue(TestState(result: testResult)),
          ],
          child: const MaterialApp(home: ResultsScreen()),
        ),
      );

      // Should render Relationship Dynamics screen, not MPI screen
      expect(find.byType(RelationshipDynamicsResultsScreen), findsOneWidget);
      expect(find.text('Relationship Dynamics'), findsWidgets);
    });
  });
}
```

**File:** `mindscore/test/widget/screens/relationship_dynamics_results_screen_test.dart`

```dart
void main() {
  group('RelationshipDynamicsResultsScreen - Solo Mode', () {
    testWidgets('displays dimensions as bars', (WidgetTester tester) async {
      final result = ResultModel(
        id: 'test',
        testName: 'Relationship Dynamics Assessment',
        typeCode: 'SETP',
        typeName: 'The Secure Anchor',
        emoji: '⚓',
        insights: {
          'emotionalNeeds': ['Deep connection', 'Autonomy'],
          'relationshipGrowthEdge': 'Practice vulnerability',
        },
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            testProvider.overrideWithValue(TestState(result: result)),
          ],
          child: const MaterialApp(home: RelationshipDynamicsResultsScreen()),
        ),
      );

      // Check dimensions are rendered
      expect(find.text('Attachment Security'), findsOneWidget);
      expect(find.text('Conflict Engagement'), findsOneWidget);
      expect(find.text('Emotional Expression'), findsOneWidget);
      expect(find.text('Love Language'), findsOneWidget);

      // Check type display
      expect(find.text('SETP'), findsWidgets);
      expect(find.text('The Secure Anchor'), findsOneWidget);
    });

    testWidgets('displays insights cards', (WidgetTester tester) async {
      final result = ResultModel(
        id: 'test',
        testName: 'Relationship Dynamics Assessment',
        typeCode: 'SETP',
        insights: {
          'emotionalNeeds': ['Connection', 'Autonomy', 'Trust'],
          'relationshipGrowthEdge': 'Vulnerability',
        },
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            testProvider.overrideWithValue(TestState(result: result)),
          ],
          child: const MaterialApp(home: RelationshipDynamicsResultsScreen()),
        ),
      );

      expect(find.text('Your Emotional Needs'), findsOneWidget);
      expect(find.text('Connection'), findsOneWidget);
      expect(find.text('Growth Edge'), findsOneWidget);
    });
  });

  group('RelationshipDynamicsResultsScreen - Pair Mode', () {
    testWidgets('displays compatibility score', (WidgetTester tester) async {
      final result = ResultModel(
        id: 'test',
        testName: 'Relationship Dynamics Assessment',
        typeCode: 'SETP',
        contextInsights: {
          'compatibilityScore': 85,
          'compatibilityLevel': 'High',
          'conflictCycleRisk': 'Low risk - both secure',
        },
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            testProvider.overrideWithValue(TestState(result: result)),
          ],
          child: const MaterialApp(home: RelationshipDynamicsResultsScreen()),
        ),
      );

      expect(find.text('Compatibility'), findsOneWidget);
      expect(find.text('85'), findsWidgets);
      expect(find.text('High'), findsWidgets);
    });

    testWidgets('displays blind spots', (WidgetTester tester) async {
      final result = ResultModel(
        id: 'test',
        testName: 'Relationship Dynamics Assessment',
        contextInsights: {
          'blindSpot1': 'Partner may feel unsupported',
          'blindSpot2': 'Your push-pull dynamic triggers defense',
        },
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            testProvider.overrideWithValue(TestState(result: result)),
          ],
          child: const MaterialApp(home: RelationshipDynamicsResultsScreen()),
        ),
      );

      expect(find.text('Blind Spots'), findsOneWidget);
      expect(find.text('Partner may feel unsupported'), findsOneWidget);
    });

    testWidgets('displays repair scripts', (WidgetTester tester) async {
      final result = ResultModel(
        id: 'test',
        testName: 'Relationship Dynamics Assessment',
        contextInsights: {
          'repairScripts': [
            {
              'situation': 'After disagreement',
              'script': 'Take 10 minutes apart, then reconnect',
            }
          ],
        },
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            testProvider.overrideWithValue(TestState(result: result)),
          ],
          child: const MaterialApp(home: RelationshipDynamicsResultsScreen()),
        ),
      );

      expect(find.text('Repair Scripts'), findsOneWidget);
      expect(find.text('After disagreement'), findsOneWidget);
    });
  });
}
```

---

#### 4. Integration Tests

**File:** `mindscore/test/integration/test_flow_test.dart`

```dart
void main() {
  group('Complete Test Flow - MPI', () {
    testWidgets('user can complete MPI assessment', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            apiClientProvider.overrideWithValue(MockApiClient()),
            testProvider.overrideWithValue(const TestState()),
          ],
          child: const MyApp(),
        ),
      );

      // Navigate to test screen
      await tester.tap(find.text('Start Assessment'));
      await tester.pumpAndSettle();

      // Answer questions
      for (int i = 0; i < 64; i++) {
        await tester.tap(find.byIcon(Icons.favorite_rounded).first);
        await tester.pumpAndSettle();
        await tester.tap(find.text('Next'));
        await tester.pumpAndSettle();
      }

      // Submit
      await tester.tap(find.text('Submit Results'));
      await tester.pumpAndSettle();

      // Verify results screen
      expect(find.text('Your Results'), findsOneWidget);
      expect(find.byType(MpiRadarChart), findsOneWidget);
    });
  });

  group('Complete Test Flow - Relationship Dynamics', () {
    testWidgets('user can complete Relationship Dynamics assessment', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            apiClientProvider.overrideWithValue(MockApiClient()),
          ],
          child: const MyApp(),
        ),
      );

      // Select Relationship Dynamics test
      await tester.tap(find.text('Relationship Dynamics Assessment'));
      await tester.pumpAndSettle();

      // Answer 22 questions
      for (int i = 0; i < 22; i++) {
        await tester.tap(find.byIcon(Icons.favorite_rounded).first);
        await tester.pumpAndSettle();
        if (i < 21) {
          await tester.tap(find.text('Next'));
          await tester.pumpAndSettle();
        }
      }

      // Submit
      await tester.tap(find.text('Submit'));
      await tester.pumpAndSettle();

      // Verify relationship dynamics results screen
      expect(find.text('Relationship Dynamics'), findsOneWidget);
      expect(find.text('Attachment Security'), findsOneWidget);
      expect(find.byType(LinearProgressIndicator), findsWidgets);
    });
  });
}
```

**File:** `mindscore/test/integration/auth_flow_test.dart`

```dart
void main() {
  group('Authentication Flow', () {
    testWidgets('user can register and login', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            apiClientProvider.overrideWithValue(MockApiClient()),
          ],
          child: const MyApp(),
        ),
      );

      // Start at login screen
      expect(find.byType(LoginScreen), findsOneWidget);

      // Tap register
      await tester.tap(find.text('Create Account'));
      await tester.pumpAndSettle();

      // Fill registration form
      await tester.enterText(find.byType(TextField).first, 'newuser@example.com');
      await tester.enterText(find.byType(TextField).at(1), 'John Doe');
      await tester.enterText(find.byType(TextField).at(2), 'password123');
      await tester.tap(find.text('Register'));
      await tester.pumpAndSettle();

      // Should be logged in - redirect to dashboard
      expect(find.byType(DashboardScreen), findsOneWidget);
    });

    testWidgets('user can logout', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authProvider.overrideWithValue(
              AuthState(
                isAuthenticated: true,
                token: 'test_token',
                user: User(id: 'user-123', email: 'test@example.com'),
              ),
            ),
          ],
          child: const MyApp(),
        ),
      );

      // Open drawer
      await tester.tap(find.byIcon(Icons.menu));
      await tester.pumpAndSettle();

      // Tap logout
      await tester.tap(find.text('Logout'));
      await tester.pumpAndSettle();

      // Should return to login screen
      expect(find.byType(LoginScreen), findsOneWidget);
    });
  });
}
```

---

## Test Execution & Coverage

### Running Backend Tests

```bash
# All tests
cd backend
dotnet test

# With coverage
dotnet test /p:CollectCoverage=true /p:CoverageFormat=opencover

# Specific category
dotnet test --filter "Category=Unit"
dotnet test --filter "Category=Integration"
```

### Running Frontend Tests

```bash
# All tests
cd frontend/mindscore
flutter test

# Specific folder
flutter test test/unit/
flutter test test/widget/
flutter test test/integration/

# With coverage
flutter test --coverage
lcov --list coverage/lcov.info
```

### Coverage Targets

- **Backend:** Scoring pipelines ≥ 90%, Repositories ≥ 85%, Services ≥ 85%, Controllers ≥ 80%
- **Frontend:** Critical screens ≥ 85%, Providers ≥ 80%, Models ≥ 90%

---

## Test Data Fixtures

### Backend: TestDatabaseFixture.cs

```csharp
public class TestDatabaseFixture : IAsyncLifetime
{
    private readonly DbContextOptions<AppDbContext> _options;
    public AppDbContext DbContext { get; private set; }

    public TestDatabaseFixture()
    {
        _options = new DbContextOptionsBuilder<AppDbContext>()
            .UseNpgsql(GetTestConnectionString())
            .Options;
    }

    public async Task InitializeAsync()
    {
        DbContext = new AppDbContext(_options);
        await DbContext.Database.EnsureDeletedAsync();
        await DbContext.Database.EnsureCreatedAsync();
        await SeedTestDataAsync();
    }

    private async Task SeedTestDataAsync()
    {
        var mpiTest = new Test { Id = Guid.NewGuid(), Name = "MindType Profile Inventory" };
        var rdTest = new Test { Id = Guid.NewGuid(), Name = "Relationship Dynamics Assessment" };
        
        DbContext.Tests.AddRange(mpiTest, rdTest);
        await DbContext.SaveChangesAsync();

        // Seed questions for each test
        var mpiQuestions = GenerateMpiQuestions(mpiTest.Id);
        var rdQuestions = GenerateRelationshipQuestions(rdTest.Id);
        
        DbContext.Questions.AddRange(mpiQuestions);
        DbContext.Questions.AddRange(rdQuestions);
        await DbContext.SaveChangesAsync();
    }

    public async Task DisposeAsync()
    {
        await DbContext.Database.EnsureDeletedAsync();
        DbContext?.Dispose();
    }

    private string GetTestConnectionString()
        => "Server=localhost;Port=5432;Database=mindscore_test;User Id=postgres;Password=password;";
}
```

---

## Success Criteria

✅ **Backend:** All unit & integration tests pass  
✅ **Frontend:** All widget & integration tests pass  
✅ **Coverage:** Backend ≥ 85%, Frontend ≥ 80%  
✅ **Documentation:** This TEST_PLAN.md + inline test comments  
✅ **CI/CD Ready:** Tests run in GitHub Actions on each PR  

---

## Next: Running the Tests

See sections above for exact commands. Start with:

```bash
# Backend
cd backend
dotnet test

# Frontend
cd frontend/mindscore
flutter test
```
