import Foundation

@MainActor
final class UpdateWritingSessionContentUseCaseImplementation: UpdateWritingSessionContentUseCase {
    private let sessionStateManager: SessionStateManager
    private let textStatisticsService: TextStatisticsService
    private let activityDetector: ActivityDetector
    
    init(
        sessionStateManager: SessionStateManager,
        textStatisticsService: TextStatisticsService,
        activityDetector: ActivityDetector
    ) {
        self.sessionStateManager = sessionStateManager
        self.textStatisticsService = textStatisticsService
        self.activityDetector = activityDetector
    }
    
    func execute(sessionId: UUID, content: String) async throws -> WritingSession {
        activityDetector.logTypingActivity()
        let updatedSession = try await sessionStateManager.updateSessionContent(
            sessionId: sessionId,
            content: content
        )
        return updatedSession
    }
}
