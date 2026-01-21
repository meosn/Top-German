import SwiftUI
import SwiftData
import Foundation

import Foundation
import SwiftData

@Model
final class GermanWord: Identifiable {
    @Attribute(.unique) var id: UUID = UUID()
    var original: String
    var translation: String
    var wordType: String
    
    var gender: String? {
        didSet { normalizeGender() }
    }
    
    var plural: String?
    var praesens: String?
    var praeteritum: String?
    var perfekt: String?
    var rektion: String?
    var examples: [String] = []
    var correctCount: Int = 0
    var wrongCount: Int = 0
    var createdAt: Date = Date()

    init(original: String, translation: String, wordType: String = "Noun") {
        self.id = UUID()
        self.original = original
        self.translation = translation
        self.wordType = wordType
        self.createdAt = Date()
    }
    
    private func normalizeGender() {
        guard let g = gender?.lowercased().trimmingCharacters(in: .whitespacesAndNewlines) else { return }
        if g.contains("ср") || g == "n" { gender = "das" }
        else if g.contains("муж") || g == "м" { gender = "der" }
        else if g.contains("жен") || g == "ж" { gender = "die" }
    }
    
    static func normalized(_ text: String) -> String {
        let article = ["der ", "die ", "das ", "ein ", "eine "]
        var cleaned = text.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        for word in article {
            cleaned = cleaned.replacingOccurrences(of: word, with: "")
        }
        return cleaned
    }
}

@Model
final class IrregularVerb: Identifiable {
    @Attribute(.unique) var id: UUID = UUID()
    var original: String
    var translation: String
    var praesens: String
    var praeteritum: String
    var perfekt: String
    var level: String
    var examples: [String] = []
    var createdAt: Date = Date()

    init(original: String, translation: String, praesens: String, praeteritum: String, perfekt: String, level: String, examples: [String] = []) {
        self.original = original
        self.translation = translation
        self.praesens = praesens
        self.praeteritum = praeteritum
        self.perfekt = perfekt
        self.level = level
        self.examples = examples
        self.createdAt = Date()
    }
}


import Foundation
import SwiftData

@Model
final class SavedDeepGrammar {
    @Attribute(.unique) var topic: String
    
    var theoryBrief: String
    var nuancesBrief: [String]
    var examplesBrief: [String]
    var tableBrief: [String]?
    
    var theoryDeep: String?
    var nuancesDeep: [String]?
    var tableDeep: [String]?
    var examplesDeep: [String]?
    
    var isDetailedMode: Bool = false
    var createdAt: Date = Date()

    init(topic: String, theoryBrief: String, nuancesBrief: [String], examplesBrief: [String], tableBrief: [String]? = nil) {
        self.topic = topic
        self.theoryBrief = theoryBrief
        self.nuancesBrief = nuancesBrief
        self.examplesBrief = examplesBrief
        self.tableBrief = tableBrief
        self.isDetailedMode = false
        self.createdAt = Date()
    }
}

struct WordDTO: Codable, Identifiable {
    var id: UUID = UUID()
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

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = UUID()
        self.original = try container.decode(String.self, forKey: .original)
        self.translation = try container.decode(String.self, forKey: .translation)
        self.wordType = try container.decodeIfPresent(String.self, forKey: .wordType)
        self.gender = try container.decodeIfPresent(String.self, forKey: .gender)
        self.plural = try container.decodeIfPresent(String.self, forKey: .plural)
        self.praesens = try container.decodeIfPresent(String.self, forKey: .praesens)
        self.praeteritum = try container.decodeIfPresent(String.self, forKey: .praeteritum)
        self.perfekt = try container.decodeIfPresent(String.self, forKey: .perfekt)
        self.rektion = try container.decodeIfPresent(String.self, forKey: .rektion)
        
        if let sArray = try? container.decodeIfPresent([String].self, forKey: .examples) {
            self.examples = sArray
        } else if let dArray = try? container.decodeIfPresent([[String: String]].self, forKey: .examples) {
            self.examples = dArray.map { "\($0["german"] ?? "") (\($0["russian"] ?? ""))" }
        } else {
            self.examples = nil
        }
    }

    init(id: UUID = UUID(), original: String, translation: String, wordType: String?, gender: String?, plural: String?, praesens: String?, praeteritum: String?, perfekt: String?, rektion: String?, examples: [String]?) {
        self.id = id
        self.original = original
        self.translation = translation
        self.wordType = wordType
        self.gender = gender
        self.plural = plural
        self.praesens = praesens
        self.praeteritum = praeteritum
        self.perfekt = perfekt
        self.rektion = rektion
        self.examples = examples
    }
}


struct SentenceVerification: Codable { let isCorrect: Bool; let feedback: String; let correctedVersion: String? }
struct WordLookupItem: Identifiable { let id = UUID(); let word: String }
enum SwipeDirection { case left, right }

struct TabBarVisibilityKey: EnvironmentKey { static let defaultValue: Binding<Bool> = .constant(false) }
extension EnvironmentValues {
    var isTabBarHidden: Binding<Bool> {
        get { self[TabBarVisibilityKey.self] }
        set { self[TabBarVisibilityKey.self] = newValue }
    }
}
extension Array {
    func chunked(into size: Int) -> [[Element]] {
        return stride(from: 0, to: count, by: size).map {
            Array(self[$0 ..< Swift.min($0 + size, count)])
        }
    }
}

struct DeepGrammarInfo: Codable {
    let theory: String
    let nuances: [String]
    let table: [String]?
    let manyExamples: [String]
}



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
