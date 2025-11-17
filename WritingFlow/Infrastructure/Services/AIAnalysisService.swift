import Foundation

// Define local types for now
enum WritingMood: String, CaseIterable {
    case enthusiastic = "enthusiastic"
    case focused = "focused"
    case reflective = "reflective"
    case creative = "creative"
    case analytical = "analytical"
    case neutral = "neutral"
    case tired = "tired"
    case stressed = "stressed"
}

struct WritingSession {
    let id: UUID
    var title: String
    var content: String
    let startTime: Date
    var endTime: Date?
    var duration: TimeInterval
    let targetDuration: TimeInterval
    var state: SessionState
    var wordCount: Int
    var characterCount: Int
    var averageTypingSpeed: Double
    var pauseCount: Int
    var totalPauseDuration: TimeInterval
    
    init(
        id: UUID = UUID(),
        title: String = "",
        content: String = "",
        startTime: Date = Date(),
        endTime: Date? = nil,
        duration: TimeInterval = 0,
        targetDuration: TimeInterval = 15 * 60,
        state: SessionState = .notStarted,
        wordCount: Int = 0,
        characterCount: Int = 0,
        averageTypingSpeed: Double = 0,
        pauseCount: Int = 0,
        totalPauseDuration: TimeInterval = 0
    ) {
        self.id = id
        self.title = title
        self.content = content
        self.startTime = startTime
        self.endTime = endTime
        self.duration = duration
        self.targetDuration = targetDuration
        self.state = state
        self.wordCount = wordCount
        self.characterCount = characterCount
        self.averageTypingSpeed = averageTypingSpeed
        self.pauseCount = pauseCount
        self.totalPauseDuration = totalPauseDuration
    }
}

enum SessionState: String, CaseIterable {
    case notStarted = "notStarted"
    case active = "active"
    case paused = "paused"
    case completed = "completed"
    case cancelled = "cancelled"
    
    var isActive: Bool {
        return self == .active
    }
    
    var isPaused: Bool {
        return self == .paused
    }
    
    var isCompleted: Bool {
        return self == .completed
    }
    
    var isFinished: Bool {
        return isCompleted || isCancelled
    }
    
    var isCancelled: Bool {
        return self == .cancelled
    }
}

@MainActor
final class AIAnalysisService {
    
    init() {
        // Foundation Models will be available in iOS 26 / macOS 16
        // For now, we'll use a simple text analysis approach
    }
    
    func analyzeText(_ text: String) async throws -> AIAnalysisResult {
        // Simple text analysis without Foundation Models
        let wordCount = text.components(separatedBy: .whitespacesAndNewlines).filter { !$0.isEmpty }.count
        let mood = analyzeMood(text)
        let themes = extractThemes(text)
        let insights = generateInsights(text, wordCount: wordCount)
        let style = analyzeStyle(text)
        let suggestions = generateSuggestions(text, mood: mood)
        let readabilityScore = calculateReadabilityScore(text)
        
        return AIAnalysisResult(
            mood: mood,
            themes: themes,
            insights: insights,
            style: style,
            suggestions: suggestions,
            wordCount: wordCount,
            readabilityScore: readabilityScore
        )
    }
    
    private func analyzeMood(_ text: String) -> WritingMood {
        let lowercaseText = text.lowercased()
        
        if lowercaseText.contains("excited") || lowercaseText.contains("amazing") {
            return .enthusiastic
        } else if lowercaseText.contains("focus") || lowercaseText.contains("concentrate") {
            return .focused
        } else if lowercaseText.contains("think") || lowercaseText.contains("reflect") {
            return .reflective
        } else if lowercaseText.contains("create") || lowercaseText.contains("imagine") {
            return .creative
        } else if lowercaseText.contains("analyze") || lowercaseText.contains("examine") {
            return .analytical
        } else if lowercaseText.contains("tired") || lowercaseText.contains("exhausted") {
            return .tired
        } else if lowercaseText.contains("stress") || lowercaseText.contains("worry") {
            return .stressed
        } else {
            return .neutral
        }
    }
    
    private func extractThemes(_ text: String) -> [String] {
        let commonThemes = [
            "creativity", "productivity", "mindfulness", "reflection",
            "planning", "goals", "ideas", "inspiration", "motivation",
            "focus", "routine", "habits", "growth", "learning"
        ]
        
        let lowercaseText = text.lowercased()
        var foundThemes: [String] = []
        
        for theme in commonThemes {
            if lowercaseText.contains(theme) {
                foundThemes.append(theme)
            }
        }
        
        return foundThemes
    }
    
    private func generateInsights(_ text: String, wordCount: Int) -> [String] {
        var insights: [String] = []
        
        if wordCount > 500 {
            insights.append("Strong productivity with \(wordCount) words written")
        }
        
        if text.contains("?") {
            insights.append("Exploratory writing with questioning approach")
        }
        
        let sentences = text.components(separatedBy: CharacterSet(charactersIn: ".!?"))
        if sentences.count > 10 {
            insights.append("Well-structured writing with clear sentence breaks")
        }
        
        return insights
    }
    
    private func analyzeStyle(_ text: String) -> [String] {
        var style: [String] = []
        
        let words = text.components(separatedBy: .whitespacesAndNewlines)
        let averageWordLength = words.reduce(0, { $0 + $1.count }) / max(1, words.count)
        
        if averageWordLength > 6 {
            style.append("Uses sophisticated vocabulary")
        } else if averageWordLength < 4 {
            style.append("Concise and direct writing style")
        }
        
        if text.contains("I") || text.contains("my") {
            style.append("Personal and reflective tone")
        }
        
        return style
    }
    
    private func generateSuggestions(_ text: String, mood: WritingMood) -> [String] {
        var suggestions: [String] = []
        
        switch mood {
        case .tired, .stressed:
            suggestions.append("Consider taking a short break to refresh your mind")
            suggestions.append("Try writing in a different environment")
        case .neutral:
            suggestions.append("Try adding more descriptive details to engage readers")
            suggestions.append("Consider varying sentence structure for better flow")
        case .creative:
            suggestions.append("Great creative flow! Consider organizing ideas into sections")
        case .focused:
            suggestions.append("Excellent focus! Maintain this momentum")
        default:
            suggestions.append("Continue developing your unique voice")
        }
        
        return suggestions
    }
    
    private func calculateReadabilityScore(_ text: String) -> Double {
        let sentences = text.components(separatedBy: CharacterSet(charactersIn: ".!?"))
            .filter { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
        
        guard !sentences.isEmpty else { return 50 }
        
        let words = text.components(separatedBy: .whitespacesAndNewlines)
            .filter { !$0.isEmpty }
        
        let averageSentenceLength = Double(words.count) / Double(sentences.count)
        
        // Simple readability score based on sentence length
        let idealLength = 15.0
        let deviation = abs(averageSentenceLength - idealLength)
        let score = max(0, 100 - (deviation * 2))
        
        return min(100, score)
    }
}

// MARK: - Supporting Types

struct AIAnalysisResult {
    let mood: WritingMood
    let themes: [String]
    let insights: [String]
    let style: [String]
    let suggestions: [String]
    let wordCount: Int
    let readabilityScore: Double
}

enum AIAnalysisError: LocalizedError {
    case modelUnavailable
    case invalidResponse
    case processingFailed
    
    var errorDescription: String? {
        switch self {
        case .modelUnavailable:
            return "AI model is not available on this device"
        case .invalidResponse:
            return "Invalid response from AI model"
        case .processingFailed:
            return "Failed to process text analysis"
        }
    }
}