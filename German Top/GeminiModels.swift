import SwiftUI

//struct TabBarVisibilityKey: EnvironmentKey {
//    static let defaultValue: Binding<Bool> = .constant(false)
//}
//
//extension EnvironmentValues {
//    var isTabBarHidden: Binding<Bool> {
//        get { self[TabBarVisibilityKey.self] }
//        set { self[TabBarVisibilityKey.self] = newValue }
//    }
//}
//
//struct WordLookupItem: Identifiable {
//    let id = UUID()
//    let word: String
//}


struct GeminiResponse: Codable {
    let candidates: [Candidate]
    struct Candidate: Codable { let content: Content }
    struct Content: Codable { let parts: [Part] }
    struct Part: Codable { let text: String? }
}


enum GeminiError: Error { case invalidURL, invalidResponse(Int), decodingError }



