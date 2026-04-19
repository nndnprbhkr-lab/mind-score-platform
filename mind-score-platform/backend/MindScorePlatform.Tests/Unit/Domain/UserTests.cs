using MindScorePlatform.Domain.Entities;
using Xunit;

namespace MindScorePlatform.Tests.Unit.Domain;

public class UserTests
{
    [Fact]
    public void Constructor_CreatesUserWithDefaultRole()
    {
        // Arrange & Act
        var user = new User
        {
            Id = Guid.NewGuid(),
            Name = "John Doe",
            Email = "john@example.com",
            PasswordHash = "hashed_password",
            CreatedAtUtc = DateTime.UtcNow
        };

        // Assert
        Assert.Equal("user", user.Role);
        Assert.False(user.IsGuest);
    }

    [Theory]
    [InlineData("john@example.com")]
    [InlineData("guest@test.local")]
    [InlineData("test.email+tag@domain.co.uk")]
    public void User_StoresValidEmail(string email)
    {
        // Arrange & Act
        var user = new User { Email = email };

        // Assert
        Assert.Equal(email, user.Email);
    }

    [Fact]
    public void User_IsGuest_WhenSetToTrue()
    {
        // Arrange
        var user = new User { IsGuest = true };

        // Act & Assert
        Assert.True(user.IsGuest);
    }

    [Fact]
    public void User_HasOptionalDemographicData()
    {
        // Arrange
        var dob = new DateTime(1990, 5, 15);
        var domicile = "United States";

        // Act
        var user = new User
        {
            DateOfBirth = dob,
            Domicile = domicile
        };

        // Assert
        Assert.Equal(dob, user.DateOfBirth);
        Assert.Equal(domicile, user.Domicile);
    }

    [Fact]
    public void User_CanLinkToAgeBand()
    {
        // Arrange
        var ageBandId = Guid.NewGuid();
        var user = new User { AgeBandId = ageBandId };

        // Act & Assert
        Assert.Equal(ageBandId, user.AgeBandId);
    }

    [Fact]
    public void User_DefaultEmail_IsEmpty()
    {
        // Arrange & Act
        var user = new User();

        // Assert
        Assert.Empty(user.Email);
    }

    [Fact]
    public void User_DefaultPasswordHash_IsEmpty()
    {
        // Arrange & Act
        var user = new User();

        // Assert
        Assert.Empty(user.PasswordHash);
    }

    [Fact]
    public void User_ReturnsUniquefullyInitializedGuid()
    {
        // Arrange
        var user1 = new User { Id = Guid.NewGuid() };
        var user2 = new User { Id = Guid.NewGuid() };

        // Act & Assert
        Assert.NotEqual(user1.Id, user2.Id);
    }

    [Fact]
    public void User_CanChangeRole()
    {
        // Arrange
        var user = new User { Role = "user" };

        // Act
        user.Role = "admin";

        // Assert
        Assert.Equal("admin", user.Role);
    }
}
