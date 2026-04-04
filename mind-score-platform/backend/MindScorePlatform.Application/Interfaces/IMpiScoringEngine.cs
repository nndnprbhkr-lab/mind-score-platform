namespace MindScorePlatform.Application.Interfaces;

public interface IMpiScoringEngine
{
    MpiResult Score(List<MpiResponseInput> responses);
}

public sealed class MpiResponseInput
{
    public string QuestionId { get; set; } = string.Empty;
    public int Value { get; set; }
}

public sealed class MpiResult
{
    public string TypeCode { get; set; } = string.Empty;
    public string TypeName { get; set; } = string.Empty;
    public string Role { get; set; } = string.Empty;
    public string Emoji { get; set; } = string.Empty;
    public string Tagline { get; set; } = string.Empty;
    public string[] Strengths { get; set; } = [];
    public string[] GrowthAreas { get; set; } = [];
    public string[] CareerPaths { get; set; } = [];
    public string CommunicationStyle { get; set; } = string.Empty;
    public string WorkStyle { get; set; } = string.Empty;
    public string AccentColor { get; set; } = string.Empty;
    public int OverallScore { get; set; }
    public Dictionary<string, MpiDimensionScore> Dimensions { get; set; } = new();
    public DateTime CompletedAt { get; set; }
}

public sealed class MpiDimensionScore
{
    public double Percentage { get; set; }
    public string DominantPole { get; set; } = string.Empty;
    public string Strength { get; set; } = string.Empty;
}
