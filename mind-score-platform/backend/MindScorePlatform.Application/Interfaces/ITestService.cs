using MindScorePlatform.Application.DTOs;

namespace MindScorePlatform.Application.Interfaces;

public interface ITestService
{
    Task<IReadOnlyList<TestDto>> GetAllAsync(CancellationToken cancellationToken);
    Task<TestDto> GetByIdAsync(Guid id, CancellationToken cancellationToken);
    Task<TestDto> CreateAsync(CreateTestDto dto, CancellationToken cancellationToken);
}
