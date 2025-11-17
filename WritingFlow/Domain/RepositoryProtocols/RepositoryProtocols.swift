import Foundation
import FoundationModels

// MARK: - Repository Protocols

public protocol WritingSessionRepositoryProtocol {
    func createSession(_ session: WritingSession) async throws
    func getSession(id: UUID) async throws -> WritingSession?
    func getAllSessions() async throws -> [WritingSession]
    func getActiveSession() async throws -> WritingSession?
    func updateSession(_ session: WritingSession) async throws
    func deleteSession(id: UUID) async throws
    func getSessions(from startDate: Date, to endDate: Date) async throws -> [WritingSession]
    func searchSessions(query: String) async throws -> [WritingSession]
}

public protocol AISummaryRepositoryProtocol {
    func createSummary(_ summary: AISummary) async throws
    func getSummary(id: UUID) async throws -> AISummary?
    func getSummaries(for sessionId: UUID) async throws -> [AISummary]
    func updateSummary(_ summary: AISummary) async throws
    func deleteSummary(id: UUID) async throws
    func getRecentSummaries(limit: Int) async throws -> [AISummary]
}

public protocol ActivityEventRepositoryProtocol {
    func logEvent(_ event: ActivityEvent) async throws
    func getEvents(for sessionId: UUID) async throws -> [ActivityEvent]
    func getEvents(from startDate: Date, to endDate: Date) async throws -> [ActivityEvent]
    func deleteEvents(for sessionId: UUID) async throws
}

public protocol TextContentRepositoryProtocol {
    func saveContent(_ content: TextContent) async throws
    func getContent(id: UUID) async throws -> TextContent?
    func getContent(for sessionId: UUID) async throws -> [TextContent]
    func getLatestContent(for sessionId: UUID) async throws -> TextContent?
    func deleteContent(id: UUID) async throws
    func deleteContent(for sessionId: UUID) async throws
}