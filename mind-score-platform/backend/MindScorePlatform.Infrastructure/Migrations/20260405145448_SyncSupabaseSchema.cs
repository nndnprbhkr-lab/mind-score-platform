using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace MindScorePlatform.Infrastructure.Migrations
{
    /// <inheritdoc />
    public partial class SyncSupabaseSchema : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            // ── Users: new profile columns (IF NOT EXISTS — Supabase may already have them) ──
            migrationBuilder.Sql("ALTER TABLE users ADD COLUMN IF NOT EXISTS agebandid uuid;");
            migrationBuilder.Sql("ALTER TABLE users ADD COLUMN IF NOT EXISTS dateofbirth timestamp with time zone;");
            migrationBuilder.Sql("ALTER TABLE users ADD COLUMN IF NOT EXISTS domicile text;");

            // ── Questions: MindScore module/age-band columns (IF NOT EXISTS) ──
            migrationBuilder.Sql("ALTER TABLE questions ADD COLUMN IF NOT EXISTS agebandid uuid;");
            migrationBuilder.Sql("ALTER TABLE questions ADD COLUMN IF NOT EXISTS difficulty text;");
            migrationBuilder.Sql("ALTER TABLE questions ADD COLUMN IF NOT EXISTS isreversescored boolean;");
            migrationBuilder.Sql("ALTER TABLE questions ADD COLUMN IF NOT EXISTS moduleid uuid;");
            migrationBuilder.Sql("ALTER TABLE questions ADD COLUMN IF NOT EXISTS version integer;");
            migrationBuilder.Sql("ALTER TABLE questions ADD COLUMN IF NOT EXISTS weight numeric;");

            // ── Tests: rename to MindType Assessment ─────────────────────────
            migrationBuilder.Sql("UPDATE tests SET name = 'MindType Assessment' WHERE id = '00000000-0000-0000-0000-000000000001';");

            // ── Indexes on new FK columns (IF NOT EXISTS) ─────────────────────
            migrationBuilder.Sql("CREATE INDEX IF NOT EXISTS \"IX_users_agebandid\" ON users (agebandid);");
            migrationBuilder.Sql("CREATE INDEX IF NOT EXISTS \"IX_Questions_agebandid\" ON questions (agebandid);");
            migrationBuilder.Sql("CREATE INDEX IF NOT EXISTS \"IX_Questions_moduleid\" ON questions (moduleid);");

            // ── FKs to pre-existing agebands / modules tables (skip if exists) ─
            migrationBuilder.Sql(@"
                DO $$ BEGIN
                    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'FK_questions_agebands_agebandid') THEN
                        ALTER TABLE questions ADD CONSTRAINT ""FK_questions_agebands_agebandid""
                            FOREIGN KEY (agebandid) REFERENCES agebands(id);
                    END IF;
                END $$;");

            migrationBuilder.Sql(@"
                DO $$ BEGIN
                    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'FK_questions_modules_moduleid') THEN
                        ALTER TABLE questions ADD CONSTRAINT ""FK_questions_modules_moduleid""
                            FOREIGN KEY (moduleid) REFERENCES modules(id);
                    END IF;
                END $$;");

            migrationBuilder.Sql(@"
                DO $$ BEGIN
                    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'FK_users_agebands_agebandid') THEN
                        ALTER TABLE users ADD CONSTRAINT ""FK_users_agebands_agebandid""
                            FOREIGN KEY (agebandid) REFERENCES agebands(id);
                    END IF;
                END $$;");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.Sql(@"ALTER TABLE questions DROP CONSTRAINT IF EXISTS ""FK_questions_agebands_agebandid"";");
            migrationBuilder.Sql(@"ALTER TABLE questions DROP CONSTRAINT IF EXISTS ""FK_questions_modules_moduleid"";");
            migrationBuilder.Sql(@"ALTER TABLE users DROP CONSTRAINT IF EXISTS ""FK_users_agebands_agebandid"";");

            migrationBuilder.Sql(@"DROP INDEX IF EXISTS ""IX_users_agebandid"";");
            migrationBuilder.Sql(@"DROP INDEX IF EXISTS ""IX_Questions_agebandid"";");
            migrationBuilder.Sql(@"DROP INDEX IF EXISTS ""IX_Questions_moduleid"";");

            migrationBuilder.Sql("ALTER TABLE users DROP COLUMN IF EXISTS agebandid;");
            migrationBuilder.Sql("ALTER TABLE users DROP COLUMN IF EXISTS dateofbirth;");
            migrationBuilder.Sql("ALTER TABLE users DROP COLUMN IF EXISTS domicile;");

            migrationBuilder.Sql("ALTER TABLE questions DROP COLUMN IF EXISTS agebandid;");
            migrationBuilder.Sql("ALTER TABLE questions DROP COLUMN IF EXISTS difficulty;");
            migrationBuilder.Sql("ALTER TABLE questions DROP COLUMN IF EXISTS isreversescored;");
            migrationBuilder.Sql("ALTER TABLE questions DROP COLUMN IF EXISTS moduleid;");
            migrationBuilder.Sql("ALTER TABLE questions DROP COLUMN IF EXISTS version;");
            migrationBuilder.Sql("ALTER TABLE questions DROP COLUMN IF EXISTS weight;");

            migrationBuilder.Sql("UPDATE tests SET name = 'MPI Assessment' WHERE id = '00000000-0000-0000-0000-000000000001';");
        }
    }
}
