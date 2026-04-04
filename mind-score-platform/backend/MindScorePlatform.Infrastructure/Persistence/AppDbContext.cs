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

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        modelBuilder.Entity<User>(entity =>
        {
            entity.HasKey(x => x.Id);
            entity.HasIndex(x => x.Email).IsUnique();
            entity.Property(x => x.Email).IsRequired();
            entity.Property(x => x.PasswordHash).IsRequired();
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

        base.OnModelCreating(modelBuilder);
    }
}
