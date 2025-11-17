import Foundation
import FoundationModels

// MARK: - Timer Engine Service

protocol TimerEngineProtocol {
    func start(duration: TimeInterval)
    func pause()
    func resume()
    func stop()
    func reset()
    var currentState: TimerState { get }
}

// MARK: - Activity Detector Service

protocol ActivityDetectorProtocol {
    func startActivityDetection(for sessionId: UUID)
    func stopActivityDetection()
    func logTypingActivity()
    func logBackspaceAttempt()
}

// MARK: - Backspace Blocker Service

protocol BackspaceBlockerProtocol {
    func enableBlocking()
    func disableBlocking()
    var isBlockingEnabled: Bool { get }
}

// MARK: - AI Summary Service

protocol AISummaryServiceProtocol {
    func generateSummary(for content: String) async throws -> AISummary
    func isAvailable() -> Bool
}

// MARK: - Text Statistics Service

protocol TextStatisticsServiceProtocol {
    func calculateWordCount(from text: String) -> Int
    func calculateCharacterCount(from text: String) -> Int
    func calculateTypingSpeed(characters: Int, timeInterval: TimeInterval) -> Double
    func calculateReadabilityScore(from text: String) -> Double
    func extractThemes(from text: String) -> [String]
    func analyzeMood(from text: String) -> WritingMood
}

// MARK: - Session State Manager Service

protocol SessionStateManagerProtocol {
    func startSession(duration: TimeInterval?) async throws -> WritingSession
    func pauseSession(sessionId: UUID) async throws -> WritingSession
    func resumeSession(sessionId: UUID) async throws -> WritingSession
    func completeSession(sessionId: UUID) async throws -> WritingSession
    func updateSessionContent(sessionId: UUID, content: String) async throws -> WritingSession
    func getCurrentSession() async throws -> WritingSession?
}