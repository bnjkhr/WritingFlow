import Foundation

/// Simple dependency injection container for WritingFlow
@MainActor
final class AppContainer {
    static let shared = AppContainer()
    
    private init() {}
    
    // MARK: - Data Layer
    lazy var dataStoreManager = DataStoreManager.shared
    
    lazy var writingSessionRepository = WritingSessionRepository(
        context: dataStoreManager.context
    )
    
    // MARK: - Services
    lazy var timerEngine = TimerEngine()
    lazy var activityDetector = ActivityDetector()
    lazy var backspaceBlocker = BackspaceBlocker()
    lazy var textStatisticsService = TextStatisticsService()
    lazy var sessionStateManager = SessionStateManager(
        sessionRepository: writingSessionRepository
    )
    
    // MARK: - Use Cases
    lazy var startWritingSessionUseCase = StartWritingSessionUseCase(
        sessionStateManager: sessionStateManager,
        timerEngine: timerEngine,
        activityDetector: activityDetector,
        backspaceBlocker: backspaceBlocker
    )
    
    lazy var updateWritingSessionContentUseCase = UpdateWritingSessionContentUseCase(
        sessionStateManager: sessionStateManager,
        textStatisticsService: textStatisticsService,
        activityDetector: activityDetector
    )
    
    lazy var getSessionHistoryUseCase = GetSessionHistoryUseCase(
        sessionRepository: writingSessionRepository
    )
    
    // MARK: - ViewModels
    lazy var writingSessionViewModel = WritingSessionViewModel(
        startWritingSessionUseCase: startWritingSessionUseCase,
        updateWritingSessionContentUseCase: updateWritingSessionContentUseCase,
        timerEngine: timerEngine,
        activityDetector: activityDetector,
        backspaceBlocker: backspaceBlocker
    )
}