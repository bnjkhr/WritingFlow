import Foundation

@MainActor
final class AIAnalysisService {
    func analyzeText(_ text: String) async throws -> AIAnalysisResult {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            throw AIAnalysisError.textTooShort
        }
        
        let wordCount = calculateWordCount(trimmed)
        let averageSentenceLength = calculateAverageSentenceLength(trimmed)
        let readabilityScore = calculateReadabilityScore(averageSentenceLength: averageSentenceLength)
        let mood = analyzeMood(trimmed)
        let themes = extractThemes(trimmed)
        let style = analyzeStyle(trimmed, averageSentenceLength: averageSentenceLength)
        let suggestions = generateSuggestions(mood: mood, wordCount: wordCount)
        let insights = buildInsights(wordCount: wordCount, themes: themes, style: style)
        
        return AIAnalysisResult(
            mood: mood,
            themes: themes,
            insights: insights,
            style: style,
            suggestions: suggestions,
            wordCount: wordCount,
            readabilityScore: readabilityScore,
            averageSentenceLength: averageSentenceLength
        )
    }
    
    // MARK: - Basic Statistics
    
    private func calculateWordCount(_ text: String) -> Int {
        let separators = CharacterSet.whitespacesAndNewlines.union(.punctuationCharacters)
        let components = text.components(separatedBy: separators)
        return components.filter { !$0.isEmpty }.count
    }
    
    private func calculateAverageSentenceLength(_ text: String) -> Double {
        let sentences = text.components(separatedBy: CharacterSet(charactersIn: ".!?"))
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
        guard !sentences.isEmpty else { return 0 }
        let totalWords = sentences.reduce(0) { partial, sentence in
            partial + calculateWordCount(sentence)
        }
        return Double(totalWords) / Double(sentences.count)
    }
    
    private func analyzeMood(_ text: String) -> WritingMood {
        let lowercased = text.lowercased()
        if lowercased.contains("excited") || lowercased.contains("amazing") {
            return .enthusiastic
        } else if lowercased.contains("focus") || lowercased.contains("concentrate") {
            return .focused
        } else if lowercased.contains("think") || lowercased.contains("reflect") {
            return .reflective
        } else if lowercased.contains("create") || lowercased.contains("imagine") {
            return .creative
        } else if lowercased.contains("analyze") || lowercased.contains("examine") {
            return .analytical
        } else if lowercased.contains("tired") || lowercased.contains("exhausted") {
            return .tired
        } else if lowercased.contains("stress") || lowercased.contains("worry") {
            return .stressed
        }
        return .neutral
    }
    
    private func extractThemes(_ text: String) -> [String] {
        let commonThemes = [
            "creativity", "productivity", "mindfulness", "reflection",
            "planning", "goals", "ideas", "inspiration", "motivation",
            "focus", "routine", "habits", "growth", "learning"
        ]
        let lowercased = text.lowercased()
        let found = commonThemes.filter { lowercased.contains($0) }
        return found.isEmpty ? ["writing", "practice"] : found
    }
    
    private func analyzeStyle(_ text: String, averageSentenceLength: Double) -> [String] {
        var descriptors: [String] = []
        let words = text.components(separatedBy: .whitespacesAndNewlines).filter { !$0.isEmpty }
        if !words.isEmpty {
            let totalCharacters = words.reduce(0) { $0 + $1.count }
            let averageWordLength = Double(totalCharacters) / Double(words.count)
            if averageWordLength > 6 {
                descriptors.append("Sophisticated vocabulary")
            } else if averageWordLength < 4 {
                descriptors.append("Concise wording")
            }
        }
        if averageSentenceLength > 20 {
            descriptors.append("Complex sentence structure")
        } else if averageSentenceLength > 0 && averageSentenceLength < 10 {
            descriptors.append("Short, direct sentences")
        }
        if text.contains("I ") || text.contains(" my ") {
            descriptors.append("Personal tone")
        }
        if descriptors.isEmpty {
            descriptors.append("Balanced writing style")
        }
        return descriptors
    }
    
    private func generateSuggestions(mood: WritingMood, wordCount: Int) -> [String] {
        var suggestions: [String] = []
        if wordCount < 50 {
            suggestions.append("Write a bit more to enable deeper analysis")
        }
        switch mood {
        case .tired, .stressed:
            suggestions.append("Consider taking a short break before continuing")
            suggestions.append("Try free-writing to release tension")
        case .neutral:
            suggestions.append("Experiment with imagery to energize the text")
        case .creative:
            suggestions.append("Organize ideas into clearer sections")
        case .focused:
            suggestions.append("Maintain this steady momentum")
        default:
            suggestions.append("Continue developing your unique voice")
        }
        return suggestions
    }
    
    private func buildInsights(wordCount: Int, themes: [String], style: [String]) -> [WritingInsight] {
        var insights: [WritingInsight] = []
        insights.append(
            WritingInsight(
                type: .productivity,
                title: "Word Count",
                description: "You've written \(wordCount) words",
                confidence: 0.9,
                actionable: false
            )
        )
        if let firstTheme = themes.first {
            insights.append(
                WritingInsight(
                    type: .consistency,
                    title: "Dominant Theme",
                    description: "Your writing gravitates toward \(firstTheme).",
                    confidence: 0.7,
                    actionable: true,
                    suggestions: ["Develop this idea further"]
                )
            )
        }
        if let styleDescriptor = style.first {
            insights.append(
                WritingInsight(
                    type: .style,
                    title: "Writing Style",
                    description: styleDescriptor,
                    confidence: 0.6,
                    actionable: false
                )
            )
        }
        return insights
    }
    
    private func calculateReadabilityScore(averageSentenceLength: Double) -> Double {
        guard averageSentenceLength > 0 else { return 0 }
        let idealLength = 15.0
        let deviation = abs(averageSentenceLength - idealLength)
        return max(0, min(100, 100 - (deviation * 2)))
    }
}

struct AIAnalysisResult: Equatable {
    let mood: WritingMood
    let themes: [String]
    let insights: [WritingInsight]
    let style: [String]
    let suggestions: [String]
    let wordCount: Int
    let readabilityScore: Double
    let averageSentenceLength: Double
}

enum AIAnalysisError: LocalizedError {
    case textTooShort
    
    var errorDescription: String? {
        switch self {
        case .textTooShort:
            return "Please enter some text before requesting analysis."
        }
    }
}
