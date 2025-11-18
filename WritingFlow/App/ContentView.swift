import SwiftUI

struct ContentView: View {
    @State private var showingWritingSession = false
    @State private var showingHistory = false
    @State private var isHovering = false

    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                colors: [
                    Color.blue.opacity(0.05),
                    Color.purple.opacity(0.05),
                    Color.pink.opacity(0.05)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {
                // Top Bar with History Button
                HStack {
                    Spacer()

                    Button(action: {
                        showingHistory = true
                    }) {
                        HStack(spacing: 8) {
                            Image(systemName: "clock.arrow.circlepath")
                                .font(.title3)
                            Text("History")
                                .fontWeight(.medium)
                        }
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(
                            Capsule()
                                .fill(Color(NSColor.controlBackgroundColor))
                                .opacity(0.8)
                        )
                        .overlay(
                            Capsule()
                                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                        )
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal, 30)
                .padding(.top, 20)

                Spacer()

                // App Icon and Branding
                VStack(spacing: 20) {
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [Color.blue, Color.purple],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 120, height: 120)
                            .shadow(color: Color.blue.opacity(0.3), radius: 20, x: 0, y: 10)

                        Image(systemName: "pencil.and.outline")
                            .font(.system(size: 50))
                            .foregroundStyle(.white)
                            .fontWeight(.medium)
                    }
                    .scaleEffect(isHovering ? 1.05 : 1.0)
                    .animation(.spring(response: 0.3), value: isHovering)

                    VStack(spacing: 8) {
                        Text("WritingFlow")
                            .font(.system(size: 48, weight: .bold, design: .rounded))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [Color.blue, Color.purple],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )

                        Text("Focused writing with AI insights")
                            .font(.title3)
                            .fontWeight(.medium)
                            .foregroundColor(.secondary)
                    }
                }

                // Main Action Button
                Button(action: {
                    showingWritingSession = true
                }) {
                    HStack(spacing: 12) {
                        Image(systemName: "play.circle.fill")
                            .font(.title2)

                        Text("Start Writing Session")
                            .font(.title3)
                            .fontWeight(.semibold)
                    }
                    .foregroundColor(.white)
                    .frame(width: 280)
                    .padding(.vertical, 18)
                    .background(
                        LinearGradient(
                            colors: [Color.blue, Color.purple],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                    .shadow(color: Color.blue.opacity(0.4), radius: 15, x: 0, y: 8)
                }
                .buttonStyle(.plain)
                .scaleEffect(isHovering ? 1.05 : 1.0)
                .onHover { hovering in
                    withAnimation(.spring(response: 0.3)) {
                        isHovering = hovering
                    }
                }

                // Feature Pills
                HStack(spacing: 16) {
                    FeaturePill(icon: "timer", text: "15 Min Sessions")
                    FeaturePill(icon: "brain.head.profile", text: "AI Analysis")
                    FeaturePill(icon: "nosign", text: "No Backspace")
                }
                .padding(.top, 10)

                Spacer()

                // Footer
                HStack(spacing: 8) {
                    Image(systemName: "sparkles")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("Powered by Apple Foundation Models")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.bottom, 20)

                Spacer()
            }
            .padding(.horizontal, 40)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .sheet(isPresented: $showingWritingSession) {
            SimpleWritingSessionView()
                .frame(minWidth: 900, minHeight: 650)
        }
        .sheet(isPresented: $showingHistory) {
            SessionHistoryView()
        }
    }
}

// MARK: - Feature Pill

struct FeaturePill: View {
    let icon: String
    let text: String

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.caption)
            Text(text)
                .font(.caption)
                .fontWeight(.medium)
        }
        .foregroundColor(.secondary)
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(
            Capsule()
                .fill(Color(NSColor.controlBackgroundColor))
                .opacity(0.8)
        )
        .overlay(
            Capsule()
                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
        )
    }
}

#Preview {
    ContentView()
        .frame(width: 800, height: 600)
}