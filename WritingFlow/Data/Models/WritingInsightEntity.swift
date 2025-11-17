import Foundation
import SwiftData

@Model
final class WritingInsightEntity {
    var id: UUID
    var typeRaw: String
    var title: String
    var insightDescription: String
    var confidence: Double
    var actionable: Bool
    var suggestions: [String]
    
    init(
        id: UUID = UUID(),
        typeRaw: String = "productivity",
        title: String,
        insightDescription: String,
        confidence: Double,
        actionable: Bool = false,
        suggestions: [String] = []
    ) {
        self.id = id
        self.typeRaw = typeRaw
        self.title = title
        self.insightDescription = insightDescription
        self.confidence = confidence
        self.actionable = actionable
        self.suggestions = suggestions
    }
}