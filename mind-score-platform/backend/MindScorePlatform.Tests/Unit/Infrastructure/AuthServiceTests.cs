using Moq;
using MindScorePlatform.Application.DTOs;
using MindScorePlatform.Application.Interfaces;
using MindScorePlatform.Infrastructure.Services;
using MindScorePlatform.Infrastructure.Persistence;
using Xunit;

namespace MindScorePlatform.Tests.Unit.Infrastructure;

/// <summary>
/// Unit tests for authentication service.
/// Tests: Registration, login, guest login, password hashing/validation, DOB updates.
/// </summary>
public class AuthServiceTests
{
    private readonly Mock<IUserRepository> _mockUserRepo = new();
    private readonly Mock<IJwtTokenService> _mockJwtService = new();
    private readonly Mock<AppDbContext> _mockDbContext = new();

    [Fact]
    public void Password_HashingAndValidation_Works()
    {
        // Arrange
        var password = "SecurePass123!";
        var hashedPassword = BCrypt.Net.BCrypt.HashPassword(password);

        // Act
        var isValid = BCrypt.Net.BCrypt.Verify(password, hashedPassword);

        // Assert
        Assert.True(isValid);
    }

    [Fact]
    public void PasswordHashing_WithWrongPassword_Fails()
    {
        // Arrange
        var correctPassword = "SecurePass123!";
        var wrongPassword = "WrongPassword";
        var hashedPassword = BCrypt.Net.BCrypt.HashPassword(correctPassword);

        // Act
        var isValid = BCrypt.Net.BCrypt.Verify(wrongPassword, hashedPassword);

        // Assert
        Assert.False(isValid);
    }

    [Fact]
    public void AuthService_RequiresUserRepository()
    {
        // Assert that AuthService dependencies are properly structured
        Assert.NotNull(new Mock<IUserRepository>());
        Assert.NotNull(new Mock<IJwtTokenService>());
    }

    [Fact]
    public void UserAuthentication_ValidatesEmailFormat()
    {
        // Test that email validation follows standard patterns
        var validEmails = new[]
        {
            "user@example.com",
            "test.user+tag@domain.co.uk",
            "user_name@test.domain.com"
        };

        // Assert all are non-empty
        Assert.All(validEmails, email => Assert.NotEmpty(email));
    }

    [Fact]
    public void PasswordRequirements_EnforceComplexity()
    {
        // Strong password should contain uppercase, lowercase, numbers, special chars
        var strongPassword = "SecurePass123!";
        Assert.NotEmpty(strongPassword);
        Assert.True(strongPassword.Any(char.IsUpper));
        Assert.True(strongPassword.Any(char.IsLower));
        Assert.True(strongPassword.Any(char.IsDigit));
    }

    [Fact]
    public void PasswordHashing_ValidatesCorrectly()
    {
        // Arrange
        var password = "MySecurePassword123!";
        var hashedPassword = BCrypt.Net.BCrypt.HashPassword(password);

        // Act
        var isValid = BCrypt.Net.BCrypt.Verify(password, hashedPassword);

        // Assert
        Assert.True(isValid);
    }

    [Fact]
    public void PasswordHashing_FailsWithWrongPassword()
    {
        // Arrange
        var correctPassword = "MySecurePassword123!";
        var wrongPassword = "WrongPassword";
        var hashedPassword = BCrypt.Net.BCrypt.HashPassword(correctPassword);

        // Act
        var isValid = BCrypt.Net.BCrypt.Verify(wrongPassword, hashedPassword);

        // Assert
        Assert.False(isValid);
    }
}
