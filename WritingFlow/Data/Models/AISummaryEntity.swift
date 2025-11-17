import Foundation
import SwiftData

@Model
final class AISummaryEntity {
    var id: UUID
    var sessionId: UUID
    var summary: String
    var moodRaw: String
    var wordCount: Int
    var averageSentenceLength: Double
    var readabilityScore: Double
    var generatedAt: Date
    
    init(
        id: UUID = UUID(),
        sessionId: UUID,
        summary: String = "",
        moodRaw: String = "neutral",
        wordCount: Int = 0,
        averageSentenceLength: Double = 0,
        readabilityScore: Double = 0,
        generatedAt: Date = Date()
    ) {
        self.id = id
        self.sessionId = sessionId
        self.summary = summary
        self.moodRaw = moodRaw
        self.wordCount = wordCount
        self.averageSentenceLength = averageSentenceLength
        self.readabilityScore = readabilityScore
        self.generatedAt = generatedAt
    }
}