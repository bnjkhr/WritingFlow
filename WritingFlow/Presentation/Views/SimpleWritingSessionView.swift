import SwiftUI

struct SimpleWritingSessionView: View {
    @State private var isActive = false
    @State private var timeRemaining: TimeInterval = 15 * 60
    @State private var text: String = ""
    @State private var isBackspaceBlocked = true
    @State private var timer: Timer?
    @State private var showingAnalysis = false
    @State private var analysisResult: AIAnalysisResult?
    
    private let aiService = AIAnalysisService()
    
    var body: some View {
        VStack(spacing: 20) {
            // Header
            HStack {
                Button("Close") {
                    stopSession()
                }
                .buttonStyle(.bordered)
                
                Spacer()
                
                Text("Writing Session")
                    .font(.headline)
            }
            .padding(.horizontal)
            
            // Timer Display
            VStack(spacing: 8) {
                Text(formattedTime)
                    .font(.system(size: 48, weight: .bold, design: .monospaced))
                    .foregroundColor(isActive ? .primary : .secondary)
                
                Text(isActive ? "Writing..." : "Ready")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isActive ? Color.green.opacity(0.1) : Color.gray.opacity(0.1))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(isActive ? Color.green : Color.gray, lineWidth: 2)
                    )
            )
            
            // Writing Editor
            VStack(spacing: 0) {
                if isBackspaceBlocked && isActive {
                    HStack {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundColor(.orange)
                        Text("Backspace is disabled - keep writing forward!")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                    .background(Color.orange.opacity(0.1))
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.orange.opacity(0.3), lineWidth: 1)
                    )
                }
                
                TextEditor(text: $text)
                    .font(.system(size: 18, design: .default))
                    .lineSpacing(4)
                    .padding()
                    .background(Color(NSColor.textBackgroundColor))
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                    )
                    .disabled(!isActive)
            }
            .frame(maxHeight: .infinity)
            
            // Control Buttons
            HStack(spacing: 16) {
                if isActive {
                    Button("Pause") {
                        pauseSession()
                    }
                    .buttonStyle(.bordered)
                } else {
                    Button("Start") {
                        startSession()
                    }
                    .buttonStyle(.borderedProminent)
                }
                
                Button("Complete") {
                    completeSession()
                }
                .buttonStyle(.borderedProminent)
                .disabled(!isActive && text.isEmpty)
                
                if !text.isEmpty {
                    Button("Analyze") {
                        Task {
                            await analyzeText()
                        }
                    }
                    .buttonStyle(.bordered)
                }
            }
            .padding()
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(NSColor.windowBackgroundColor))
        .sheet(isPresented: $showingAnalysis) {
            if let result = analysisResult {
                AnalysisResultView(result: result)
            }
        }
    }
    
    private var formattedTime: String {
        let minutes = Int(max(0, timeRemaining)) / 60
        let seconds = Int(max(0, timeRemaining)) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    private func startSession() {
        isActive = true
        timeRemaining = 15 * 60
        isBackspaceBlocked = true
        
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            if timeRemaining > 0 {
                timeRemaining -= 1
            } else {
                completeSession()
            }
        }
    }
    
    private func pauseSession() {
        isActive = false
        timer?.invalidate()
        timer = nil
    }
    
    private func completeSession() {
        isActive = false
        isBackspaceBlocked = false
        timer?.invalidate()
        timer = nil
        
        print("Session completed with \(text.count) characters")
    }
    
    private func stopSession() {
        isActive = false
        isBackspaceBlocked = false
        timer?.invalidate()
        timer = nil
        text = ""
        timeRemaining = 15 * 60
    }
    
    private func analyzeText() async {
        do {
            analysisResult = try await aiService.analyzeText(text)
            showingAnalysis = true
        } catch {
            print("Analysis failed: \(error)")
        }
    }
}

struct AnalysisResultView: View {
    let result: AIAnalysisResult
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Mood Section
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Writing Mood")
                            .font(.headline)
                        Text(result.mood.rawValue.capitalized)
                            .font(.title2)
                            .foregroundColor(.blue)
                    }
                    
                    // Stats Section
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Statistics")
                            .font(.headline)
                        
                        HStack {
                            Text("Word Count:")
                            Spacer()
                            Text("\(result.wordCount)")
                                .fontWeight(.semibold)
                        }
                        
                        HStack {
                            Text("Readability Score:")
                            Spacer()
                            Text(String(format: "%.1f", result.readabilityScore))
                                .fontWeight(.semibold)
                        }
                    }
                    
                    // Themes Section
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Themes")
                            .font(.headline)
                        
                        ForEach(result.themes, id: \.self) { theme in
                            Text("• \(theme.capitalized)")
                                .font(.body)
                        }
                    }
                    
                    // Insights Section
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Insights")
                            .font(.headline)
                        
                        ForEach(result.insights, id: \.self) { insight in
                            Text("• \(insight)")
                                .font(.body)
                        }
                    }
                    
                    // Style Section
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Writing Style")
                            .font(.headline)
                        
                        ForEach(result.style, id: \.self) { style in
                            Text("• \(style)")
                                .font(.body)
                        }
                    }
                    
                    // Suggestions Section
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Suggestions")
                            .font(.headline)
                        
                        ForEach(result.suggestions, id: \.self) { suggestion in
                            Text("• \(suggestion)")
                                .font(.body)
                                .foregroundColor(.blue)
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("AI Analysis")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    SimpleWritingSessionView()
        .frame(width: 800, height: 600)
}