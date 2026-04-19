using System.Text;
using System.Text.Json;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Logging;
using MindScorePlatform.Application.DTOs;
using MindScorePlatform.Application.Interfaces;
using MindScorePlatform.Domain.Enums;
using MindScorePlatform.Infrastructure.Services.Mpi;

namespace MindScorePlatform.Infrastructure.Services;

/// <summary>
/// Calls the Claude API to generate targeted follow-up questions for ambiguous
/// MPI dimension scores detected by <see cref="TensionDetector"/>.
/// </summary>
/// <remarks>
/// Uses a raw <see cref="HttpClient"/> — no additional NuGet package required.
/// All failures are silently absorbed: a failed API call returns <c>null</c>
/// rather than propagating an exception, so the main submit pipeline is never
/// interrupted by a failed follow-up generation.
/// </remarks>
public sealed class AiFollowUpService : IAiFollowUpService
{
    private readonly IHttpClientFactory        _http;
    private readonly string                    _apiKey;
    private readonly ILogger<AiFollowUpService> _logger;

    private static readonly JsonSerializerOptions CamelCase =
        new() { PropertyNamingPolicy = JsonNamingPolicy.CamelCase };

    public AiFollowUpService(
        IHttpClientFactory http,
        IConfiguration config,
        ILogger<AiFollowUpService> logger)
    {
        _http   = http;
        _logger = logger;
        _apiKey = config["Anthropic:ApiKey"]
            ?? throw new InvalidOperationException("Missing Anthropic:ApiKey configuration.");
    }

    /// <inheritdoc/>
    public async Task<AiFollowUpPayload?> GenerateAsync(
        Dictionary<string, MpiDimensionScore> dimensions,
        AssessmentContext context,
        string? ageBandName,
        CancellationToken ct)
    {
        var (tensions, _) = TensionDetector.Detect(dimensions);

        if (tensions.Count == 0)
            return null;

        using var cts = CancellationTokenSource.CreateLinkedTokenSource(ct);
        cts.CancelAfter(TimeSpan.FromSeconds(10));

        try
        {
            var requestBody = new
            {
                model      = "claude-sonnet-4-6",
                max_tokens = 1024,
                system     = "You are a psychometric assessment assistant. Output ONLY valid JSON — no prose, no markdown code fences.",
                messages   = new[]
                {
                    new { role = "user", content = BuildPrompt(dimensions, tensions, context, ageBandName) }
                },
            };

            var client  = _http.CreateClient();
            var request = new HttpRequestMessage(HttpMethod.Post, "https://api.anthropic.com/v1/messages");
            request.Headers.Add("x-api-key", _apiKey);
            request.Headers.Add("anthropic-version", "2023-06-01");
            request.Content = new StringContent(
                JsonSerializer.Serialize(requestBody),
                Encoding.UTF8,
                "application/json");

            var response = await client.SendAsync(request, cts.Token);
            response.EnsureSuccessStatusCode();

            var json = await response.Content.ReadAsStringAsync(cts.Token);
            var root = JsonSerializer.Deserialize<JsonElement>(json);
            var text = root.GetProperty("content")[0].GetProperty("text").GetString() ?? "";

            if (string.IsNullOrWhiteSpace(text))
            {
                _logger.LogWarning("Claude returned an empty text payload — discarding follow-up.");
                return null;
            }

            // Strip markdown code fences Claude occasionally includes despite instructions.
            var cleaned = text.Trim();
            if (cleaned.StartsWith("```"))
            {
                var firstNewline = cleaned.IndexOf('\n');
                cleaned = firstNewline >= 0 ? cleaned[(firstNewline + 1)..] : cleaned;
                if (cleaned.EndsWith("```"))
                    cleaned = cleaned[..^3].TrimEnd();
            }

            var payload = JsonSerializer.Deserialize<AiFollowUpPayload>(cleaned, CamelCase);

            if (payload is null || payload.Questions.Count == 0)
            {
                _logger.LogWarning(
                    "Claude returned a parseable response but with no questions. Raw: {Text}", text);
                return null;
            }

            if (payload.Questions.Any(q => q.Options.Count < 2))
            {
                _logger.LogWarning(
                    "Claude returned a question with fewer than 2 options — discarding follow-up. Raw: {Text}", text);
                return null;
            }

            return payload;
        }
        catch (Exception ex)
        {
            _logger.LogWarning(ex,
                "AI follow-up generation failed — result will be returned without follow-up questions.");
            return null;
        }
    }

    private static string BuildPrompt(
        Dictionary<string, MpiDimensionScore> dimensions,
        List<string> tensions,
        AssessmentContext context,
        string? ageBandName)
    {
        var contextLabel = context switch
        {
            AssessmentContext.Career              => "career and workplace decisions",
            AssessmentContext.Relationships       => "personal relationships and social dynamics",
            AssessmentContext.Leadership          => "leadership and team management",
            AssessmentContext.PersonalDevelopment => "personal growth and self-awareness",
            _                                    => "general self-understanding",
        };

        var contextGuidance = context switch
        {
            AssessmentContext.Career =>
                "Frame scenarios around workplace situations: team meetings, project decisions, dealing with colleagues, career choices.",
            AssessmentContext.Relationships =>
                "Frame scenarios around interpersonal situations: conflict with a partner or friend, social gatherings, emotional conversations.",
            AssessmentContext.Leadership =>
                "Frame scenarios around leading others: giving feedback, handling underperformance, running meetings, making team decisions.",
            AssessmentContext.PersonalDevelopment =>
                "Frame scenarios around self-reflection and growth: handling setbacks, personal goals, values conflicts, inner motivation.",
            _ =>
                "Frame scenarios around everyday life situations that reveal natural personality tendencies.",
        };

        var ageBandLine = ageBandName is not null
            ? "User age range: " + ageBandName + ". Ensure all scenarios are realistic and relatable for someone at this life stage.\n"
            : "";

        var scores = string.Join("\n", dimensions.Select(d =>
            $"- {d.Key}: {d.Value.Percentage:F1}% ({d.Value.DominantPole} pole, {d.Value.Strength} preference)"));

        var tensionList = string.Join("\n", tensions.Select(t => $"- {t}"));

        return
            "A user completed a 4-dimension personality assessment focused on " + contextLabel + ".\n"
            + ageBandLine
            + "Their dimension scores are:\n"
            + scores + "\n\n"
            + "Detected ambiguities that need resolution:\n"
            + tensionList + "\n\n"
            + "Generate exactly " + tensions.Count + " scenario-based follow-up question(s) — one per ambiguity listed above.\n"
            + contextGuidance + "\n"
            + "Each question must have exactly 2 options mapping to opposite poles of the ambiguous dimension.\n"
            + "Questions should feel natural and behavioural — not abstract or clinical.\n\n"
            + "Reply ONLY with this JSON structure (no other text).\n"
            + "The questions array must contain exactly " + tensions.Count + " item(s), one per ambiguity, with ids fu_1…fu_" + tensions.Count + ":\n"
            + "{\n"
            + "  \"tensions\": [\"copy each ambiguity listed above as a string\"],\n"
            + "  \"questions\": [\n"
            + "    {\n"
            + "      \"id\": \"fu_1\",\n"
            + "      \"text\": \"Scenario-based question text here\",\n"
            + "      \"options\": [\n"
            + "        { \"text\": \"Option A text\", \"dimensionImpact\": { \"EnergySource\": 5 } },\n"
            + "        { \"text\": \"Option B text\", \"dimensionImpact\": { \"EnergySource\": 1 } }\n"
            + "      ]\n"
            + "    }\n"
            + "  ],\n"
            + "  \"answers\": []\n"
            + "}";
    }
}
