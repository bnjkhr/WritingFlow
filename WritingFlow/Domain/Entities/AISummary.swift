import Foundation

// MARK: - AI Summary Domain Entity

struct AISummary: Identifiable, Equatable {
    let id: UUID
    let sessionId: UUID
    let summary: String
    let insights: [WritingInsight]
    let themes: [String]
    let mood: WritingMood
    let wordCount: Int
    let averageSentenceLength: Double
    let readabilityScore: Double
    let generatedAt: Date
    
    init(
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

// MARK: - Writing Insight

struct WritingInsight: Identifiable, Equatable {
    let id: UUID
    let type: InsightType
    let title: String
    let description: String
    let confidence: Double // 0.0 to 1.0
    let actionable: Bool
    let suggestions: [String]
    
    init(
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

// MARK: - Insight Type

enum InsightType: String, CaseIterable, Equatable {
    case productivity = "productivity"
    case consistency = "consistency"
    case creativity = "creativity"
    case structure = "structure"
    case vocabulary = "vocabulary"
    case flow = "flow"
    case mood = "mood"
    
    var displayName: String {
        switch self {
        case .productivity:
            return "Productivity"
        case .consistency:
            return "Consistency"
        case .creativity:
            return "Creativity"
        case .structure:
            return "Structure"
        case .vocabulary:
            return "Vocabulary"
        case .flow:
            return "Writing Flow"
        case .mood:
            return "Mood Analysis"
        }
    }
    
    var icon: String {
        switch self {
        case .productivity:
            return "chart.line.uptrend.xyaxis"
        case .consistency:
            return "calendar.badge.clock"
        case .creativity:
            return "lightbulb"
        case .structure:
            return "list.bullet.rectangle"
        case .vocabulary:
            return "text.book.closed"
        case .flow:
            return "waveform.path"
        case .mood:
            return "face.smiling"
        }
    }
}

// MARK: - Writing Mood

enum WritingMood: String, CaseIterable, Equatable {
    case enthusiastic = "enthusiastic"
    case focused = "focused"
    case reflective = "reflective"
    case creative = "creative"
    case analytical = "analytical"
    case neutral = "neutral"
    case tired = "tired"
    case stressed = "stressed"
    
    var displayName: String {
        switch self {
        case .enthusiastic:
            return "Enthusiastic"
        case .focused:
            return "Focused"
        case .reflective:
            return "Reflective"
        case .creative:
            return "Creative"
        case .analytical:
            return "Analytical"
        case .neutral:
            return "Neutral"
        case .tired:
            return "Tired"
        case .stressed:
            return "Stressed"
        }
    }
    
    var color: String {
        switch self {
        case .enthusiastic:
            return "orange"
        case .focused:
            return "blue"
        case .reflective:
            return "purple"
        case .creative:
            return "pink"
        case .analytical:
            return "green"
        case .neutral:
            return "gray"
        case .tired:
            return "indigo"
        case .stressed:
            return "red"
        }
    }
    
    var icon: String {
        switch self {
        case .enthusiastic:
            return "face.dashed"
        case .focused:
            return "eye.circle"
        case .reflective:
            return "moon.circle"
        case .creative:
            return "paintbrush.pointed"
        case .analytical:
            return "magnifyingglass.circle"
        case .neutral:
            return "circle"
        case .tired:
            return "bed.double.circle"
        case .stressed:
            return "exclamationmark.triangle"
        }
    }
}

// MARK: - Activity Detection Domain Entity

struct ActivityEvent: Identifiable, Equatable {
    let id: UUID
    let sessionId: UUID
    let timestamp: Date
    let type: ActivityType
    let duration: TimeInterval
    let metadata: [String: String]
    
    init(
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

// MARK: - Activity Type

enum ActivityType: String, CaseIterable, Equatable {
    case typing = "typing"
    case pause = "pause"
    case backspaceAttempt = "backspaceAttempt"
    case idle = "idle"
    case resume = "resume"
    case completion = "completion"
    
    var displayName: String {
        switch self {
        case .typing:
            return "Typing"
        case .pause:
            return "Pause"
        case .backspaceAttempt:
            return "Backspace Attempt"
        case .idle:
            return "Idle"
        case .resume:
            return "Resume"
        case .completion:
            return "Completion"
        }
    }
}