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