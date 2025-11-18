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