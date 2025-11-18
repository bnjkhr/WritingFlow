import Foundation
import SwiftData

@MainActor
final class DataStoreManager {
    static let shared = DataStoreManager()
    
    private init() {}
    
    lazy var container: ModelContainer = {
        do {
            return try ModelContainer(
                for: WritingSessionEntity.self,
                     ActivityEventEntity.self,
                     AISummaryEntity.self,
                     TextContentEntity.self,
                     WritingInsightEntity.self
            )
        } catch {
            fatalError("Failed to create ModelContainer: \(error)")
        }
    }()
    
    var context: ModelContext {
        return container.mainContext
    }
    
    func save() throws {
        try context.save()
    }
}