# Backend

## Location

`mind-score-platform/backend/`

## Tech

- .NET 8 Web API
- Clean Architecture (Domain/Application/Infrastructure/WebApi)
- PostgreSQL (Supabase)
- Entity Framework Core
- JWT Authentication
- Swagger

## Run locally

From `mind-score-platform/backend/`:

- Build:
  - `/usr/local/share/dotnet/dotnet build MindScorePlatform.sln`

- Run API:
  - `/usr/local/share/dotnet/dotnet run --project MindScorePlatform.WebApi/MindScorePlatform.WebApi.csproj`

Swagger will be available at:
- `https://localhost:<port>/swagger`

## Environment variables

- `ConnectionStrings__Default`
  - Supabase connection string (PostgreSQL)
- `Jwt__Issuer`
- `Jwt__Audience`
- `Jwt__Key`
  - Long random secret

## EF Core migrations

A local tool manifest is included; from `mind-score-platform/backend/`:

- Create migration:
  - `/usr/local/share/dotnet/dotnet tool run dotnet-ef migrations add InitialCreate --project MindScorePlatform.Infrastructure --startup-project MindScorePlatform.WebApi`

- Apply migration:
  - `/usr/local/share/dotnet/dotnet tool run dotnet-ef database update --project MindScorePlatform.Infrastructure --startup-project MindScorePlatform.WebApi`

## Render deployment

- `mind-score-platform/backend/Dockerfile` is used for container builds.
- `mind-score-platform/backend/render.yaml` contains a basic Render service definition.

Set these secrets in Render:
- `ConnectionStrings__Default`
- `Jwt__Key`
