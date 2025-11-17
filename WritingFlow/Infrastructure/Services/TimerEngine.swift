import Foundation
import Combine

@MainActor
final class TimerEngine: ObservableObject {
    @Published private(set) var remainingTime: TimeInterval = 15 * 60
    @Published private(set) var isRunning: Bool = false
    @Published private(set) var isPaused: Bool = false
    @Published private(set) var isExpired: Bool = false
    
    private var timer: Timer?
    private var lastUpdateTime: Date = Date()
    
    func start(duration: TimeInterval) {
        stop()
        
        remainingTime = duration
        isRunning = true
        isPaused = false
        isExpired = false
        
        lastUpdateTime = Date()
        
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.updateTimer()
            }
        }
    }
    
    func pause() {
        guard isRunning else { return }
        
        timer?.invalidate()
        timer = nil
        
        isRunning = false
        isPaused = true
    }
    
    func resume() {
        guard isPaused else { return }
        
        isRunning = true
        isPaused = false
        
        lastUpdateTime = Date()
        
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.updateTimer()
            }
        }
    }
    
    func stop() {
        timer?.invalidate()
        timer = nil
        
        remainingTime = 15 * 60
        isRunning = false
        isPaused = false
        isExpired = false
    }
    
    func reset() {
        stop()
    }
    
    private func updateTimer() {
        guard isRunning else { return }
        
        let now = Date()
        let elapsed = now.timeIntervalSince(lastUpdateTime)
        lastUpdateTime = now
        
        let newRemainingTime = max(0, remainingTime - elapsed)
        
        if newRemainingTime <= 0 {
            // Timer expired
            timer?.invalidate()
            timer = nil
            
            remainingTime = 0
            isRunning = false
            isPaused = false
            isExpired = true
        } else {
            remainingTime = newRemainingTime
        }
    }
}