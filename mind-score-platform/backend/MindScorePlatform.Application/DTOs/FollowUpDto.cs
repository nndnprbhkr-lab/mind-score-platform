namespace MindScorePlatform.Application.DTOs;

/// <summary>A single AI-generated follow-up question with two selectable options.</summary>
public sealed class FollowUpQuestion
{
    public string Id { get; set; } = string.Empty;
    public string Text { get; set; } = string.Empty;
    public List<FollowUpOption> Options { get; set; } = [];
}

/// <summary>One option in a follow-up question, carrying dimension impact metadata.</summary>
public sealed class FollowUpOption
{
    public string Text { get; set; } = string.Empty;
    /// <summary>Maps dimension name → implied score (1–5 scale) for scoring adjustment.</summary>
    public Dictionary<string, int> DimensionImpact { get; set; } = new();
}

/// <summary>The user's chosen answer to one follow-up question.</summary>
public sealed class FollowUpAnswer
{
    public string QuestionId { get; set; } = string.Empty;
    /// <summary>Zero-based index into the question's Options list.</summary>
    public int OptionIndex { get; set; }
}

/// <summary>
/// Complete follow-up payload stored in Result.AiFollowUpJson.
/// Shape: { tensions, questions, answers }
/// </summary>
public sealed class AiFollowUpPayload
{
    public List<string> Tensions { get; set; } = [];
    public List<FollowUpQuestion> Questions { get; set; } = [];
    public List<FollowUpAnswer> Answers { get; set; } = [];
}

/// <summary>Request body for POST /api/results/{id}/follow-up.</summary>
public sealed class SubmitFollowUpDto
{
    public List<FollowUpAnswer> Answers { get; set; } = [];
}
