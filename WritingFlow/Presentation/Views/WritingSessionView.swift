import SwiftUI

struct WritingSessionView: View {
    @StateObject private var viewModel: WritingSessionViewModel
    @Environment(\.dismiss) private var dismiss
    
    init(viewModel: WritingSessionViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        VStack(spacing: 20) {
            // Header
            HStack {
                Button("Close") {
                    dismiss()
                }
                .buttonStyle(.bordered)
                
                Spacer()
                
                if let session = viewModel.currentSession {
                    Text(session.title)
                        .font(.headline)
                }
            }
            .padding(.horizontal)
            
            // Timer Display
            TimerDisplay(
                remainingTime: viewModel.remainingTime,
                isRunning: viewModel.isTimerRunning,
                isPaused: viewModel.isTimerPaused,
                isExpired: viewModel.isTimerExpired
            )
            
            // Writing Editor
            WritingEditor(
                text: Binding(
                    get: { viewModel.text },
                    set: { viewModel.text = $0 }
                ),
                isBackspaceBlocked: Binding(
                    get: { viewModel.isBackspaceBlocked },
                    set: { _ in }
                ),
                onTextChange: { newText in
                    Task {
                        await viewModel.updateText(newText)
                    }
                }
            )
            .frame(maxHeight: .infinity)
            
            // Control Buttons
            HStack(spacing: 16) {
                if viewModel.isTimerRunning {
                    Button("Pause") {
                        Task {
                            await viewModel.pauseSession()
                        }
                    }
                    .buttonStyle(.bordered)
                } else if viewModel.isTimerPaused {
                    Button("Resume") {
                        Task {
                            await viewModel.resumeSession()
                        }
                    }
                    .buttonStyle(.borderedProminent)
                }
                
                Button("Complete") {
                    Task {
                        await viewModel.completeSession()
                    }
                }
                .buttonStyle(.borderedProminent)
                .disabled(viewModel.currentSession == nil)
            }
            .padding()
            
            // Loading Indicator
            if viewModel.isLoading {
                ProgressView()
                    .scaleEffect(1.2)
            }
            
            // Error Message
            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .padding()
                    .background(Color.red.opacity(0.1))
                    .cornerRadius(8)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(NSColor.windowBackgroundColor))
    }
}

#Preview {
    // Mock dependencies would go here
    Text("Writing Session View Preview")
}