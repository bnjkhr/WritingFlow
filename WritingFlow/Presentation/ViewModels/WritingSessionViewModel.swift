import SwiftUI
import Combine

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
    @Published var analysisResult: AIAnalysisResult?
    @Published var showingAnalysis = false

    private let startWritingSessionUseCase: StartWritingSessionUseCase
    private let updateWritingSessionContentUseCase: UpdateWritingSessionContentUseCase
    private let aiAnalysisService: AIAnalysisService
    private let sessionStateManager: SessionStateManager
    private let timerEngine: TimerEngine
    private let activityDetector: ActivityDetector
    private let backspaceBlocker: BackspaceBlocker

    private var cancellables: Set<AnyCancellable> = []

    init(
        startWritingSessionUseCase: StartWritingSessionUseCase,
        updateWritingSessionContentUseCase: UpdateWritingSessionContentUseCase,
        aiAnalysisService: AIAnalysisService,
        sessionStateManager: SessionStateManager,
        timerEngine: TimerEngine,
        activityDetector: ActivityDetector,
        backspaceBlocker: BackspaceBlocker
    ) {
        self.startWritingSessionUseCase = startWritingSessionUseCase
        self.updateWritingSessionContentUseCase = updateWritingSessionContentUseCase
        self.aiAnalysisService = aiAnalysisService
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
            timerEngine.start(duration: session.duration)

        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    func pauseSession() async {
        guard let session = currentSession else { return }

        do {
            let updatedSession = try await sessionStateManager.pauseSession(sessionId: session.id)
            currentSession = updatedSession
            timerEngine.pause()
            isBackspaceBlocked = false

        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func resumeSession() async {
        guard let session = currentSession else { return }

        do {
            let updatedSession = try await sessionStateManager.resumeSession(sessionId: session.id)
            currentSession = updatedSession
            timerEngine.resume()
            isBackspaceBlocked = true

        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func completeSession() async {
        guard let session = currentSession, !session.isCompleted else { return }

        isLoading = true

        do {
            _ = try await sessionStateManager.completeSession(sessionId: session.id)
            timerEngine.stop()
            activityDetector.stopActivityDetection()
            backspaceBlocker.disableBlocking()

            // Don't clear the session immediately, allow for analysis
            // currentSession = nil
            // text = ""
            isBackspaceBlocked = false

        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    func analyzeSession() async {
        isLoading = true
        showingAnalysis = false
        analysisResult = nil

        do {
            analysisResult = try await aiAnalysisService.analyzeText(text)
            showingAnalysis = true
        } catch {
            errorMessage = "Failed to analyze text: \(error.localizedDescription)"
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
            text = newText

        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func setupTimerObserver() {
        timerEngine.$remainingTime
            .assign(to: &$remainingTime)

        timerEngine.$isRunning
            .assign(to: &$isTimerRunning)

        timerEngine.$isPaused
            .assign(to: &$isTimerPaused)

        timerEngine.$isExpired
            .sink { [weak self] isExpired in
                if isExpired {
                    Task {
                        await self?.completeSession()
                    }
                }
            }
            .store(in: &cancellables)
    }
}
