import Foundation
import FoundationModels

// MARK: - Writing Session Use Cases

protocol StartWritingSessionUseCase {
    func execute(duration: TimeInterval?) async throws -> WritingSession
}

protocol PauseWritingSessionUseCase {
    func execute(sessionId: UUID) async throws -> WritingSession
}

protocol ResumeWritingSessionUseCase {
    func execute(sessionId: UUID) async throws -> WritingSession
}

protocol CompleteWritingSessionUseCase {
    func execute(sessionId: UUID) async throws -> WritingSession
}

protocol UpdateWritingSessionContentUseCase {
    func execute(sessionId: UUID, content: String) async throws -> WritingSession
}

// MARK: - Timer Use Cases

protocol StartTimerUseCase {
    func execute(duration: TimeInterval) async throws -> TimerState
}

protocol PauseTimerUseCase {
    func execute() async throws -> TimerState
}

protocol ResumeTimerUseCase {
    func execute() async throws -> TimerState
}

protocol StopTimerUseCase {
    func execute() async throws -> TimerState
}

protocol GetTimerStateUseCase {
    func execute() async throws -> TimerState
}

// MARK: - Activity Detection Use Cases

protocol DetectActivityUseCase {
    func execute(sessionId: UUID, activityType: ActivityType) async throws -> ActivityEvent
}

protocol CheckInactivityUseCase {
    func execute(sessionId: UUID, threshold: TimeInterval) async throws -> Bool
}

protocol LogBackspaceAttemptUseCase {
    func execute(sessionId: UUID) async throws -> ActivityEvent
}

// MARK: - AI Summary Use Cases

protocol GenerateSummaryUseCase {
    func execute(sessionId: UUID) async throws -> AISummary
}

protocol GetSummaryUseCase {
    func execute(sessionId: UUID) async throws -> AISummary?
}

protocol RegenerateSummaryUseCase {
    func execute(sessionId: UUID) async throws -> AISummary
}

// MARK: - Session History Use Cases

protocol GetSessionHistoryUseCase {
    func execute(limit: Int?, offset: Int?) async throws -> [WritingSession]
}

protocol SearchSessionsUseCase {
    func execute(query: String) async throws -> [WritingSession]
}

protocol GetSessionAnalyticsUseCase {
    func execute(sessionId: UUID) async throws -> SessionAnalytics
}

protocol DeleteSessionUseCase {
    func execute(sessionId: UUID) async throws
}

// MARK: - Session Analytics Domain Entity

struct SessionAnalytics: Equatable {
    let sessionId: UUID
    let totalWritingTime: TimeInterval
    let totalPauseTime: TimeInterval
    let averageTypingSpeed: Double
    let peakTypingSpeed: Double
    let totalWords: Int
    let totalCharacters: Int
    let averageSessionLength: TimeInterval
    let completionRate: Double
    let mostProductiveTime: Date?
    let writingStreak: Int
    
    var productivityScore: Double {
        let activeTime = totalWritingTime - totalPauseTime
        guard activeTime > 0 else { return 0 }
        return (Double(totalCharacters) / activeTime) * 60.0 // characters per minute
    }
    
    var efficiencyRate: Double {
        guard totalWritingTime > 0 else { return 0 }
        return (totalWritingTime - totalPauseTime) / totalWritingTime
    }
}