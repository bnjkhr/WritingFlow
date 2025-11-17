import Foundation
import SwiftData

@Model
final class ActivityEventEntity {
    var id: UUID
    var sessionId: UUID
    var timestamp: Date
    var typeRaw: String
    var duration: Double
    var metadata: [String: String]
    
    init(
        id: UUID = UUID(),
        sessionId: UUID,
        timestamp: Date = Date(),
        typeRaw: String = "typing",
        duration: Double = 0,
        metadata: [String: String] = [:]
    ) {
        self.id = id
        self.sessionId = sessionId
        self.timestamp = timestamp
        self.typeRaw = typeRaw
        self.duration = duration
        self.metadata = metadata
    }
}