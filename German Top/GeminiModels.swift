import SwiftUI

struct GeminiResponse: Codable {
    let candidates: [Candidate]
    struct Candidate: Codable { let content: Content }
    struct Content: Codable { let parts: [Part] }
    struct Part: Codable { let text: String? }
}


enum GeminiError: Error {
    case invalidURL, invalidResponse(Int), decodingError
}
