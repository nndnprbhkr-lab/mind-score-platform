using System.Text;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.IdentityModel.Tokens;
using MindScorePlatform.Application.Interfaces;
using MindScorePlatform.Infrastructure.Persistence;
using MindScorePlatform.Infrastructure.Repositories;
using MindScorePlatform.Infrastructure.Services;
using MindScorePlatform.Infrastructure.Services.Mpi;

namespace MindScorePlatform.Infrastructure;

public static class DependencyInjection
{
    public static IServiceCollection AddInfrastructure(this IServiceCollection services, IConfiguration configuration)
    {
        var connectionString = configuration.GetConnectionString("Default");
        if (string.IsNullOrWhiteSpace(connectionString))
        {
            throw new InvalidOperationException("Missing ConnectionStrings:Default configuration.");
        }

        services.AddDbContext<AppDbContext>(options =>
            options.UseNpgsql(connectionString, npgsqlOptions =>
                npgsqlOptions.MigrationsAssembly(typeof(DependencyInjection).Assembly.FullName)));

        services.AddScoped<IUserRepository, UserRepository>();
        services.AddScoped<IAuthService, AuthService>();
        services.AddSingleton<IJwtTokenService, JwtTokenService>();
        services.AddSingleton<IMpiScoringEngine, MpiScoringEngine>();
        services.AddSingleton<IMpiActionPlanEngine, MpiActionPlanEngine>();
        services.AddScoped<IMindScoringEngine, MindScoringEngine>();

        services.AddScoped<ITestRepository, TestRepository>();
        services.AddScoped<IQuestionRepository, QuestionRepository>();
        services.AddScoped<IResponseRepository, ResponseRepository>();
        services.AddScoped<IResultRepository, ResultRepository>();
        services.AddScoped<IReportRepository, ReportRepository>();

        services.AddScoped<ITestService, TestService>();
        services.AddScoped<IQuestionService, QuestionService>();
        services.AddScoped<IResponseService, ResponseService>();
        services.AddScoped<IResultService, ResultService>();
        services.AddScoped<IReportService, ReportService>();

        var jwtKey = configuration["Jwt:Key"];
        if (string.IsNullOrWhiteSpace(jwtKey))
        {
            throw new InvalidOperationException("Missing Jwt:Key configuration.");
        }

        var key = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(jwtKey));

        services
            .AddAuthentication(JwtBearerDefaults.AuthenticationScheme)
            .AddJwtBearer(options =>
            {
                options.TokenValidationParameters = new TokenValidationParameters
                {
                    ValidateIssuer = true,
                    ValidateAudience = true,
                    ValidateLifetime = true,
                    ValidateIssuerSigningKey = true,
                    ValidIssuer = configuration["Jwt:Issuer"] ?? string.Empty,
                    ValidAudience = configuration["Jwt:Audience"] ?? string.Empty,
                    IssuerSigningKey = key,
                    ClockSkew = TimeSpan.FromMinutes(2),
                };
            });

        services.AddAuthorization();

        return services;
    }
}
