import Foundation

// MARK: - Domain Constants

struct DomainConstants {
    // Timer Constants
    static let defaultSessionDuration: TimeInterval = 15 * 60 // 15 minutes
    static let inactivityThreshold: TimeInterval = 30 // 30 seconds
    static let timerUpdateInterval: TimeInterval = 1.0 // 1 second
    
    // Text Analysis Constants
    static let minimumWordsForAnalysis = 10
    static let minimumCharactersForSummary = 50
    static let maximumSummaryLength = 500
    
    // Activity Detection Constants
    static let typingActivityTimeout: TimeInterval = 5.0
    static let backspaceDetectionEnabled = true
    
    // AI Summary Constants
    static let summaryGenerationTimeout: TimeInterval = 30.0
    static let maxRetryAttempts = 3
    
    // UI Constants
    static let maxSessionTitleLength = 100
    static let maxContentLength = 1_000_000 // 1 million characters
}

// MARK: - Domain Errors

enum DomainError: LocalizedError, Equatable {
    case sessionNotFound(UUID)
    case sessionAlreadyActive
    case sessionNotActive
    case sessionAlreadyCompleted
    case invalidDuration
    case contentTooLong
    case contentEmpty
    case aiServiceUnavailable
    case summaryGenerationFailed
    case activityDetectionFailed
    case backspaceBlockerFailed
    case timerError
    case dataCorruption
    case permissionDenied
    case networkUnavailable
    
    var errorDescription: String? {
        switch self {
        case .sessionNotFound(let id):
            return "Session with ID \(id.uuidString) not found"
        case .sessionAlreadyActive:
            return "A session is already active"
        case .sessionNotActive:
            return "No active session found"
        case .sessionAlreadyCompleted:
            return "Session has already been completed"
        case .invalidDuration:
            return "Invalid session duration"
        case .contentTooLong:
            return "Content exceeds maximum length"
        case .contentEmpty:
            return "Content cannot be empty"
        case .aiServiceUnavailable:
            return "AI service is currently unavailable"
        case .summaryGenerationFailed:
            return "Failed to generate summary"
        case .activityDetectionFailed:
            return "Activity detection failed"
        case .backspaceBlockerFailed:
            return "Backspace blocker failed"
        case .timerError:
            return "Timer error occurred"
        case .dataCorruption:
            return "Data corruption detected"
        case .permissionDenied:
            return "Permission denied"
        case .networkUnavailable:
            return "Network unavailable"
        }
    }
    
    var recoverySuggestion: String? {
        switch self {
        case .sessionNotFound:
            return "Please check the session ID and try again"
        case .sessionAlreadyActive:
            return "Complete or pause the current session first"
        case .sessionNotActive:
            return "Start a new session to continue"
        case .sessionAlreadyCompleted:
            return "Start a new session to continue writing"
        case .invalidDuration:
            return "Please provide a valid duration between 1 and 60 minutes"
        case .contentTooLong:
            return "Please reduce the content length"
        case .contentEmpty:
            return "Please add some content before saving"
        case .aiServiceUnavailable:
            return "Please check your internet connection and try again"
        case .summaryGenerationFailed:
            return "Please try generating the summary again"
        case .activityDetectionFailed:
            return "Please restart the session"
        case .backspaceBlockerFailed:
            return "Please restart the application"
        case .timerError:
            return "Please restart the timer"
        case .dataCorruption:
            return "Please restore from backup if available"
        case .permissionDenied:
            return "Please check your app permissions"
        case .networkUnavailable:
            return "Please check your internet connection"
        }
    }
}

// MARK: - Validation Utilities

struct ValidationUtils {
    static func isValidSessionDuration(_ duration: TimeInterval) -> Bool {
        return duration >= 60 && duration <= 3600 // 1 minute to 1 hour
    }
    
    static func isValidContent(_ content: String) -> Bool {
        return !content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    static func isValidContentLength(_ content: String) -> Bool {
        return content.count <= DomainConstants.maxContentLength
    }
    
    static func isValidSessionTitle(_ title: String) -> Bool {
        return title.count <= DomainConstants.maxSessionTitleLength
    }
    
    static func canGenerateSummary(for content: String) -> Bool {
        return content.count >= DomainConstants.minimumCharactersForSummary
    }
    
    static func canAnalyzeText(_ content: String) -> Bool {
        let words = content.components(separatedBy: .whitespacesAndNewlines)
        let filteredWords = words.filter { !$0.isEmpty }
        return filteredWords.count >= DomainConstants.minimumWordsForAnalysis
    }
}