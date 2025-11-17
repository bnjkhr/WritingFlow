import Foundation
import Combine

@MainActor
final class ActivityDetector: ObservableObject {
    @Published private(set) var isDetecting: Bool = false
    @Published private(set) var lastActivityTime: Date = Date()
    
    private var currentSessionId: UUID?
    private var inactivityTimer: Timer?
    private var typingTimer: Timer?
    
    func startActivityDetection(for sessionId: UUID) {
        currentSessionId = sessionId
        isDetecting = true
        lastActivityTime = Date()
        
        startInactivityMonitoring()
    }
    
    func stopActivityDetection() {
        currentSessionId = nil
        isDetecting = false
        
        inactivityTimer?.invalidate()
        inactivityTimer = nil
        
        typingTimer?.invalidate()
        typingTimer = nil
    }
    
    func logTypingActivity() {
        guard isDetecting else { return }
        
        lastActivityTime = Date()
        
        // Reset inactivity timer
        inactivityTimer?.invalidate()
        startInactivityMonitoring()
        
        // Log typing event (would be saved to repository)
        print("Typing activity detected for session: \(currentSessionId?.uuidString ?? "unknown")")
    }
    
    func logBackspaceAttempt() {
        guard isDetecting else { return }
        
        // Log backspace attempt (would be saved to repository)
        print("Backspace attempt detected for session: \(currentSessionId?.uuidString ?? "unknown")")
    }
    
    private func startInactivityMonitoring() {
        inactivityTimer = Timer.scheduledTimer(withTimeInterval: 30.0, repeats: false) { [weak self] _ in
            Task { @MainActor in
                self?.handleInactivity()
            }
        }
    }
    
    private func handleInactivity() {
        guard isDetecting else { return }
        
        let now = Date()
        let timeSinceLastActivity = now.timeIntervalSince(lastActivityTime)
        
        if timeSinceLastActivity >= 30.0 {
            // User has been inactive for 30 seconds
            print("User inactivity detected for session: \(currentSessionId?.uuidString ?? "unknown")")
            
            // Could pause timer or notify session manager
        }
    }
}