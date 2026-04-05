using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using Microsoft.EntityFrameworkCore.Migrations;
using Npgsql.EntityFrameworkCore.PostgreSQL.Migrations.Internal;

namespace MindScorePlatform.Infrastructure.Persistence;

/// <summary>
/// Overrides EF's default migrations history repository so that the
/// MigrationId and ProductVersion columns are stored as lowercase,
/// matching the Supabase naming convention used across all tables.
/// </summary>
#pragma warning disable EF1001 // Internal EF Core API usage
public sealed class LowercaseHistoryRepository : NpgsqlHistoryRepository
{
    public LowercaseHistoryRepository(HistoryRepositoryDependencies dependencies)
        : base(dependencies) { }

    protected override void ConfigureTable(EntityTypeBuilder<HistoryRow> history)
    {
        base.ConfigureTable(history);
        history.Property(h => h.MigrationId).HasColumnName("migrationid");
        history.Property(h => h.ProductVersion).HasColumnName("productversion");
    }
}
#pragma warning restore EF1001
