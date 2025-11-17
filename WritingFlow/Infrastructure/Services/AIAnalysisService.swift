import Foundation
import FoundationModels

// MARK: - Generable Types for AI Analysis

@Generable(description: "Analysis of writing mood and emotional tone from text content")
struct WritingMoodAnalysis {
    @Guide(description: "The primary mood detected in the writing")
    let mood: String

    @Guide(description: "Confidence level between 0.0 and 1.0")
    let confidence: Double

    @Guide(description: "Brief explanation of why this mood was identified")
    let reasoning: String
}

@Generable(description: "Main themes and topics identified in the writing")
struct ThemeAnalysis {
    @Guide(description: "List of 3-5 main themes found in the text")
    let themes: [String]

    @Guide(description: "Brief description of each theme's relevance")
    let themeDescriptions: [String]
}

@Generable(description: "Writing insights and observations")
struct WritingInsightAnalysis {
    @Guide(description: "Type of insight: productivity, style, structure, or flow")
    let type: String

    @Guide(description: "Title summarizing the insight")
    let title: String

    @Guide(description: "Detailed description of the insight")
    let description: String

    @Guide(description: "Confidence level between 0.0 and 1.0")
    let confidence: Double

    @Guide(description: "List of actionable suggestions based on this insight")
    let suggestions: [String]
}

@Generable(description: "Writing style analysis including vocabulary and structure")
struct StyleAnalysis {
    @Guide(description: "List of 2-4 style characteristics observed")
    let characteristics: [String]

    @Guide(description: "Average sentence complexity: simple, moderate, or complex")
    let sentenceComplexity: String

    @Guide(description: "Vocabulary level: basic, intermediate, or advanced")
    let vocabularyLevel: String
}

@Generable(description: "Complete AI analysis result combining all aspects of the writing")
struct AIAnalysis {
    @Guide(description: "The detected writing mood from predefined options")
    let mood: String

    @Guide(description: "List of 3-5 main themes")
    let themes: [String]

    @Guide(description: "2-3 key insights about the writing")
    let insights: [String]

    @Guide(description: "2-3 style characteristics")
    let styleCharacteristics: [String]

    @Guide(description: "3-5 constructive suggestions for improvement")
    let suggestions: [String]

    @Guide(description: "Readability score from 0 to 100")
    let readabilityScore: Double
}

// MARK: - AI Analysis Service

@MainActor
final class AIAnalysisService {

    private let session: LanguageModelSession

    init() {
        // Initialize session with instructions for writing analysis
        let instructions = """
        You are an expert writing analyst and coach specializing in creative writing, journaling, and content creation.
        Your role is to provide insightful, constructive, and encouraging feedback on writing samples.

        When analyzing text:
        - Focus on the emotional tone and mood of the writing
        - Identify recurring themes and topics
        - Recognize writing patterns and style characteristics
        - Provide actionable, positive suggestions for improvement
        - Be supportive and encouraging while remaining honest
        - Keep analyses concise and focused

        For mood analysis, use these categories: enthusiastic, focused, reflective, creative, analytical, neutral, tired, stressed

        Provide specific, detailed feedback that helps writers understand their patterns and improve their craft.
        """

        self.session = LanguageModelSession(instructions: instructions)
    }

    func analyzeText(_ text: String) async throws -> AIAnalysisResult {
        // Check if text is too short for meaningful analysis
        guard !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return createEmptyResult()
        }

        // Calculate basic statistics
        let wordCount = calculateWordCount(text)
        let averageSentenceLength = calculateAverageSentenceLength(text)

        // Use Foundation Models for AI-powered analysis
        let prompt = """
        Analyze the following writing sample and provide comprehensive feedback:

        Text: "\(text)"

        Please provide:
        1. The primary mood/emotional tone (choose from: enthusiastic, focused, reflective, creative, analytical, neutral, tired, stressed)
        2. Main themes (3-5 key topics or subjects)
        3. Key insights about the writing (2-3 observations)
        4. Style characteristics (2-3 notable features)
        5. Constructive suggestions for improvement (3-5 specific recommendations)
        6. A readability score from 0-100 (higher = more readable)
        """

        // Configure generation options for more creative analysis
        let options = GenerationOptions(
            sampling: .random(top: 10),
            temperature: 0.7
        )

        do {
            // Generate structured analysis using Foundation Models
            let analysis = try await session.respond(
                to: prompt,
                generating: AIAnalysis.self,
                options: options
            )

            // Convert AI analysis to domain model
            return convertToAnalysisResult(
                analysis: analysis,
                wordCount: wordCount,
                averageSentenceLength: averageSentenceLength
            )

        } catch {
            // If Foundation Models fails, fall back to basic analysis
            print("Foundation Models unavailable, using fallback: \(error)")
            return createFallbackAnalysis(text: text, wordCount: wordCount, averageSentenceLength: averageSentenceLength)
        }
    }

    // MARK: - Helper Methods

    private func calculateWordCount(_ text: String) -> Int {
        let words = text.components(separatedBy: .whitespacesAndNewlines)
        return words.filter { !$0.isEmpty }.count
    }

    private func calculateAverageSentenceLength(_ text: String) -> Double {
        let sentences = text.components(separatedBy: CharacterSet(charactersIn: ".!?"))
            .filter { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }

        guard !sentences.isEmpty else { return 0 }

        let words = text.components(separatedBy: .whitespacesAndNewlines)
            .filter { !$0.isEmpty }

        return Double(words.count) / Double(sentences.count)
    }

    private func convertToAnalysisResult(
        analysis: AIAnalysis,
        wordCount: Int,
        averageSentenceLength: Double
    ) -> AIAnalysisResult {
        // Convert mood string to enum
        let mood = WritingMood(rawValue: analysis.mood.lowercased()) ?? .neutral

        // Convert insights to structured format
        let insights = analysis.insights.enumerated().map { index, insight in
            WritingInsight(
                type: determineInsightType(from: insight),
                title: "Insight \(index + 1)",
                description: insight,
                confidence: 0.8,
                actionable: true,
                suggestions: []
            )
        }

        return AIAnalysisResult(
            mood: mood,
            themes: analysis.themes,
            insights: insights,
            style: analysis.styleCharacteristics,
            suggestions: analysis.suggestions,
            wordCount: wordCount,
            readabilityScore: analysis.readabilityScore,
            averageSentenceLength: averageSentenceLength
        )
    }

    private func determineInsightType(from insight: String) -> InsightType {
        let lowercased = insight.lowercased()

        if lowercased.contains("productiv") || lowercased.contains("output") {
            return .productivity
        } else if lowercased.contains("style") || lowercased.contains("voice") {
            return .style
        } else if lowercased.contains("mood") || lowercased.contains("emotion") {
            return .mood
        } else if lowercased.contains("structure") || lowercased.contains("organization") {
            return .structure
        } else if lowercased.contains("vocabular") || lowercased.contains("word") {
            return .vocabulary
        } else if lowercased.contains("flow") || lowercased.contains("rhythm") {
            return .flow
        } else {
            return .consistency
        }
    }

    private func createEmptyResult() -> AIAnalysisResult {
        return AIAnalysisResult(
            mood: .neutral,
            themes: [],
            insights: [],
            style: ["No content to analyze"],
            suggestions: ["Start writing to receive AI-powered insights"],
            wordCount: 0,
            readabilityScore: 0,
            averageSentenceLength: 0
        )
    }

    private func createFallbackAnalysis(
        text: String,
        wordCount: Int,
        averageSentenceLength: Double
    ) -> AIAnalysisResult {
        // Simple fallback analysis when AI is unavailable
        let mood = analyzeMoodFallback(text)
        let themes = extractThemesFallback(text)
        let style = analyzeStyleFallback(text, averageSentenceLength: averageSentenceLength)
        let suggestions = generateSuggestionsFallback(mood: mood, wordCount: wordCount)
        let readabilityScore = calculateReadabilityScoreFallback(averageSentenceLength)

        let insights = [
            WritingInsight(
                type: .productivity,
                title: "Word Count",
                description: "You've written \(wordCount) words",
                confidence: 1.0,
                actionable: false,
                suggestions: []
            )
        ]

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

    // MARK: - Fallback Analysis Methods

    private func analyzeMoodFallback(_ text: String) -> WritingMood {
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

    private func extractThemesFallback(_ text: String) -> [String] {
        let commonThemes = [
            "creativity", "productivity", "mindfulness", "reflection",
            "planning", "goals", "ideas", "inspiration", "motivation",
            "focus", "routine", "habits", "growth", "learning"
        ]

        let lowercased = text.lowercased()
        return commonThemes.filter { lowercased.contains($0) }
    }

    private func analyzeStyleFallback(_ text: String, averageSentenceLength: Double) -> [String] {
        var style: [String] = []

        let words = text.components(separatedBy: .whitespacesAndNewlines).filter { !$0.isEmpty }
        let averageWordLength = words.reduce(0, { $0 + $1.count }) / max(1, words.count)

        if averageWordLength > 6 {
            style.append("Sophisticated vocabulary")
        } else if averageWordLength < 4 {
            style.append("Concise writing style")
        }

        if averageSentenceLength > 20 {
            style.append("Complex sentence structure")
        } else if averageSentenceLength < 10 {
            style.append("Short, direct sentences")
        }

        if text.contains("I") || text.contains("my") {
            style.append("Personal tone")
        }

        return style.isEmpty ? ["Neutral writing style"] : style
    }

    private func generateSuggestionsFallback(mood: WritingMood, wordCount: Int) -> [String] {
        var suggestions: [String] = []

        if wordCount < 50 {
            suggestions.append("Try writing more to enable deeper analysis")
        }

        switch mood {
        case .tired, .stressed:
            suggestions.append("Consider taking a short break")
            suggestions.append("Try writing in a different environment")
        case .neutral:
            suggestions.append("Add more descriptive details")
            suggestions.append("Vary sentence structure for better flow")
        case .creative:
            suggestions.append("Organize ideas into clear sections")
        case .focused:
            suggestions.append("Maintain this excellent momentum")
        default:
            suggestions.append("Continue developing your unique voice")
        }

        return suggestions
    }

    private func calculateReadabilityScoreFallback(_ averageSentenceLength: Double) -> Double {
        let idealLength = 15.0
        let deviation = abs(averageSentenceLength - idealLength)
        return max(0, min(100, 100 - (deviation * 2)))
    }
}

// MARK: - Supporting Types

struct AIAnalysisResult {
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
    case modelUnavailable
    case invalidResponse
    case processingFailed
    case textTooShort

    var errorDescription: String? {
        switch self {
        case .modelUnavailable:
            return "AI model is not available on this device"
        case .invalidResponse:
            return "Invalid response from AI model"
        case .processingFailed:
            return "Failed to process text analysis"
        case .textTooShort:
            return "Text is too short for meaningful analysis"
        }
    }
}

// MARK: - Domain Types (referenced from Domain layer)

enum WritingMood: String, CaseIterable {
    case enthusiastic = "enthusiastic"
    case focused = "focused"
    case reflective = "reflective"
    case creative = "creative"
    case analytical = "analytical"
    case neutral = "neutral"
    case tired = "tired"
    case stressed = "stressed"
}

struct WritingInsight {
    let type: InsightType
    let title: String
    let description: String
    let confidence: Double
    let actionable: Bool
    let suggestions: [String]
}

enum InsightType: String, CaseIterable {
    case productivity = "productivity"
    case style = "style"
    case mood = "mood"
    case structure = "structure"
    case vocabulary = "vocabulary"
    case flow = "flow"
    case consistency = "consistency"
}
