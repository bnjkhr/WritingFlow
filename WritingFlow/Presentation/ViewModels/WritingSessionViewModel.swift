import SwiftUI

@MainActor
final class WritingSessionViewModel: ObservableObject {
    @Published var currentSession: WritingSession?
    @Published var text: String = ""
    @Published var isBackspaceBlocked: Bool = false
    @Published var remainingTime: TimeInterval = 15 * 60
    @Published var isTimerRunning: Bool = false
    @Published var isTimerPaused: Bool = false
    @Published var isTimerExpired: Bool = false
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    private let startWritingSessionUseCase: StartWritingSessionUseCase
    private let updateWritingSessionContentUseCase: UpdateWritingSessionContentUseCase
    private let sessionStateManager: SessionStateManager
    private let timerEngine: TimerEngine
    private let activityDetector: ActivityDetector
    private let backspaceBlocker: BackspaceBlocker

    init(
        startWritingSessionUseCase: StartWritingSessionUseCase,
        updateWritingSessionContentUseCase: UpdateWritingSessionContentUseCase,
        sessionStateManager: SessionStateManager,
        timerEngine: TimerEngine,
        activityDetector: ActivityDetector,
        backspaceBlocker: BackspaceBlocker
    ) {
        self.startWritingSessionUseCase = startWritingSessionUseCase
        self.updateWritingSessionContentUseCase = updateWritingSessionContentUseCase
        self.sessionStateManager = sessionStateManager
        self.timerEngine = timerEngine
        self.activityDetector = activityDetector
        self.backspaceBlocker = backspaceBlocker

        setupTimerObserver()
    }
    
    func startSession(duration: TimeInterval? = nil) async {
        isLoading = true
        errorMessage = nil
        
        do {
            let session = try await startWritingSessionUseCase.execute(duration: duration)
            currentSession = session
            text = session.content
            isBackspaceBlocked = true
            
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    func pauseSession() async {
        guard let session = currentSession else { return }
        
        do {
            _ = try await sessionStateManager.pauseSession(sessionId: session.id)
            timerEngine.pause()
            isBackspaceBlocked = false
            
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    func resumeSession() async {
        guard let session = currentSession else { return }
        
        do {
            _ = try await sessionStateManager.resumeSession(sessionId: session.id)
            timerEngine.resume()
            isBackspaceBlocked = true
            
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    func completeSession() async {
        guard let session = currentSession else { return }
        
        isLoading = true
        
        do {
            _ = try await sessionStateManager.completeSession(sessionId: session.id)
            timerEngine.stop()
            activityDetector.stopActivityDetection()
            backspaceBlocker.disableBlocking()
            
            currentSession = nil
            text = ""
            isBackspaceBlocked = false
            
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    func updateText(_ newText: String) async {
        guard let session = currentSession else { return }
        
        do {
            _ = try await updateWritingSessionContentUseCase.execute(
                sessionId: session.id,
                content: newText
            )
            
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    private func setupTimerObserver() {
        // Observe timer engine changes
        // This would be implemented with proper Combine publishers
    }
}