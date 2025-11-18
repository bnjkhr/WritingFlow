import Foundation

@MainActor
final class StartWritingSessionUseCaseImplementation: StartWritingSessionUseCase {
    private let sessionStateManager: SessionStateManager
    private let timerEngine: TimerEngine
    private let activityDetector: ActivityDetector
    private let backspaceBlocker: BackspaceBlocker
    
    init(
        sessionStateManager: SessionStateManager,
        timerEngine: TimerEngine,
        activityDetector: ActivityDetector,
        backspaceBlocker: BackspaceBlocker
    ) {
        self.sessionStateManager = sessionStateManager
        self.timerEngine = timerEngine
        self.activityDetector = activityDetector
        self.backspaceBlocker = backspaceBlocker
    }
    
    func execute(duration: TimeInterval? = nil) async throws -> WritingSession {
        let session = try await sessionStateManager.startSession(duration: duration)
        timerEngine.start(duration: session.targetDuration)
        activityDetector.startActivityDetection(for: session.id)
        backspaceBlocker.enableBlocking()
        return session
    }
}
