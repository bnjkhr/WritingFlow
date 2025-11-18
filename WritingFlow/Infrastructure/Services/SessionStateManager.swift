import Foundation

@MainActor
final class SessionStateManager: ObservableObject {
    @Published private(set) var currentSession: WritingSession?
    
    private let sessionRepository: WritingSessionRepository
    
    init(sessionRepository: WritingSessionRepository) {
        self.sessionRepository = sessionRepository
    }
    
    func startSession(duration: TimeInterval? = nil) async throws -> WritingSession {
        // Check if there's already an active session
        if try await sessionRepository.getActiveSession() != nil {
            throw DomainError.sessionAlreadyActive
        }
        
        let targetDuration = duration ?? (15 * 60) // Default 15 minutes
        
        let newSession = WritingSession(
            title: "Writing Session \(DateFormatter.sessionTitle.string(from: Date()))",
            startTime: Date(),
            targetDuration: targetDuration,
            state: .active
        )
        
        try await sessionRepository.createSession(newSession)
        currentSession = newSession
        
        return newSession
    }
    
    func pauseSession(sessionId: UUID) async throws -> WritingSession {
        guard var session = try await sessionRepository.getSession(id: sessionId) else {
            throw DomainError.sessionNotFound(sessionId)
        }
        
        guard session.isActive else {
            throw DomainError.sessionNotActive
        }
        
        session = WritingSession(
            id: session.id,
            title: session.title,
            content: session.content,
            startTime: session.startTime,
            endTime: session.endTime,
            duration: session.duration,
            targetDuration: session.targetDuration,
            state: .paused,
            wordCount: session.wordCount,
            characterCount: session.characterCount,
            averageTypingSpeed: session.averageTypingSpeed,
            pauseCount: session.pauseCount + 1,
            totalPauseDuration: session.totalPauseDuration
        )
        
        try await sessionRepository.updateSession(session)
        
        if currentSession?.id == sessionId {
            currentSession = session
        }
        
        return session
    }
    
    func resumeSession(sessionId: UUID) async throws -> WritingSession {
        guard var session = try await sessionRepository.getSession(id: sessionId) else {
            throw DomainError.sessionNotFound(sessionId)
        }
        
        guard session.isPaused else {
            throw DomainError.sessionNotActive
        }
        
        session = WritingSession(
            id: session.id,
            title: session.title,
            content: session.content,
            startTime: session.startTime,
            endTime: session.endTime,
            duration: session.duration,
            targetDuration: session.targetDuration,
            state: .active,
            wordCount: session.wordCount,
            characterCount: session.characterCount,
            averageTypingSpeed: session.averageTypingSpeed,
            pauseCount: session.pauseCount,
            totalPauseDuration: session.totalPauseDuration
        )
        
        try await sessionRepository.updateSession(session)
        
        if currentSession?.id == sessionId {
            currentSession = session
        }
        
        return session
    }
    
    func completeSession(sessionId: UUID) async throws -> WritingSession {
        guard var session = try await sessionRepository.getSession(id: sessionId) else {
            throw DomainError.sessionNotFound(sessionId)
        }
        
        session = WritingSession(
            id: session.id,
            title: session.title,
            content: session.content,
            startTime: session.startTime,
            endTime: Date(),
            duration: session.duration,
            targetDuration: session.targetDuration,
            state: .completed,
            wordCount: session.wordCount,
            characterCount: session.characterCount,
            averageTypingSpeed: session.averageTypingSpeed,
            pauseCount: session.pauseCount,
            totalPauseDuration: session.totalPauseDuration
        )
        
        try await sessionRepository.updateSession(session)
        
        if currentSession?.id == sessionId {
            currentSession = nil
        }
        
        return session
    }
    
    func updateSessionContent(sessionId: UUID, content: String) async throws -> WritingSession {
        guard var session = try await sessionRepository.getSession(id: sessionId) else {
            throw DomainError.sessionNotFound(sessionId)
        }
        
        let wordCount = TextContent.calculateWordCount(from: content)
        let characterCount = content.count
        
        session = WritingSession(
            id: session.id,
            title: session.title,
            content: content,
            startTime: session.startTime,
            endTime: session.endTime,
            duration: session.duration,
            targetDuration: session.targetDuration,
            state: session.state,
            wordCount: wordCount,
            characterCount: characterCount,
            averageTypingSpeed: session.averageTypingSpeed,
            pauseCount: session.pauseCount,
            totalPauseDuration: session.totalPauseDuration
        )
        
        try await sessionRepository.updateSession(session)
        
        if currentSession?.id == sessionId {
            currentSession = session
        }
        
        return session
    }
    
    func getCurrentSession() async throws -> WritingSession? {
        if let currentSession = currentSession {
            return currentSession
        }
        
        let session = try await sessionRepository.getActiveSession()
        currentSession = session
        return session
    }
}

private extension DateFormatter {
    static let sessionTitle: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter
    }()
}
