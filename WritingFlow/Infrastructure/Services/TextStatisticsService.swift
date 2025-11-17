import Foundation

@MainActor
final class TextStatisticsService {
    
    func calculateWordCount(from text: String) -> Int {
        let words = text.components(separatedBy: .whitespacesAndNewlines)
        return words.filter { !$0.isEmpty }.count
    }
    
    func calculateCharacterCount(from text: String) -> Int {
        return text.count
    }
    
    func calculateTypingSpeed(characters: Int, timeInterval: TimeInterval) -> Double {
        guard timeInterval > 0 else { return 0 }
        return (Double(characters) / timeInterval) * 60.0 // characters per minute
    }
    
    func calculateReadabilityScore(from text: String) -> Double {
        // Simple readability score based on sentence length and word complexity
        let sentences = text.components(separatedBy: CharacterSet(charactersIn: ".!?"))
            .filter { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
        
        guard !sentences.isEmpty else { return 0 }
        
        let words = calculateWordCount(from: text)
        let averageSentenceLength = Double(words) / Double(sentences.count)
        
        // Simple scoring: ideal sentence length is 15-20 words
        let idealLength = 17.5
        let deviation = abs(averageSentenceLength - idealLength)
        let score = max(0, 100 - (deviation * 2))
        
        return min(100, score)
    }
    
    func extractThemes(from text: String) -> [String] {
        // Simple theme extraction based on common writing themes
        let commonThemes = [
            "creativity", "productivity", "mindfulness", "reflection",
            "planning", "goals", "ideas", "inspiration", "motivation",
            "focus", "routine", "habits", "growth", "learning"
        ]
        
        let lowercaseText = text.lowercased()
        var foundThemes: [String] = []
        
        for theme in commonThemes {
            if lowercaseText.contains(theme) {
                foundThemes.append(theme)
            }
        }
        
        return foundThemes
    }
    
    func analyzeMood(from text: String) -> String {
        // Simple mood analysis based on keywords
        let moodKeywords: [String: String] = [
            "excited": "enthusiastic",
            "focused": "focused", 
            "thinking": "reflective",
            "creative": "creative",
            "analyzing": "analytical",
            "calm": "neutral",
            "tired": "tired",
            "stressed": "stressed"
        ]
        
        let lowercaseText = text.lowercased()
        
        for (keyword, mood) in moodKeywords {
            if lowercaseText.contains(keyword) {
                return mood
            }
        }
        
        return "neutral"
    }
}