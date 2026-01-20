import Foundation

class GeminiService {
    private let apiKey: String = "AIzaSyCkUEQQRA_zIvvUU3xxnSh7rvVrjvdJEsQ"
    private let baseUrl: String = "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash-exp:generateContent"

    func fetchWordDetails(for word: String) async throws -> [WordDTO] {
        let prompt = """
        Ты профессиональный немецкий словарь. Анализируй: "\(word)". 
        СТРОГИЕ ПРАВИЛА ГРАММАТИКИ:
        1. Для СУЩЕСТВИТЕЛЬНЫХ:gender обязательно только die, der, das, Обязательно 'plural' (с артиклем die) и 'rektion' (если есть управление).
        2. Для ГЛАГОЛОВ: Обязательно формы: 'praesens' (3-е лицо), 'praeteritum' (3-е лицо), 'perfekt' (с hat/ist) и 'rektion'.
        3. 'original' всегда в начальной форме. 'translation' на русском.
        в examples приведи 2-3 примера с этим словом на немецком и перевод примера в скобках
        Верни ТОЛЬКО JSON массив [].
        """
        return try await performRequest(prompt: prompt, type: [WordDTO].self)
    }

    func generateSentence(for word: GermanWord) async throws -> String {
        let prompt = "Напиши ОДНО простое предложение на русском, подразумевающее использование слова '\(word.original)'. НЕ используй немецкие слова. Только текст."
        return try await performRawRequest(prompt: prompt)
    }

    func verifyTranslation(userText: String, russianSentence: String, targetWord: String) async throws -> SentenceVerification {
        let prompt = """
        Ты лояльный учитель. Проверь перевод. RU: "\(russianSentence)", User DE: "\(userText)", Target Word: "\(targetWord)".
        Если грамматика верна и смысл передан -> "isCorrect": true. Не придирайся к порядку слов.
        Верни JSON: {"isCorrect": bool, "feedback": "ru", "correctedVersion": "de"}

        """
        return try await performRequest(prompt: prompt, type: SentenceVerification.self)
    }

    func verifySynonym(userWord: String, targetWord: String) async throws -> SentenceVerification {
        let prompt = "Являются ли '\(userWord)' и '\(targetWord)' синонимами? JSON: {isCorrect, feedback, correctedVersion}."
        return try await performRequest(prompt: prompt, type: SentenceVerification.self)
    }

    func fetchSynonymHint(for word: String) async throws -> String {
        let prompt = "Напиши 3 немецких синонима для слова '\(word)' через запятую. Верни только синонимы"
        return try await performRawRequest(prompt: prompt)
    }

    func generateExtraExample(for word: String) async throws -> String {
        let prompt = "Напиши один короткий пример на нем. со словом '\(word)' и перевод примера в скобках. Верни ТОЛЬКО пример и перевод в скобках"
        return try await performRawRequest(prompt: prompt)
    }

    private func performRawRequest(prompt: String) async throws -> String {
        let urlStr = "\(baseUrl)?key=\(apiKey)"
        guard let url = URL(string: urlStr) else { throw GeminiError.invalidURL }
        let body: [String: Any] = ["contents": [["parts": [["text": prompt]]]]]
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        let (data, response) = try await URLSession.shared.data(for: request)
        if let res = response as? HTTPURLResponse, res.statusCode != 200 { throw GeminiError.invalidResponse(res.statusCode) }
        let result = try JSONDecoder().decode(GeminiResponse.self, from: data)
        return result.candidates.first?.content.parts.first?.text ?? ""
    }

    private func performRequest<T: Codable>(prompt: String, type: T.Type) async throws -> T {
        let rawText = try await performRawRequest(prompt: prompt)
        var clean = rawText
        if let f = clean.firstIndex(where: { $0 == "[" || $0 == "{" }), let l = clean.lastIndex(where: { $0 == "]" || $0 == "}" }) {
            clean = String(clean[f...l])
        }
        clean = clean.replacingOccurrences(of: "```json", with: "").replacingOccurrences(of: "```", with: "")
        guard let data = clean.data(using: .utf8) else { throw GeminiError.decodingError }
        return try JSONDecoder().decode(T.self, from: data)
    }
}
