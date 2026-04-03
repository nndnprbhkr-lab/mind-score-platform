using MindScorePlatform.Domain.Entities;

namespace MindScorePlatform.Application.Interfaces;

public interface IJwtTokenService
{
    string CreateToken(User user);
}
