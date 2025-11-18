import SwiftUI
import AppKit

// MARK: - Custom NSTextView for Backspace Blocking

class BlockingTextView: NSTextView {
    var isBackspaceBlocked: Bool = false
    var onTextChange: ((String) -> Void)?

    override func keyDown(with event: NSEvent) {
        // Block backspace/delete when enabled
        if isBackspaceBlocked {
            let deleteKey: UInt16 = 51 // Backspace
            let deleteForwardKey: UInt16 = 117 // Delete forward

            if event.keyCode == deleteKey || event.keyCode == deleteForwardKey {
                NSSound.beep()
                return
            }
        }

        super.keyDown(with: event)
    }

    override func didChangeText() {
        super.didChangeText()
        onTextChange?(string)
    }
}

struct BlockingTextEditor: NSViewRepresentable {
    @Binding var text: String
    @Binding var isBackspaceBlocked: Bool
    var isEnabled: Bool

    func makeNSView(context: Context) -> NSScrollView {
        let scrollView = NSTextView.scrollableTextView()
        let textView = scrollView.documentView as! NSTextView

        // Replace with our custom text view
        let blockingTextView = BlockingTextView()
        blockingTextView.isRichText = false
        blockingTextView.font = .systemFont(ofSize: 18)
        blockingTextView.textColor = .labelColor
        blockingTextView.backgroundColor = .textBackgroundColor
        blockingTextView.isAutomaticQuoteSubstitutionEnabled = false
        blockingTextView.isAutomaticDashSubstitutionEnabled = false
        blockingTextView.isAutomaticTextReplacementEnabled = false
        blockingTextView.isAutomaticSpellingCorrectionEnabled = false
        blockingTextView.isContinuousSpellCheckingEnabled = false
        blockingTextView.onTextChange = { newText in
            DispatchQueue.main.async {
                text = newText
            }
        }

        scrollView.documentView = blockingTextView

        return scrollView
    }

    func updateNSView(_ scrollView: NSScrollView, context: Context) {
        guard let textView = scrollView.documentView as? BlockingTextView else { return }

        textView.isBackspaceBlocked = isBackspaceBlocked
        textView.isEditable = isEnabled
        textView.isSelectable = true

        if textView.string != text {
            textView.string = text
        }
    }
}

// MARK: - Simple Writing Session View

struct SimpleWritingSessionView: View {
    @State private var isActive = false
    @State private var timeRemaining: TimeInterval = 15 * 60
    @State private var text: String = ""
    @State private var isBackspaceBlocked = true
    @State private var timer: Timer?
    @State private var showingAnalysis = false
    @State private var analysisResult: AIAnalysisResult?
    @State private var isAnalyzing = false
    @State private var showStats = true
    @State private var startTime: Date?
    @State private var showCompletionAlert = false
    @Environment(\.dismiss) private var dismiss

    private let aiService = AIAnalysisService()
    private let historyManager = SessionHistoryManager()

    var body: some View {
        VStack(spacing: 0) {
            // Header
            headerView

            // Main Content Area
            HStack(spacing: 0) {
                // Writing Area
                VStack(spacing: 16) {
                    // Timer Display
                    timerDisplayView

                    // Writing Editor
                    writingEditorView

                    // Control Buttons
                    controlButtonsView
                }
                .frame(maxWidth: .infinity)

                // Stats Sidebar (collapsible)
                if showStats && isActive {
                    statsSidebarView
                        .transition(.move(edge: .trailing))
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(NSColor.windowBackgroundColor))
        .sheet(isPresented: $showingAnalysis) {
            if let result = analysisResult {
                AnalysisResultView(result: result)
            }
        }
        .alert("Session Complete!", isPresented: $showCompletionAlert) {
            Button("OK") {
                showCompletionAlert = false
            }
        } message: {
            if !text.isEmpty {
                Text("Great work! You wrote \(wordCount) words in this session. AI analysis is ready!")
            } else {
                Text("Session completed.")
            }
        }
    }

    // MARK: - Header View

    private var headerView: some View {
        HStack {
            Button(action: { dismiss() }) {
                HStack(spacing: 6) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title3)
                    Text("Close")
                }
            }
            .buttonStyle(.plain)
            .foregroundColor(.secondary)
            .help("Close writing session")

            Spacer()

            Text("WritingFlow Session")
                .font(.headline)
                .foregroundColor(.primary)

            Spacer()

            Button(action: {
                withAnimation {
                    showStats.toggle()
                }
            }) {
                Image(systemName: showStats ? "sidebar.right" : "sidebar.left")
                    .font(.title3)
            }
            .buttonStyle(.plain)
            .foregroundColor(.secondary)
            .help("Toggle statistics sidebar")
            .opacity(isActive ? 1 : 0)
            .animation(.easeInOut, value: isActive)
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 16)
        .background(Color(NSColor.controlBackgroundColor))
        .overlay(
            Divider(),
            alignment: .bottom
        )
    }

    // MARK: - Timer Display

    private var timerDisplayView: some View {
        VStack(spacing: 12) {
            Text(formattedTime)
                .font(.system(size: 56, weight: .bold, design: .rounded))
                .foregroundColor(timerColor)
                .contentTransition(.numericText())
                .animation(.default, value: timeRemaining)

            HStack(spacing: 8) {
                Circle()
                    .fill(statusColor)
                    .frame(width: 8, height: 8)
                    .opacity(isActive ? 1 : 0.5)

                Text(statusText)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.secondary)
            }

            // Progress Bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 8)

                    RoundedRectangle(cornerRadius: 4)
                        .fill(
                            LinearGradient(
                                colors: [statusColor, statusColor.opacity(0.7)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: geometry.size.width * progress, height: 8)
                        .animation(.linear, value: progress)
                }
            }
            .frame(height: 8)
        }
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(NSColor.controlBackgroundColor))
                .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 4)
        )
        .padding(.horizontal, 24)
        .padding(.top, 16)
    }

    // MARK: - Writing Editor

    private var writingEditorView: some View {
        VStack(spacing: 0) {
            if isBackspaceBlocked && isActive {
                HStack(spacing: 8) {
                    Image(systemName: "lock.fill")
                        .foregroundColor(.orange)
                        .font(.caption)
                    Text("Backspace disabled - keep writing forward!")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)

                    Spacer()

                    Text("Words: \(wordCount)")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.blue)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .frame(maxWidth: .infinity)
                .background(Color.orange.opacity(0.1))
                .overlay(
                    Rectangle()
                        .fill(Color.orange.opacity(0.3))
                        .frame(height: 1),
                    alignment: .bottom
                )
            }

            ZStack(alignment: .topLeading) {
                if text.isEmpty && !isActive {
                    Text("Start your session to begin writing...")
                        .font(.title3)
                        .foregroundColor(.secondary.opacity(0.5))
                        .padding(20)
                }

                BlockingTextEditor(
                    text: $text,
                    isBackspaceBlocked: $isBackspaceBlocked,
                    isEnabled: isActive
                )
                .opacity(isActive || !text.isEmpty ? 1 : 0.5)
            }
        }
        .background(Color(NSColor.textBackgroundColor))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(isActive ? Color.blue.opacity(0.3) : Color.gray.opacity(0.2), lineWidth: 2)
        )
        .padding(.horizontal, 24)
        .padding(.vertical, 16)
    }

    // MARK: - Control Buttons

    private var controlButtonsView: some View {
        HStack(spacing: 12) {
            if isActive {
                Button(action: pauseSession) {
                    HStack(spacing: 8) {
                        Image(systemName: "pause.circle.fill")
                            .font(.title3)
                        Text("Pause")
                            .fontWeight(.semibold)
                    }
                    .frame(minWidth: 100)
                    .padding(.vertical, 12)
                    .padding(.horizontal, 20)
                }
                .buttonStyle(.bordered)
                .tint(.orange)
            } else if !text.isEmpty {
                Button(action: startSession) {
                    HStack(spacing: 8) {
                        Image(systemName: "play.circle.fill")
                            .font(.title3)
                        Text("Resume")
                            .fontWeight(.semibold)
                    }
                    .frame(minWidth: 100)
                    .padding(.vertical, 12)
                    .padding(.horizontal, 20)
                }
                .buttonStyle(.borderedProminent)
            } else {
                Button(action: startSession) {
                    HStack(spacing: 8) {
                        Image(systemName: "play.circle.fill")
                            .font(.title3)
                        Text("Start Session")
                            .fontWeight(.semibold)
                    }
                    .frame(minWidth: 120)
                    .padding(.vertical, 12)
                    .padding(.horizontal, 20)
                }
                .buttonStyle(.borderedProminent)
            }

            Button(action: completeSession) {
                HStack(spacing: 8) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.title3)
                    Text("Complete")
                        .fontWeight(.semibold)
                }
                .frame(minWidth: 100)
                .padding(.vertical, 12)
                .padding(.horizontal, 20)
            }
            .buttonStyle(.borderedProminent)
            .tint(.green)
            .disabled(!isActive && text.isEmpty)

            if !text.isEmpty {
                Button(action: { Task { await analyzeText() } }) {
                    HStack(spacing: 8) {
                        if isAnalyzing {
                            ProgressView()
                                .scaleEffect(0.8)
                                .frame(width: 16, height: 16)
                        } else {
                            Image(systemName: "sparkles")
                                .font(.title3)
                        }
                        Text("AI Analysis")
                            .fontWeight(.semibold)
                    }
                    .frame(minWidth: 120)
                    .padding(.vertical, 12)
                    .padding(.horizontal, 20)
                }
                .buttonStyle(.bordered)
                .disabled(isAnalyzing)
            }
        }
        .padding(.horizontal, 24)
        .padding(.bottom, 20)
    }

    // MARK: - Stats Sidebar

    private var statsSidebarView: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Live Statistics")
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(.primary)

            Divider()

            StatRow(
                icon: "doc.text",
                label: "Words",
                value: "\(wordCount)",
                color: .blue
            )

            StatRow(
                icon: "textformat.characters",
                label: "Characters",
                value: "\(characterCount)",
                color: .purple
            )

            StatRow(
                icon: "gauge.medium",
                label: "WPM",
                value: String(format: "%.0f", wordsPerMinute),
                color: .green
            )

            if let elapsed = elapsedTime {
                StatRow(
                    icon: "clock",
                    label: "Elapsed",
                    value: formatElapsedTime(elapsed),
                    color: .orange
                )
            }

            Spacer()

            // Mini motivation
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Image(systemName: "sparkles")
                        .foregroundColor(.yellow)
                        .font(.caption)
                    Text("Keep going!")
                        .font(.caption)
                        .fontWeight(.medium)
                }

                if wordCount > 0 {
                    Text(motivationalMessage)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                        .lineLimit(3)
                }
            }
            .padding(12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.yellow.opacity(0.1))
            )
        }
        .padding(20)
        .frame(width: 220)
        .background(Color(NSColor.controlBackgroundColor))
        .overlay(
            Divider(),
            alignment: .leading
        )
    }

    // MARK: - Computed Properties

    private var formattedTime: String {
        let minutes = Int(max(0, timeRemaining)) / 60
        let seconds = Int(max(0, timeRemaining)) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }

    private var statusText: String {
        if timeRemaining <= 0 {
            return "Time's Up!"
        } else if isActive {
            return "Writing in Progress"
        } else if !text.isEmpty {
            return "Paused"
        } else {
            return "Ready to Start"
        }
    }

    private var statusColor: Color {
        if timeRemaining <= 0 {
            return .red
        } else if isActive {
            return .green
        } else if !text.isEmpty {
            return .orange
        } else {
            return .gray
        }
    }

    private var timerColor: Color {
        if timeRemaining <= 60 {
            return .red
        } else if timeRemaining <= 300 {
            return .orange
        } else {
            return .primary
        }
    }

    private var progress: Double {
        let totalTime = 15.0 * 60.0
        return max(0, min(1, 1.0 - (timeRemaining / totalTime)))
    }

    private var wordCount: Int {
        text.components(separatedBy: .whitespacesAndNewlines)
            .filter { !$0.isEmpty }
            .count
    }

    private var characterCount: Int {
        text.count
    }

    private var wordsPerMinute: Double {
        guard let start = startTime else { return 0 }
        let elapsed = Date().timeIntervalSince(start) / 60.0
        return elapsed > 0 ? Double(wordCount) / elapsed : 0
    }

    private var elapsedTime: TimeInterval? {
        guard let start = startTime else { return nil }
        return Date().timeIntervalSince(start)
    }

    private var motivationalMessage: String {
        switch wordCount {
        case 0..<50:
            return "Great start! Keep the momentum going."
        case 50..<100:
            return "You're doing amazing! Half way there."
        case 100..<200:
            return "Excellent progress! Your ideas are flowing."
        case 200..<500:
            return "Outstanding work! You're on fire!"
        default:
            return "Incredible! You're a writing machine!"
        }
    }

    // MARK: - Actions

    private func startSession() {
        withAnimation(.spring(response: 0.3)) {
            isActive = true
            if startTime == nil {
                startTime = Date()
                timeRemaining = 15 * 60
            }
            isBackspaceBlocked = true
        }

        // Create timer on main thread
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            Task { @MainActor in
                if self.timeRemaining > 0 {
                    self.timeRemaining -= 1
                } else {
                    self.completeSession()
                }
            }
        }

        // Ensure timer runs even when scrolling
        RunLoop.main.add(timer!, forMode: .common)
    }

    private func pauseSession() {
        withAnimation(.spring(response: 0.3)) {
            isActive = false
            timer?.invalidate()
            timer = nil
            isBackspaceBlocked = false
        }
    }

    private func completeSession() {
        withAnimation(.spring(response: 0.3)) {
            isActive = false
            isBackspaceBlocked = false
            timer?.invalidate()
            timer = nil
        }

        // Save session to history
        if !text.isEmpty, let start = startTime {
            let sessionTitle = "Session \(formatSessionDate(start))"
            let duration = Date().timeIntervalSince(start)

            historyManager.saveSession(
                title: sessionTitle,
                content: text,
                startTime: start,
                endTime: Date(),
                wordCount: wordCount,
                characterCount: characterCount,
                duration: duration,
                analysisResult: analysisResult
            )
        }

        // Show completion alert
        showCompletionAlert = true

        // Auto-analyze if there's text
        if !text.isEmpty {
            Task {
                // Small delay to show the alert first
                try? await Task.sleep(nanoseconds: 500_000_000)
                await analyzeText()
            }
        }
    }

    private func formatSessionDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }

    private func stopSession() {
        withAnimation(.spring(response: 0.3)) {
            isActive = false
            isBackspaceBlocked = false
            timer?.invalidate()
            timer = nil
            text = ""
            timeRemaining = 15 * 60
            startTime = nil
        }
    }

    private func analyzeText() async {
        guard !text.isEmpty else { return }

        isAnalyzing = true

        do {
            analysisResult = try await aiService.analyzeText(text)
            showingAnalysis = true
        } catch {
            print("Analysis failed: \(error)")
            // Could show error alert here
        }

        isAnalyzing = false
    }
}

// MARK: - Stat Row Component

struct StatRow: View {
    let icon: String
    let label: String
    let value: String
    let color: Color

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(color)
                .font(.title3)
                .frame(width: 24)

            VStack(alignment: .leading, spacing: 2) {
                Text(label)
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text(value)
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
            }

            Spacer()
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Format Helper

private func formatElapsedTime(_ time: TimeInterval) -> String {
    let minutes = Int(time) / 60
    let seconds = Int(time) % 60
    if minutes > 0 {
        return "\(minutes)m \(seconds)s"
    } else {
        return "\(seconds)s"
    }
}

// MARK: - Analysis Result View

struct AnalysisResultView: View {
    let result: AIAnalysisResult
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Header Stats
                    HStack(spacing: 20) {
                        StatCard(
                            title: "Words",
                            value: "\(result.wordCount)",
                            icon: "doc.text",
                            color: .blue
                        )

                        StatCard(
                            title: "Readability",
                            value: String(format: "%.0f%%", result.readabilityScore),
                            icon: "chart.bar",
                            color: .green
                        )

                        StatCard(
                            title: "Avg Sentence",
                            value: String(format: "%.1f", result.averageSentenceLength),
                            icon: "text.alignleft",
                            color: .purple
                        )
                    }

                    Divider()

                    // Mood Section
                    AnalysisSection(title: "Writing Mood", icon: "face.smiling", color: .orange) {
                        HStack(spacing: 12) {
                            Image(systemName: "circle.fill")
                                .foregroundColor(.orange)
                                .font(.title2)

                            Text(result.mood.rawValue.capitalized)
                                .font(.title2)
                                .fontWeight(.semibold)
                        }
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.orange.opacity(0.1))
                        )
                    }

                    // Themes Section
                    if !result.themes.isEmpty {
                        AnalysisSection(title: "Themes", icon: "tag", color: .blue) {
                            FlowLayout(spacing: 8) {
                                ForEach(result.themes, id: \.self) { theme in
                                    Text(theme.capitalized)
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 6)
                                        .background(
                                            Capsule()
                                                .fill(Color.blue.opacity(0.1))
                                        )
                                        .foregroundColor(.blue)
                                }
                            }
                        }
                    }

                    // Insights Section
                    if !result.insights.isEmpty {
                        AnalysisSection(title: "Insights", icon: "lightbulb", color: .yellow) {
                            VStack(alignment: .leading, spacing: 12) {
                                ForEach(result.insights, id: \.title) { insight in
                                    InsightCard(insight: insight)
                                }
                            }
                        }
                    }

                    // Style Section
                    if !result.style.isEmpty {
                        AnalysisSection(title: "Writing Style", icon: "paintbrush", color: .purple) {
                            VStack(alignment: .leading, spacing: 8) {
                                ForEach(result.style, id: \.self) { style in
                                    HStack(spacing: 8) {
                                        Image(systemName: "checkmark.circle.fill")
                                            .foregroundColor(.purple)
                                            .font(.caption)
                                        Text(style)
                                            .font(.body)
                                    }
                                }
                            }
                        }
                    }

                    // Suggestions Section
                    if !result.suggestions.isEmpty {
                        AnalysisSection(title: "Suggestions", icon: "sparkles", color: .green) {
                            VStack(alignment: .leading, spacing: 12) {
                                ForEach(result.suggestions, id: \.self) { suggestion in
                                    HStack(alignment: .top, spacing: 12) {
                                        Image(systemName: "arrow.right.circle.fill")
                                            .foregroundColor(.green)
                                            .font(.body)
                                        Text(suggestion)
                                            .font(.body)
                                            .foregroundColor(.primary)
                                    }
                                    .padding(12)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .background(
                                        RoundedRectangle(cornerRadius: 8)
                                            .fill(Color.green.opacity(0.05))
                                    )
                                }
                            }
                        }
                    }
                }
                .padding(24)
            }
            .navigationTitle("AI Analysis")
            .navigationBarTitleDisplayMode(.inline)
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
}

// MARK: - Analysis Components

struct StatCard: View {
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
                    .foregroundColor(.primary)

                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(NSColor.controlBackgroundColor))
                .shadow(color: Color.black.opacity(0.05), radius: 8)
        )
    }
}

struct AnalysisSection<Content: View>: View {
    let title: String
    let icon: String
    let color: Color
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .foregroundColor(color)
                    .font(.title3)

                Text(title)
                    .font(.title3)
                    .fontWeight(.bold)
            }

            content
        }
    }
}

struct InsightCard: View {
    let insight: WritingInsight

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: iconForType(insight.type))
                    .foregroundColor(colorForType(insight.type))

                Text(insight.title)
                    .font(.headline)
                    .fontWeight(.semibold)

                Spacer()

                Text(String(format: "%.0f%%", insight.confidence * 100))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Text(insight.description)
                .font(.body)
                .foregroundColor(.secondary)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(NSColor.controlBackgroundColor))
        )
    }

    private func iconForType(_ type: InsightType) -> String {
        switch type {
        case .productivity: return "chart.line.uptrend.xyaxis"
        case .style: return "paintbrush"
        case .mood: return "face.smiling"
        case .structure: return "list.bullet.rectangle"
        case .vocabulary: return "text.book.closed"
        case .flow: return "waveform"
        case .consistency: return "checkmark.seal"
        }
    }

    private func colorForType(_ type: InsightType) -> Color {
        switch type {
        case .productivity: return .green
        case .style: return .purple
        case .mood: return .orange
        case .structure: return .blue
        case .vocabulary: return .indigo
        case .flow: return .teal
        case .consistency: return .mint
        }
    }
}

// MARK: - Flow Layout (for tags)

struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = FlowResult(
            in: proposal.replacingUnspecifiedDimensions().width,
            subviews: subviews,
            spacing: spacing
        )
        return result.size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = FlowResult(
            in: bounds.width,
            subviews: subviews,
            spacing: spacing
        )
        for (index, subview) in subviews.enumerated() {
            subview.place(at: CGPoint(x: bounds.minX + result.frames[index].minX, y: bounds.minY + result.frames[index].minY), proposal: .unspecified)
        }
    }

    struct FlowResult {
        var frames: [CGRect] = []
        var size: CGSize = .zero

        init(in maxWidth: CGFloat, subviews: Subviews, spacing: CGFloat) {
            var currentX: CGFloat = 0
            var currentY: CGFloat = 0
            var lineHeight: CGFloat = 0

            for subview in subviews {
                let size = subview.sizeThatFits(.unspecified)

                if currentX + size.width > maxWidth && currentX > 0 {
                    currentX = 0
                    currentY += lineHeight + spacing
                    lineHeight = 0
                }

                frames.append(CGRect(x: currentX, y: currentY, width: size.width, height: size.height))
                lineHeight = max(lineHeight, size.height)
                currentX += size.width + spacing
            }

            self.size = CGSize(width: maxWidth, height: currentY + lineHeight)
        }
    }
}

#Preview {
    SimpleWritingSessionView()
        .frame(width: 1000, height: 700)
}
