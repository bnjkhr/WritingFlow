import Foundation
import SwiftData

@Model
final class TextContentEntity {
    var id: UUID
    var sessionId: UUID
    var content: String
    var timestamp: Date
    var wordCount: Int
    var characterCount: Int
    var typingSpeed: Double
    
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
}