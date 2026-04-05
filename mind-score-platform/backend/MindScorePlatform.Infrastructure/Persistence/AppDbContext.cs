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
            entity.HasKey(x => x.Id);
            entity.HasIndex(x => x.Email).IsUnique();
            entity.Property(x => x.Name).IsRequired();
            entity.Property(x => x.Email).IsRequired();
            entity.Property(x => x.PasswordHash).IsRequired();
            entity.Property(x => x.DateOfBirth).HasColumnName("dateofbirth");
            entity.Property(x => x.Domicile).HasColumnName("domicile");
            entity.Property(x => x.AgeBandId).HasColumnName("agebandid");
            entity.HasOne(x => x.AgeBand).WithMany().HasForeignKey(x => x.AgeBandId).IsRequired(false);
        });

        modelBuilder.Entity<Test>(entity =>
        {
            entity.HasKey(x => x.Id);
            entity.Property(x => x.Name).IsRequired();
            entity.HasData(MpiSeed.Test);
        });

        modelBuilder.Entity<Question>(entity =>
        {
            entity.HasKey(x => x.Id);
            entity.Property(x => x.Code).IsRequired();
            entity.Property(x => x.Text).IsRequired();
            entity.HasIndex(x => new { x.TestId, x.Order }).IsUnique();
            entity.HasIndex(x => new { x.TestId, x.Code }).IsUnique();
            entity.Property(x => x.ModuleId).HasColumnName("moduleid");
            entity.Property(x => x.AgeBandId).HasColumnName("agebandid");
            entity.Property(x => x.Difficulty).HasColumnName("difficulty");
            entity.Property(x => x.Weight).HasColumnName("weight");
            entity.Property(x => x.IsReverseScored).HasColumnName("isreversescored");
            entity.Property(x => x.Version).HasColumnName("version");
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
            entity.HasKey(x => x.Id);
            entity.Property(x => x.Value).IsRequired();
            entity.HasIndex(x => new { x.UserId, x.QuestionId }).IsUnique();
        });

        modelBuilder.Entity<Result>(entity =>
        {
            entity.HasKey(x => x.Id);
            entity.HasIndex(x => new { x.UserId, x.TestId }).IsUnique();
            entity.Property(x => x.PersonalityType).IsRequired();
            entity.Property(x => x.PersonalityName).IsRequired();
            entity.Property(x => x.PersonalityEmoji).IsRequired();
            entity.Property(x => x.PersonalityTagline).IsRequired();
            entity.Property(x => x.DimensionScoresJson).IsRequired();
            entity.Property(x => x.InsightsJson).IsRequired();
        });

        modelBuilder.Entity<Report>(entity =>
        {
            entity.HasKey(x => x.Id);
            entity.Property(x => x.Title).IsRequired();
            entity.Property(x => x.Content).IsRequired();
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
