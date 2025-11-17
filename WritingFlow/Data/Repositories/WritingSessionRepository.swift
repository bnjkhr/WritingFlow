import Foundation
import SwiftData

@MainActor
final class WritingSessionRepository: WritingSessionRepositoryProtocol {
    private let context: ModelContext
    
    init(context: ModelContext = DataStoreManager.shared.context) {
        self.context = context
    }
    
    func createSession(_ session: WritingSession) async throws {
        let entity = WritingSessionEntity(
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
        
        context.insert(entity)
        try context.save()
    }
    
    func getSession(id: UUID) async throws -> WritingSession? {
        let descriptor = FetchDescriptor<WritingSessionEntity>(
            predicate: #Predicate { $0.id == id }
        )
        
        guard let entity = try context.fetch(descriptor).first else {
            return nil
        }
        
        return entity.toDomain()
    }
    
    func getAllSessions() async throws -> [WritingSession] {
        let descriptor = FetchDescriptor<WritingSessionEntity>(
            sortBy: [SortDescriptor(\.startTime, order: .reverse)]
        )
        
        let entities = try context.fetch(descriptor)
        return entities.map { $0.toDomain() }
    }
    
    func getActiveSession() async throws -> WritingSession? {
        let descriptor = FetchDescriptor<WritingSessionEntity>(
            predicate: #Predicate { $0.stateRaw == SessionState.active.rawValue }
        )
        
        guard let entity = try context.fetch(descriptor).first else {
            return nil
        }
        
        return entity.toDomain()
    }
    
    func updateSession(_ session: WritingSession) async throws {
        let descriptor = FetchDescriptor<WritingSessionEntity>(
            predicate: #Predicate { $0.id == session.id }
        )
        
        guard let entity = try context.fetch(descriptor).first else {
            throw DomainError.sessionNotFound(session.id)
        }
        
        entity.title = session.title
        entity.content = session.content
        entity.endTime = session.endTime
        entity.duration = session.duration
        entity.stateRaw = session.state.rawValue
        entity.wordCount = session.wordCount
        entity.characterCount = session.characterCount
        entity.averageTypingSpeed = session.averageTypingSpeed
        entity.pauseCount = session.pauseCount
        entity.totalPauseDuration = session.totalPauseDuration
        
        try context.save()
    }
    
    func deleteSession(id: UUID) async throws {
        let descriptor = FetchDescriptor<WritingSessionEntity>(
            predicate: #Predicate { $0.id == id }
        )
        
        guard let entity = try context.fetch(descriptor).first else {
            throw DomainError.sessionNotFound(id)
        }
        
        context.delete(entity)
        try context.save()
    }
    
    func getSessions(from startDate: Date, to endDate: Date) async throws -> [WritingSession] {
        let descriptor = FetchDescriptor<WritingSessionEntity>(
            predicate: #Predicate { $0.startTime >= startDate && $0.startTime <= endDate },
            sortBy: [SortDescriptor(\.startTime, order: .reverse)]
        )
        
        let entities = try context.fetch(descriptor)
        return entities.map { $0.toDomain() }
    }
    
    func searchSessions(query: String) async throws -> [WritingSession] {
        let descriptor = FetchDescriptor<WritingSessionEntity>(
            predicate: #Predicate { $0.title.localizedStandardContains(query) || $0.content.localizedStandardContains(query) },
            sortBy: [SortDescriptor(\.startTime, order: .reverse)]
        )
        
        let entities = try context.fetch(descriptor)
        return entities.map { $0.toDomain() }
    }
}