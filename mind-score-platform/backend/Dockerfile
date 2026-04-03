# Build
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src

COPY MindScorePlatform.sln ./
COPY MindScorePlatform.Domain/MindScorePlatform.Domain.csproj MindScorePlatform.Domain/
COPY MindScorePlatform.Application/MindScorePlatform.Application.csproj MindScorePlatform.Application/
COPY MindScorePlatform.Infrastructure/MindScorePlatform.Infrastructure.csproj MindScorePlatform.Infrastructure/
COPY MindScorePlatform.WebApi/MindScorePlatform.WebApi.csproj MindScorePlatform.WebApi/

RUN dotnet restore MindScorePlatform.WebApi/MindScorePlatform.WebApi.csproj

COPY . .
RUN dotnet publish MindScorePlatform.WebApi/MindScorePlatform.WebApi.csproj -c Release -o /app/publish

# Runtime
FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS runtime
WORKDIR /app

ENV ASPNETCORE_URLS=http://0.0.0.0:8080
EXPOSE 8080

COPY --from=build /app/publish .

ENTRYPOINT ["dotnet", "MindScorePlatform.WebApi.dll"]
