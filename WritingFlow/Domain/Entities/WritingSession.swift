import Foundation

// MARK: - Domain Entities

public struct WritingSession {
    public let id: UUID
    public var title: String
    public var content: String
    public let startTime: Date
    public var endTime: Date?
    public var duration: TimeInterval
    public let targetDuration: TimeInterval
    public var state: SessionState
    public var wordCount: Int
    public var characterCount: Int
    public var averageTypingSpeed: Double
    public var pauseCount: Int
    public var totalPauseDuration: TimeInterval
    
    public init(
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

public enum SessionState: String, CaseIterable, Codable {
    case notStarted = "notStarted"
    case active = "active"
    case paused = "paused"
    case completed = "completed"
    case cancelled = "cancelled"
    
    public var isActive: Bool {
        return self == .active
    }
    
    public var isPaused: Bool {
        return self == .paused
    }
    
    public var isCompleted: Bool {
        return self == .completed
    }
    
    public var isFinished: Bool {
        return isCompleted || isCancelled
    }
    
    public var isCancelled: Bool {
        return self == .cancelled
    }
}

public struct AISummary {
    public let id: UUID
    public let sessionId: UUID
    public let summary: String
    public let insights: [WritingInsight]
    public let themes: [String]
    public let mood: WritingMood
    public let wordCount: Int
    public let averageSentenceLength: Double
    public let readabilityScore: Double
    public let generatedAt: Date
    
    public init(
        id: UUID = UUID(),
        sessionId: UUID,
        summary: String = "",
        insights: [WritingInsight] = [],
        themes: [String] = [],
        mood: WritingMood = .neutral,
        wordCount: Int = 0,
        averageSentenceLength: Double = 0,
        readabilityScore: Double = 0,
        generatedAt: Date = Date()
    ) {
        self.id = id
        self.sessionId = sessionId
        self.summary = summary
        self.insights = insights
        self.themes = themes
        self.mood = mood
        self.wordCount = wordCount
        self.averageSentenceLength = averageSentenceLength
        self.readabilityScore = readabilityScore
        self.generatedAt = generatedAt
    }
}

public struct WritingInsight {
    public let id: UUID
    public let type: InsightType
    public let title: String
    public let description: String
    public let confidence: Double
    public let actionable: Bool
    public let suggestions: [String]
    
    public init(
        id: UUID = UUID(),
        type: InsightType,
        title: String,
        description: String,
        confidence: Double,
        actionable: Bool = false,
        suggestions: [String] = []
    ) {
        self.id = id
        self.type = type
        self.title = title
        self.description = description
        self.confidence = confidence
        self.actionable = actionable
        self.suggestions = suggestions
    }
}

public enum InsightType: String, CaseIterable, Codable {
    case productivity = "productivity"
    case style = "style"
    case mood = "mood"
    case structure = "structure"
    case vocabulary = "vocabulary"
    case flow = "flow"
    case consistency = "consistency"
}

public enum WritingMood: String, CaseIterable, Codable {
    case enthusiastic = "enthusiastic"
    case focused = "focused"
    case reflective = "reflective"
    case creative = "creative"
    case analytical = "analytical"
    case neutral = "neutral"
    case tired = "tired"
    case stressed = "stressed"
}

public struct ActivityEvent {
    public let id: UUID
    public let sessionId: UUID
    public let timestamp: Date
    public let type: ActivityType
    public let duration: TimeInterval
    public let metadata: [String: String]
    
    public init(
        id: UUID = UUID(),
        sessionId: UUID,
        timestamp: Date = Date(),
        type: ActivityType,
        duration: TimeInterval = 0,
        metadata: [String: String] = [:]
    ) {
        self.id = id
        self.sessionId = sessionId
        self.timestamp = timestamp
        self.type = type
        self.duration = duration
        self.metadata = metadata
    }
}

public enum ActivityType: String, CaseIterable, Codable {
    case typing = "typing"
    case pause = "pause"
    case backspace = "backspace"
    case idle = "idle"
    case focus = "focus"
    case distraction = "distraction"
}

public struct TextContent {
    public let id: UUID
    public let sessionId: UUID
    public let content: String
    public let timestamp: Date
    public let wordCount: Int
    public let characterCount: Int
    public let typingSpeed: Double
    
    public init(
        id: UUID = UUID(),
        sessionId: UUID,
        content: String = "",
        timestamp: Date = Date(),
        wordCount: Int = 0,
        characterCount: Int = 0,
        typingSpeed: Double = 0
    ) {
        self.id = id
        self.sessionId = sessionId
        self.content = content
        self.timestamp = timestamp
        self.wordCount = wordCount
        self.characterCount = characterCount
        self.typingSpeed = typingSpeed
    }
    
    public static func calculateWordCount(from text: String) -> Int {
        let words = text.components(separatedBy: .whitespacesAndNewlines)
        return words.filter { !$0.isEmpty }.count
    }
}

public struct TimerState {
    public let remainingTime: TimeInterval
    public let isRunning: Bool
    public let isPaused: Bool
    public let isExpired: Bool
    public let lastUpdateTime: Date
    
    public init(
        remainingTime: TimeInterval = 15 * 60,
        isRunning: Bool = false,
        isPaused: Bool = false,
        isExpired: Bool = false,
        lastUpdateTime: Date = Date()
    ) {
        self.remainingTime = remainingTime
        self.isRunning = isRunning
        self.isPaused = isPaused
        self.isExpired = isExpired
        self.lastUpdateTime = lastUpdateTime
    }
}

// MARK: - Domain Errors

public enum DomainError: LocalizedError, Equatable {
    case sessionNotFound(UUID)
    case sessionAlreadyActive
    case sessionNotActive
    case sessionCannotBeCompleted
    case invalidSessionDuration
    case invalidSessionState
    case dataCorruption
    case networkUnavailable
    case aiServiceUnavailable
    case insufficientPermissions
    case invalidInput(String)
    case operationTimeout
    case unknown(String)
    
    public var errorDescription: String? {
        switch self {
        case .sessionNotFound(let id):
            return "Session with ID \(id.uuidString) not found"
        case .sessionAlreadyActive:
            return "A session is already active"
        case .sessionNotActive:
            return "No active session found"
        case .sessionCannotBeCompleted:
            return "Session cannot be completed in current state"
        case .invalidSessionDuration:
            return "Invalid session duration"
        case .invalidSessionState:
            return "Invalid session state"
        case .dataCorruption:
            return "Data corruption detected"
        case .networkUnavailable:
            return "Network is unavailable"
        case .aiServiceUnavailable:
            return "AI service is unavailable"
        case .insufficientPermissions:
            return "Insufficient permissions"
        case .invalidInput(let message):
            return "Invalid input: \(message)"
        case .operationTimeout:
            return "Operation timed out"
        case .unknown(let message):
            return "Unknown error: \(message)"
        }
    }
}