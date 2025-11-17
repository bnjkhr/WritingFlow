import Foundation

// MARK: - Writing Session Domain Entity

struct WritingSession: Identifiable, Equatable {
    let id: UUID
    let title: String
    let content: String
    let startTime: Date
    let endTime: Date?
    let duration: TimeInterval // in seconds
    let targetDuration: TimeInterval // target duration (15 minutes default)
    let state: SessionState
    let wordCount: Int
    let characterCount: Int
    let averageTypingSpeed: Double // characters per minute
    let pauseCount: Int
    let totalPauseDuration: TimeInterval
    
    init(
        id: UUID = UUID(),
        title: String = "",
        content: String = "",
        startTime: Date = Date(),
        endTime: Date? = nil,
        duration: TimeInterval = 0,
        targetDuration: TimeInterval = 15 * 60, // 15 minutes
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
    
    var isActive: Bool {
        state == .active
    }
    
    var isPaused: Bool {
        state == .paused
    }
    
    var isCompleted: Bool {
        state == .completed
    }
    
    var isExpired: Bool {
        state == .expired
    }
    
    var remainingTime: TimeInterval {
        max(0, targetDuration - duration)
    }
    
    var progress: Double {
        min(1.0, duration / targetDuration)
    }
    
    var formattedDuration: String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    var formattedRemainingTime: String {
        let minutes = Int(remainingTime) / 60
        let seconds = Int(remainingTime) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

// MARK: - Session State

enum SessionState: String, CaseIterable, Equatable {
    case notStarted = "notStarted"
    case active = "active"
    case paused = "paused"
    case completed = "completed"
    case expired = "expired"
    
    var displayName: String {
        switch self {
        case .notStarted:
            return "Not Started"
        case .active:
            return "Active"
        case .paused:
            return "Paused"
        case .completed:
            return "Completed"
        case .expired:
            return "Expired"
        }
    }
    
    var isActive: Bool {
        self == .active
    }
    
    var isFinished: Bool {
        switch self {
        case .completed, .expired:
            return true
        default:
            return false
        }
    }
}

// MARK: - Text Content Domain Entity

struct TextContent: Equatable {
    let id: UUID
    let sessionId: UUID
    let content: String
    let timestamp: Date
    let wordCount: Int
    let characterCount: Int
    let typingSpeed: Double // characters per minute since last update
    
    init(
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
    
    static func calculateWordCount(from text: String) -> Int {
        let words = text.components(separatedBy: .whitespacesAndNewlines)
        return words.filter { !$0.isEmpty }.count
    }
    
    static func calculateTypingSpeed(
        characters: Int,
        timeInterval: TimeInterval
    ) -> Double {
        guard timeInterval > 0 else { return 0 }
        return (Double(characters) / timeInterval) * 60.0 // characters per minute
    }
}

// MARK: - Timer State Domain Entity

struct TimerState: Equatable {
    let remainingTime: TimeInterval
    let isRunning: Bool
    let isPaused: Bool
    let isExpired: Bool
    let lastUpdateTime: Date
    
    init(
        remainingTime: TimeInterval = 15 * 60, // 15 minutes default
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
    
    var formattedTime: String {
        let minutes = Int(max(0, remainingTime)) / 60
        let seconds = Int(max(0, remainingTime)) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    var progress: Double {
        let totalTime = 15.0 * 60.0 // 15 minutes
        let elapsed = totalTime - remainingTime
        return min(1.0, max(0.0, elapsed / totalTime))
    }
    
    var isCritical: Bool {
        remainingTime <= 60 && isRunning // Last minute
    }
    
    var isWarning: Bool {
        remainingTime <= 300 && isRunning // Last 5 minutes
    }
}