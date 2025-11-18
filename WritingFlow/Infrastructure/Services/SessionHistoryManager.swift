import Foundation
import SwiftData

// MARK: - Session History Manager

@MainActor
final class SessionHistoryManager: ObservableObject {
    private let context: ModelContext

    @Published var sessions: [SavedSession] = []

    init() {
        self.context = DataStoreManager.shared.context
        loadSessions()
    }

    // MARK: - Public Methods

    func saveSession(
        title: String,
        content: String,
        startTime: Date,
        endTime: Date,
        wordCount: Int,
        characterCount: Int,
        duration: TimeInterval
    ) {
        let entity = WritingSessionEntity(
            title: title.isEmpty ? "Session \(formatDate(startTime))" : title,
            content: content,
            startTime: startTime,
            endTime: endTime,
            duration: duration,
            targetDuration: 15 * 60,
            stateRaw: "completed",
            wordCount: wordCount,
            characterCount: characterCount,
            averageTypingSpeed: calculateWPM(words: wordCount, duration: duration),
            pauseCount: 0,
            totalPauseDuration: 0
        )

        context.insert(entity)

        do {
            try context.save()
            loadSessions()
        } catch {
            print("Failed to save session: \(error)")
        }
    }

    func deleteSession(_ session: SavedSession) {
        let sessionId = session.id
        let descriptor = FetchDescriptor<WritingSessionEntity>(
            predicate: #Predicate { $0.id == sessionId }
        )

        do {
            let entities = try context.fetch(descriptor)
            for entity in entities {
                context.delete(entity)
            }
            try context.save()
            loadSessions()
        } catch {
            print("Failed to delete session: \(error)")
        }
    }

    // MARK: - Private Methods

    private func loadSessions() {
        let descriptor = FetchDescriptor<WritingSessionEntity>(
            sortBy: [SortDescriptor(\.startTime, order: .reverse)]
        )

        do {
            let entities = try context.fetch(descriptor)
            sessions = entities.map { entity in
                SavedSession(
                    id: entity.id,
                    title: entity.title,
                    content: entity.content,
                    startTime: entity.startTime,
                    endTime: entity.endTime ?? entity.startTime,
                    wordCount: entity.wordCount,
                    characterCount: entity.characterCount,
                    duration: entity.duration,
                    averageTypingSpeed: entity.averageTypingSpeed
                )
            }
        } catch {
            print("Failed to load sessions: \(error)")
            sessions = []
        }
    }

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }

    private func calculateWPM(words: Int, duration: TimeInterval) -> Double {
        guard duration > 0 else { return 0 }
        return Double(words) / (duration / 60.0)
    }
}

// MARK: - Saved Session Model

struct SavedSession: Identifiable, Equatable {
    let id: UUID
    let title: String
    let content: String
    let startTime: Date
    let endTime: Date
    let wordCount: Int
    let characterCount: Int
    let duration: TimeInterval
    let averageTypingSpeed: Double

    var formattedDuration: String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return String(format: "%dm %ds", minutes, seconds)
    }

    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: startTime)
    }
}
