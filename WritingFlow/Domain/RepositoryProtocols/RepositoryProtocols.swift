import Foundation

// Import domain entities to resolve types
// Note: These will be properly imported when Xcode project is set up

// MARK: - Writing Session Repository Protocol

protocol WritingSessionRepositoryProtocol {
    func createSession(_ session: WritingSession) async throws
    func getSession(id: UUID) async throws -> WritingSession?
    func getAllSessions() async throws -> [WritingSession]
    func getActiveSession() async throws -> WritingSession?
    func updateSession(_ session: WritingSession) async throws
    func deleteSession(id: UUID) async throws
    func getSessions(from startDate: Date, to endDate: Date) async throws -> [WritingSession]
    func searchSessions(query: String) async throws -> [WritingSession]
}

// MARK: - AI Summary Repository Protocol

protocol AISummaryRepositoryProtocol {
    func createSummary(_ summary: AISummary) async throws
    func getSummary(id: UUID) async throws -> AISummary?
    func getSummary(for sessionId: UUID) async throws -> AISummary?
    func getAllSummaries() async throws -> [AISummary]
    func updateSummary(_ summary: AISummary) async throws
    func deleteSummary(id: UUID) async throws
    func getSummaries(from startDate: Date, to endDate: Date) async throws -> [AISummary]
}

// MARK: - Activity Event Repository Protocol

protocol ActivityEventRepositoryProtocol {
    func createEvent(_ event: ActivityEvent) async throws
    func getEvents(for sessionId: UUID) async throws -> [ActivityEvent]
    func getAllEvents() async throws -> [ActivityEvent]
    func deleteEvents(for sessionId: UUID) async throws
    func getEvents(from startDate: Date, to endDate: Date) async throws -> [ActivityEvent]
}

// MARK: - Text Content Repository Protocol

protocol TextContentRepositoryProtocol {
    func saveContent(_ content: TextContent) async throws
    func getContent(for sessionId: UUID) async throws -> TextContent?
    func getAllContent() async throws -> [TextContent]
    func deleteContent(for sessionId: UUID) async throws
    func searchContent(query: String) async throws -> [TextContent]
}