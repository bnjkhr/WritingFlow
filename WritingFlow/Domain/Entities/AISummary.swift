import Foundation

// MARK: - Display Helpers for Domain Entities

extension InsightType {
    var displayName: String {
        switch self {
        case .productivity:
            return "Productivity"
        case .style:
            return "Style"
        case .mood:
            return "Mood"
        case .structure:
            return "Structure"
        case .vocabulary:
            return "Vocabulary"
        case .flow:
            return "Writing Flow"
        case .consistency:
            return "Consistency"
        }
    }
    
    var icon: String {
        switch self {
        case .productivity:
            return "chart.line.uptrend.xyaxis"
        case .style:
            return "text.book.closed"
        case .mood:
            return "face.smiling"
        case .structure:
            return "list.bullet.rectangle"
        case .vocabulary:
            return "textformat"
        case .flow:
            return "waveform.path"
        case .consistency:
            return "calendar.badge.clock"
        }
    }
}

extension WritingMood {
    var displayName: String {
        switch self {
        case .enthusiastic:
            return "Enthusiastic"
        case .focused:
            return "Focused"
        case .reflective:
            return "Reflective"
        case .creative:
            return "Creative"
        case .analytical:
            return "Analytical"
        case .neutral:
            return "Neutral"
        case .tired:
            return "Tired"
        case .stressed:
            return "Stressed"
        }
    }
    
    var color: String {
        switch self {
        case .enthusiastic:
            return "orange"
        case .focused:
            return "blue"
        case .reflective:
            return "purple"
        case .creative:
            return "pink"
        case .analytical:
            return "green"
        case .neutral:
            return "gray"
        case .tired:
            return "indigo"
        case .stressed:
            return "red"
        }
    }
    
    var icon: String {
        switch self {
        case .enthusiastic:
            return "face.dashed"
        case .focused:
            return "eye.circle"
        case .reflective:
            return "moon.circle"
        case .creative:
            return "paintbrush.pointed"
        case .analytical:
            return "magnifyingglass.circle"
        case .neutral:
            return "circle"
        case .tired:
            return "bed.double.circle"
        case .stressed:
            return "exclamationmark.triangle"
        }
    }
}

extension ActivityType {
    var displayName: String {
        switch self {
        case .typing:
            return "Typing"
        case .pause:
            return "Pause"
        case .backspace:
            return "Backspace"
        case .idle:
            return "Idle"
        case .focus:
            return "Focus"
        case .distraction:
            return "Distraction"
        }
    }
}
