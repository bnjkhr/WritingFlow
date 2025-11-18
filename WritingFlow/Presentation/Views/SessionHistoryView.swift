import SwiftUI

// MARK: - Session History View

struct SessionHistoryView: View {
    @StateObject private var historyManager = SessionHistoryManager()
    @State private var selectedSession: SavedSession?
    @State private var showingSessionDetail = false
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ZStack {
                if historyManager.sessions.isEmpty {
                    emptyStateView
                } else {
                    sessionListView
                }
            }
            .navigationTitle("Session History")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
        .frame(minWidth: 700, minHeight: 500)
        .sheet(item: $selectedSession) { session in
            SessionDetailView(session: session)
        }
    }

    // MARK: - Empty State

    private var emptyStateView: some View {
        VStack(spacing: 24) {
            Image(systemName: "tray")
                .font(.system(size: 60))
                .foregroundColor(.secondary.opacity(0.5))

            VStack(spacing: 8) {
                Text("No Sessions Yet")
                    .font(.title2)
                    .fontWeight(.bold)

                Text("Complete a writing session to see it here")
                    .font(.body)
                    .foregroundColor(.secondary)
            }
        }
    }

    // MARK: - Session List

    private var sessionListView: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                ForEach(historyManager.sessions) { session in
                    SessionCard(session: session)
                        .onTapGesture {
                            selectedSession = session
                            showingSessionDetail = true
                        }
                        .contextMenu {
                            Button(role: .destructive) {
                                withAnimation {
                                    historyManager.deleteSession(session)
                                }
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                }
            }
            .padding(20)
        }
    }
}

// MARK: - Session Card

struct SessionCard: View {
    let session: SavedSession

    var body: some View {
        HStack(spacing: 16) {
            // Icon
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color.blue.opacity(0.2), Color.purple.opacity(0.2)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 60, height: 60)

                Image(systemName: "doc.text.fill")
                    .font(.title2)
                    .foregroundColor(.blue)
            }

            // Content
            VStack(alignment: .leading, spacing: 8) {
                Text(session.title)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .lineLimit(1)

                Text(session.formattedDate)
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                HStack(spacing: 16) {
                    StatBadge(
                        icon: "doc.text",
                        value: "\(session.wordCount)",
                        label: "words"
                    )

                    StatBadge(
                        icon: "clock",
                        value: session.formattedDuration,
                        label: ""
                    )

                    StatBadge(
                        icon: "gauge",
                        value: String(format: "%.0f", session.averageTypingSpeed),
                        label: "wpm"
                    )
                }
            }

            Spacer()

            // Chevron
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(NSColor.controlBackgroundColor))
                .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
        )
    }
}

// MARK: - Stat Badge

struct StatBadge: View {
    let icon: String
    let value: String
    let label: String

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.caption2)
            Text(value)
                .font(.caption)
                .fontWeight(.medium)
            if !label.isEmpty {
                Text(label)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .foregroundColor(.secondary)
    }
}

// MARK: - Session Detail View

struct SessionDetailView: View {
    let session: SavedSession
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Header Stats
                    HStack(spacing: 16) {
                        DetailStatCard(
                            title: "Words",
                            value: "\(session.wordCount)",
                            icon: "doc.text",
                            color: .blue
                        )

                        DetailStatCard(
                            title: "Characters",
                            value: "\(session.characterCount)",
                            icon: "textformat.characters",
                            color: .purple
                        )

                        DetailStatCard(
                            title: "WPM",
                            value: String(format: "%.0f", session.averageTypingSpeed),
                            icon: "gauge.medium",
                            color: .green
                        )
                    }

                    // Session Info
                    VStack(alignment: .leading, spacing: 12) {
                        Label("Session Details", systemImage: "info.circle")
                            .font(.headline)
                            .foregroundColor(.primary)

                        Divider()

                        DetailRow(label: "Started", value: formatDateTime(session.startTime))
                        DetailRow(label: "Ended", value: formatDateTime(session.endTime))
                        DetailRow(label: "Duration", value: session.formattedDuration)
                    }
                    .padding(16)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(NSColor.controlBackgroundColor))
                    )

                    // Content
                    VStack(alignment: .leading, spacing: 12) {
                        Label("Content", systemImage: "doc.text")
                            .font(.headline)
                            .foregroundColor(.primary)

                        Divider()

                        ScrollView {
                            Text(session.content.isEmpty ? "No content" : session.content)
                                .font(.body)
                                .foregroundColor(session.content.isEmpty ? .secondary : .primary)
                                .textSelection(.enabled)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .frame(maxHeight: 300)
                    }
                    .padding(16)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(NSColor.textBackgroundColor))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                            )
                    )
                }
                .padding(24)
            }
            .navigationTitle(session.title)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
        .frame(minWidth: 600, minHeight: 500)
    }

    private func formatDateTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

// MARK: - Detail Stat Card

struct DetailStatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)

            VStack(spacing: 4) {
                Text(value)
                    .font(.title)
                    .fontWeight(.bold)

                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(NSColor.controlBackgroundColor))
        )
    }
}

// MARK: - Detail Row

struct DetailRow: View {
    let label: String
    let value: String

    var body: some View {
        HStack {
            Text(label)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .fontWeight(.medium)
        }
        .font(.body)
    }
}

#Preview {
    SessionHistoryView()
}
