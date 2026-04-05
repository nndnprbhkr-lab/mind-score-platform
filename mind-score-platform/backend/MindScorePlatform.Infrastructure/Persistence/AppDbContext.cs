using Microsoft.EntityFrameworkCore;
using MindScorePlatform.Domain.Entities;

namespace MindScorePlatform.Infrastructure.Persistence;

public sealed class AppDbContext : DbContext
{
    public AppDbContext(DbContextOptions<AppDbContext> options) : base(options)
    {
    }

    public DbSet<User> Users => Set<User>();
    public DbSet<Test> Tests => Set<Test>();
    public DbSet<Question> Questions => Set<Question>();
    public DbSet<Response> Responses => Set<Response>();
    public DbSet<Result> Results => Set<Result>();
    public DbSet<Report> Reports => Set<Report>();
    public DbSet<AgeBand> AgeBands => Set<AgeBand>();
    public DbSet<Module> Modules => Set<Module>();
    public DbSet<ModuleScore> ModuleScores => Set<ModuleScore>();
    public DbSet<NormReference> NormReferences => Set<NormReference>();
    public DbSet<AgeBandModuleWeight> AgeBandModuleWeights => Set<AgeBandModuleWeight>();

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        modelBuilder.Entity<User>(entity =>
        {
            entity.ToTable("users");
            entity.HasKey(x => x.Id);
            entity.Property(x => x.Id).HasColumnName("id");
            entity.Property(x => x.Name).IsRequired().HasColumnName("name");
            entity.Property(x => x.Email).IsRequired().HasColumnName("email");
            entity.Property(x => x.PasswordHash).IsRequired().HasColumnName("passwordhash");
            entity.Property(x => x.Role).HasColumnName("role");
            entity.Property(x => x.IsGuest).HasColumnName("isguest");
            entity.Property(x => x.CreatedAtUtc).HasColumnName("createdatutc");
            entity.Property(x => x.DateOfBirth).HasColumnName("dateofbirth");
            entity.Property(x => x.Domicile).HasColumnName("domicile");
            entity.Property(x => x.AgeBandId).HasColumnName("agebandid");
            entity.HasIndex(x => x.Email).IsUnique().HasDatabaseName("IX_Users_Email");
            entity.HasOne(x => x.AgeBand).WithMany().HasForeignKey(x => x.AgeBandId).IsRequired(false);
        });

        modelBuilder.Entity<Test>(entity =>
        {
            entity.ToTable("tests");
            entity.HasKey(x => x.Id);
            entity.Property(x => x.Id).HasColumnName("id");
            entity.Property(x => x.Name).IsRequired().HasColumnName("name");
            entity.Property(x => x.CreatedAtUtc).HasColumnName("createdatutc");
            entity.HasData(MpiSeed.Test);
        });

        modelBuilder.Entity<Question>(entity =>
        {
            entity.ToTable("questions");
            entity.HasKey(x => x.Id);
            entity.Property(x => x.Id).HasColumnName("id");
            entity.Property(x => x.TestId).HasColumnName("testid");
            entity.Property(x => x.Code).IsRequired().HasColumnName("code");
            entity.Property(x => x.Text).IsRequired().HasColumnName("text");
            entity.Property(x => x.Order).HasColumnName("orderid");
            entity.Property(x => x.CreatedAtUtc).HasColumnName("createdatutc");
            entity.Property(x => x.ModuleId).HasColumnName("moduleid");
            entity.Property(x => x.AgeBandId).HasColumnName("agebandid");
            entity.Property(x => x.Difficulty).HasColumnName("difficulty");
            entity.Property(x => x.Weight).HasColumnName("weight");
            entity.Property(x => x.IsReverseScored).HasColumnName("isreversescored");
            entity.Property(x => x.Version).HasColumnName("version");
            entity.HasIndex(x => new { x.TestId, x.Order }).IsUnique().HasDatabaseName("IX_Questions_TestId_Order");
            entity.HasIndex(x => new { x.TestId, x.Code }).IsUnique().HasDatabaseName("IX_Questions_TestId_Code");
            entity.HasOne(x => x.Module)
                  .WithMany(m => m.Questions)
                  .HasForeignKey(x => x.ModuleId)
                  .IsRequired(false);
            entity.HasOne(x => x.AgeBand)
                  .WithMany(a => a.Questions)
                  .HasForeignKey(x => x.AgeBandId)
                  .IsRequired(false);
            entity.HasData(MpiSeed.Questions);
        });

        modelBuilder.Entity<Response>(entity =>
        {
            entity.ToTable("responses");
            entity.HasKey(x => x.Id);
            entity.Property(x => x.Id).HasColumnName("id");
            entity.Property(x => x.UserId).HasColumnName("userid");
            entity.Property(x => x.QuestionId).HasColumnName("questionid");
            entity.Property(x => x.Value).IsRequired().HasColumnName("value");
            entity.Property(x => x.CreatedAtUtc).HasColumnName("createdatutc");
            entity.HasIndex(x => new { x.UserId, x.QuestionId }).IsUnique().HasDatabaseName("IX_Responses_UserId_QuestionId");
        });

        modelBuilder.Entity<Result>(entity =>
        {
            entity.ToTable("results");
            entity.HasKey(x => x.Id);
            entity.Property(x => x.Id).HasColumnName("id");
            entity.Property(x => x.UserId).HasColumnName("userid");
            entity.Property(x => x.TestId).HasColumnName("testid");
            entity.Property(x => x.Score).HasColumnName("score");
            entity.Property(x => x.CreatedAtUtc).HasColumnName("createdatutc");
            entity.Property(x => x.PersonalityType).IsRequired().HasColumnName("personalitytype");
            entity.Property(x => x.PersonalityName).IsRequired().HasColumnName("personalityname");
            entity.Property(x => x.PersonalityEmoji).IsRequired().HasColumnName("personalityemoji");
            entity.Property(x => x.PersonalityTagline).IsRequired().HasColumnName("personalitytagline");
            entity.Property(x => x.DimensionScoresJson).IsRequired().HasColumnName("dimensionscoresjson");
            entity.Property(x => x.InsightsJson).IsRequired().HasColumnName("insightsjson");
            entity.HasIndex(x => new { x.UserId, x.TestId }).IsUnique().HasDatabaseName("IX_Results_UserId_TestId");
        });

        modelBuilder.Entity<Report>(entity =>
        {
            entity.ToTable("reports");
            entity.HasKey(x => x.Id);
            entity.Property(x => x.Id).HasColumnName("id");
            entity.Property(x => x.UserId).HasColumnName("userid");
            entity.Property(x => x.Title).IsRequired().HasColumnName("title");
            entity.Property(x => x.Content).IsRequired().HasColumnName("content");
            entity.Property(x => x.CreatedAtUtc).HasColumnName("createdatutc");
        });

        modelBuilder.Entity<AgeBand>(entity =>
        {
            entity.ToTable("agebands");
            entity.HasKey(x => x.Id);
            entity.Property(x => x.Id).HasColumnName("id");
            entity.Property(x => x.Name).IsRequired().HasColumnName("name");
            entity.Property(x => x.MinAge).HasColumnName("minage");
            entity.Property(x => x.MaxAge).HasColumnName("maxage");
            entity.Property(x => x.Description).HasColumnName("description");
            entity.Property(x => x.DisplayOrder).HasColumnName("displayorder");
            entity.Property(x => x.IsActive).HasColumnName("isactive");
            entity.Property(x => x.CreatedAt).HasColumnName("createdat");
        });

        modelBuilder.Entity<Module>(entity =>
        {
            entity.ToTable("modules");
            entity.HasKey(x => x.Id);
            entity.Property(x => x.Id).HasColumnName("id");
            entity.Property(x => x.Name).IsRequired().HasColumnName("name");
            entity.Property(x => x.Description).HasColumnName("description");
            entity.Property(x => x.DisplayOrder).HasColumnName("displayorder");
            entity.Property(x => x.IsActive).HasColumnName("isactive");
            entity.Property(x => x.CreatedAt).HasColumnName("createdat");
        });

        modelBuilder.Entity<ModuleScore>(entity =>
        {
            entity.ToTable("module_scores");
            entity.HasKey(x => x.Id);
            entity.Property(x => x.Id).HasColumnName("id");
            entity.Property(x => x.TestId).HasColumnName("testid");
            entity.Property(x => x.ModuleId).HasColumnName("moduleid");
            entity.Property(x => x.RawScore).HasColumnName("rawscore");
            entity.Property(x => x.Percentile).HasColumnName("percentile");
            entity.Property(x => x.WeightedScore).HasColumnName("weightedscore");
            entity.Property(x => x.CreatedAt).HasColumnName("createdat");
            entity.HasOne(x => x.Module)
                  .WithMany(m => m.ModuleScores)
                  .HasForeignKey(x => x.ModuleId);
        });

        modelBuilder.Entity<NormReference>(entity =>
        {
            entity.ToTable("normreferences");
            entity.HasKey(x => x.Id);
            entity.Property(x => x.Id).HasColumnName("id");
            entity.Property(x => x.ModuleId).HasColumnName("moduleid");
            entity.Property(x => x.AgeBandId).HasColumnName("agebandid");
            entity.Property(x => x.Mean).HasColumnName("mean");
            entity.Property(x => x.StandardDeviation).HasColumnName("standarddeviation");
            entity.Property(x => x.SampleSize).HasColumnName("samplesize");
            entity.Property(x => x.CreatedAt).HasColumnName("createdat");
            entity.HasOne(x => x.Module).WithMany().HasForeignKey(x => x.ModuleId);
            entity.HasOne(x => x.AgeBand).WithMany().HasForeignKey(x => x.AgeBandId);
        });

        modelBuilder.Entity<AgeBandModuleWeight>(entity =>
        {
            entity.ToTable("agebandmoduleweights");
            entity.HasKey(x => x.Id);
            entity.Property(x => x.Id).HasColumnName("id");
            entity.Property(x => x.AgeBandId).HasColumnName("agebandid");
            entity.Property(x => x.ModuleId).HasColumnName("moduleid");
            entity.Property(x => x.Weight).HasColumnName("weight");
            entity.Property(x => x.CreatedAt).HasColumnName("createdat");
            entity.HasOne(x => x.AgeBand).WithMany().HasForeignKey(x => x.AgeBandId);
            entity.HasOne(x => x.Module).WithMany().HasForeignKey(x => x.ModuleId);
        });

        base.OnModelCreating(modelBuilder);
    }
}
