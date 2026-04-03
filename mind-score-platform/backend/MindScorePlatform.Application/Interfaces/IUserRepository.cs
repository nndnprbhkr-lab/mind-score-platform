using MindScorePlatform.Domain.Entities;

namespace MindScorePlatform.Application.Interfaces;

public interface IUserRepository
{
    Task<User?> GetByEmailAsync(string email, CancellationToken cancellationToken);

    Task<User?> GetByIdAsync(Guid id, CancellationToken cancellationToken);

    Task AddAsync(User user, CancellationToken cancellationToken);
}
