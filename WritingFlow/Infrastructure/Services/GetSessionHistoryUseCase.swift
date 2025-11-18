import Foundation

@MainActor
final class GetSessionHistoryUseCaseImplementation: GetSessionHistoryUseCase {
    private let sessionRepository: WritingSessionRepository
    
    init(sessionRepository: WritingSessionRepository) {
        self.sessionRepository = sessionRepository
    }
    
    func execute(limit: Int? = nil, offset: Int? = nil) async throws -> [WritingSession] {
        let allSessions = try await sessionRepository.getAllSessions()
        let startIndex = offset ?? 0
        let endIndex = limit.map { startIndex + $0 } ?? allSessions.count
        guard startIndex < allSessions.count else {
            return []
        }
        let endIndexClamped = min(endIndex, allSessions.count)
        return Array(allSessions[startIndex..<endIndexClamped])
    }
}
