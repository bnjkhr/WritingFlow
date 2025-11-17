import SwiftUI

struct TimerDisplay: View {
    let remainingTime: TimeInterval
    let isRunning: Bool
    let isPaused: Bool
    let isExpired: Bool
    
    var body: some View {
        VStack(spacing: 8) {
            Text(formattedTime)
                .font(.system(size: 48, weight: .bold, design: .monospaced))
                .foregroundColor(foregroundColor)
            
            Text(statusText)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(backgroundColor)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(borderColor, lineWidth: 2)
                )
        )
    }
    
    private var formattedTime: String {
        let minutes = Int(max(0, remainingTime)) / 60
        let seconds = Int(max(0, remainingTime)) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    private var statusText: String {
        if isExpired {
            return "Time's up!"
        } else if isPaused {
            return "Paused"
        } else if isRunning {
            return "Writing..."
        } else {
            return "Ready"
        }
    }
    
    private var foregroundColor: Color {
        if isExpired {
            return .red
        } else if isPaused {
            return .orange
        } else if isRunning {
            return .primary
        } else {
            return .secondary
        }
    }
    
    private var backgroundColor: Color {
        if isExpired {
            return .red.opacity(0.1)
        } else if isPaused {
            return .orange.opacity(0.1)
        } else if isRunning {
            return .green.opacity(0.1)
        } else {
            return .gray.opacity(0.1)
        }
    }
    
    private var borderColor: Color {
        if isExpired {
            return .red
        } else if isPaused {
            return .orange
        } else if isRunning {
            return .green
        } else {
            return .gray
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        TimerDisplay(
            remainingTime: 15 * 60,
            isRunning: false,
            isPaused: false,
            isExpired: false
        )
        
        TimerDisplay(
            remainingTime: 10 * 60,
            isRunning: true,
            isPaused: false,
            isExpired: false
        )
        
        TimerDisplay(
            remainingTime: 5 * 60,
            isRunning: false,
            isPaused: true,
            isExpired: false
        )
        
        TimerDisplay(
            remainingTime: 0,
            isRunning: false,
            isPaused: false,
            isExpired: true
        )
    }
    .padding()
}