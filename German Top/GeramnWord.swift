import Foundation
import SwiftData

@Model
final class GermanWord: Identifiable {
    @Attribute(.unique) var id: UUID = UUID()
    var original: String
    var translation: String 
    var wordType: String
    
    var gender: String? {
        didSet {
            let g = gender?.lowercased().trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            if g.contains("ср") { gender = "das" }
            else if g.contains("муж") || g == "м" { gender = "der" }
            else if g.contains("жен") || g == "ж" { gender = "die" }
            else { gender = g }
        }
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
    }
    
    static func normalized(_ text: String) -> String {
        text.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
    }
}

extension Array {
    func chunked(into size: Int) -> [[Element]] {
        stride(from: 0, to: count, by: size).map { Array(self[$0 ..< Swift.min($0 + size, count)]) }
    }
}
