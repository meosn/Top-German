import SwiftUI

struct TabBarVisibilityKey: EnvironmentKey {
    static let defaultValue: Binding<Bool> = .constant(false)
}

extension EnvironmentValues {
    var isTabBarHidden: Binding<Bool> {
        get { self[TabBarVisibilityKey.self] }
        set { self[TabBarVisibilityKey.self] = newValue }
    }
}

struct WordLookupItem: Identifiable {
    let id = UUID()
    let word: String
}

import SwiftUI

struct WordDTO: Codable, Identifiable {
    var id = UUID()
    let original: String
    let translation: String
    let wordType: String?
    let gender: String?
    let plural: String?
    let praesens: String?
    let praeteritum: String?
    let perfekt: String?
    let rektion: String?
    let examples: [String]?

    enum CodingKeys: String, CodingKey {
        case original, translation, wordType, gender, plural, praesens, praeteritum, perfekt, rektion, examples
    }

    init(original: String, translation: String, wordType: String? = nil, gender: String? = nil, plural: String? = nil, praesens: String? = nil, praeteritum: String? = nil, perfekt: String? = nil, rektion: String? = nil, examples: [String]? = nil) {
        self.id = UUID(); self.original = original; self.translation = translation; self.wordType = wordType; self.gender = gender; self.plural = plural; self.praesens = praesens; self.praeteritum = praeteritum; self.perfekt = perfekt; self.rektion = rektion; self.examples = examples
    }
}

struct SentenceVerification: Codable {
    let isCorrect: Bool
    let feedback: String
    let correctedVersion: String?
}

struct GeminiResponse: Codable {
    let candidates: [Candidate]
    struct Candidate: Codable { let content: Content }
    struct Content: Codable { let parts: [Part] }
    struct Part: Codable { let text: String? }
}

enum GeminiError: Error { case invalidURL, invalidResponse(Int), decodingError }

struct GermanColors {
    static func colorForGender(_ gender: String?) -> Color {
        guard let g = gender?.lowercased() else { return Color.gray.opacity(0.3) }
        if g.contains("der") { return Color.blue }
        if g.contains("die") { return Color.red }
        if g.contains("das") { return Color.green }
        return Color.gray.opacity(0.3)
    }
    static let darkCardBG = Color(white: 0.12)
    static let deepBlack = Color.black
}


