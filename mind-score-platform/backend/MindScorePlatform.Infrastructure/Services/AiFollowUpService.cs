using System.Text;
using System.Text.Json;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Logging;
using MindScorePlatform.Application.DTOs;
using MindScorePlatform.Application.Interfaces;
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
                    new { role = "user", content = BuildPrompt(dimensions, tensions) }
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

            return JsonSerializer.Deserialize<AiFollowUpPayload>(text, CamelCase);
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
        List<string> tensions)
    {
        var scores = string.Join("\n", dimensions.Select(d =>
            $"- {d.Key}: {d.Value.Percentage:F1}% ({d.Value.DominantPole} pole, {d.Value.Strength} preference)"));

        var tensionList = string.Join("\n", tensions.Select(t => $"- {t}"));

        return
            "A user completed a 4-dimension personality assessment with these scores:\n"
            + scores + "\n\n"
            + "Detected ambiguities that need resolution:\n"
            + tensionList + "\n\n"
            + "Generate exactly 3 scenario-based follow-up questions to resolve the ambiguities above.\n"
            + "Each question must have exactly 2 options mapping to opposite poles of the ambiguous dimension.\n"
            + "Questions should feel natural and behavioural — not abstract or clinical.\n\n"
            + "Reply ONLY with this JSON structure (no other text):\n"
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
