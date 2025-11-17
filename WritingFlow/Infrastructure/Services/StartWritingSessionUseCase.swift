import Foundation

@MainActor
final class StartWritingSessionUseCase {
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
        // Start the session
        let session = try await sessionStateManager.startSession(duration: duration)
        
        // Start the timer
        timerEngine.start(duration: session.targetDuration)
        
        // Start activity detection
        activityDetector.startActivityDetection(for: session.id)
        
        // Enable backspace blocking
        backspaceBlocker.enableBlocking()
        
        return session
    }
}