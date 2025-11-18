import Foundation
import SwiftData

@Model
final class WritingSessionEntity {
    var id: UUID
    var title: String
    var content: String
    var startTime: Date
    var endTime: Date?
    var duration: Double
    var targetDuration: Double
    var stateRaw: String
    var wordCount: Int
    var characterCount: Int
    var averageTypingSpeed: Double
    var pauseCount: Int
    var totalPauseDuration: Double
    
    init(
        id: UUID = UUID(),
        title: String = "",
        content: String = "",
        startTime: Date = Date(),
        endTime: Date? = nil,
        duration: Double = 0,
        targetDuration: Double = 15 * 60,
        stateRaw: String = "notStarted",
        wordCount: Int = 0,
        characterCount: Int = 0,
        averageTypingSpeed: Double = 0,
        pauseCount: Int = 0,
        totalPauseDuration: Double = 0
    ) {
        self.id = id
        self.title = title
        self.content = content
        self.startTime = startTime
        self.endTime = endTime
        self.duration = duration
        self.targetDuration = targetDuration
        self.stateRaw = stateRaw
        self.wordCount = wordCount
        self.characterCount = characterCount
        self.averageTypingSpeed = averageTypingSpeed
        self.pauseCount = pauseCount
        self.totalPauseDuration = totalPauseDuration
    }
}

extension WritingSessionEntity {
    convenience init(from session: WritingSession) {
        self.init(
            id: session.id,
            title: session.title,
            content: session.content,
            startTime: session.startTime,
            endTime: session.endTime,
            duration: session.duration,
            targetDuration: session.targetDuration,
            stateRaw: session.state.rawValue,
            wordCount: session.wordCount,
            characterCount: session.characterCount,
            averageTypingSpeed: session.averageTypingSpeed,
            pauseCount: session.pauseCount,
            totalPauseDuration: session.totalPauseDuration
        )
    }
    
    func update(from session: WritingSession) {
        title = session.title
        content = session.content
        startTime = session.startTime
        endTime = session.endTime
        duration = session.duration
        targetDuration = session.targetDuration
        stateRaw = session.state.rawValue
        wordCount = session.wordCount
        characterCount = session.characterCount
        averageTypingSpeed = session.averageTypingSpeed
        pauseCount = session.pauseCount
        totalPauseDuration = session.totalPauseDuration
    }
    
    func toDomain() -> WritingSession {
        WritingSession(
            id: id,
            title: title,
            content: content,
            startTime: startTime,
            endTime: endTime,
            duration: duration,
            targetDuration: targetDuration,
            state: SessionState(rawValue: stateRaw) ?? .notStarted,
            wordCount: wordCount,
            characterCount: characterCount,
            averageTypingSpeed: averageTypingSpeed,
            pauseCount: pauseCount,
            totalPauseDuration: totalPauseDuration
        )
    }
}
