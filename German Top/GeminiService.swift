import Foundation

class GeminiService {
    private let apiKey: String = "AIzaSyCkUEQQRA_zIvvUU3xxnSh7rvVrjvdJEsQ"
    private let baseUrl: String = "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash-exp:generateContent"

    func fetchWordDetails(for word: String) async throws -> [WordDTO] {
        let prompt = """
        Ты профессиональный немецкий словарь. Анализируй: "\(word)". 
        
        ПРАВИЛА ДЛЯ ПОЛЯ "rektion" (УПРАВЛЕНИЕ):
        - КАТЕГОРИЧЕСКИ ЗАПРЕЩЕНО писать "transitive", "intransitive", "refl" или "—".
        - Если у слова есть устойчивое управление, пиши его. Если вариантов кпраавлениям несколько, пиши все (с поснением на русском).
        - Если управления нет, пиши null.
        
        СТРОГИЕ ПРАВИЛА ДЛЯ ГЛАГОЛОВ:
            - Если слово является ГЛАГОЛОМ, ты ОБЯЗАН заполнить поле "praeteritum".
            - "praeteritum": форма 3-го лица единственного числа (например: для 'erleben' это 'erlebte', для 'sehen' это 'sah').
            - Поле "praeteritum" не может быть null для глаголов.
        
        ОСТАЛЬНЫЕ ПРАВИЛА:
        1. "original": немецкая нач. форма. 
        2. "translation": русский перевод. 
        3. "gender": только 'der', 'die', 'das'.
        4. "examples": 2 примера "Нем (Рус)".
        5. Для глаголов обязательно заполняй все три поля форм: praesens, praeteritum, perfekt
        6. Также заполняй wordType (только Noun, Verb, Adjective, или Phrase)
        
        Верни ТОЛЬКО JSON массив [].
        """
        return try await performRequest(prompt: prompt, type: [WordDTO].self)
    }

    func generateSentence(for word: GermanWord) async throws -> String {
        let prompt = "Напиши ОДНО простое предложение на русском, подразумевающее использование слова '\(word.original)'. НЕ используй немецкие слова. Только текст."
        return try await performRawRequest(prompt: prompt)
    }
    func askAnything(topic: String, question: String) async throws -> String {
            let prompt = "Ты преподаватель немецкого. Тема: '\(topic)'. Ответь кратко на вопрос ученика: \(question). Используй примеры."
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
    
    func fetchIrregularVerbs(level: String) async throws -> [WordDTO] {
        let prompt = """
        Найди 10 популярных неправильных немецких глаголов для уровня \(level).
        Верни ТОЛЬКО JSON массив [].
        ОБЯЗАТЕЛЬНО заполни поля: 
        "original" (инфинитив), 
        "translation" (русский), 
        "praesens" (3 л. ед.ч.), 
        "praeteritum" (3 л. ед.ч.), 
        "perfekt" (с hat/ist),
        "examples" (2 примера в формате "Нем (Рус)").
        """
        return try await performRequest(prompt: prompt, type: [WordDTO].self)
    }

    func fetchDeepGrammar(topic: String, isExtraDetailed: Bool) async throws -> DeepGrammarInfo {
            let modeInstruction = isExtraDetailed
                ? "Напиши ФУНДАМЕНТАЛЬНЫЙ глубокий разбор. МАКСИМАЛЬНО подробные таблицы всех форм и исключений. Минимум 8 абзацев теории."
                : "Напиши КРАТКИЙ обзор сути правила. ТАБЛИЦА основных форм ОБЯЗАТЕЛЬНА."

            let prompt = """
            Ты — ведущий лингвист-германист. Тема: "\(topic)".
            \(modeInstruction)
            
            СТРОГОЕ ПРАВИЛО ДЛЯ ТАБЛИЦ:
            Если в теме есть структура (падежи, окончания, спряжения, предлоги), ты ОБЯЗАН создать таблицу в поле "table".
            Формат: массив строк, колонки через "|". Первая строка - заголовки.

            Верни ТОЛЬКО JSON:
            {
              "theory": "текст на русском",
              "nuances": ["нюанс 1", "..."],
              "table": ["Заголовок 1 | Заголовок 2", "Строка 1 | Данные 1"],
              "manyExamples": ["DE (RU)"]
            }
            """
            return try await performRequest(prompt: prompt, type: DeepGrammarInfo.self)
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
            if let res = response as? HTTPURLResponse, res.statusCode != 200 {
                print("AI SERVER ERROR: \(res.statusCode)")
                throw GeminiError.invalidResponse(res.statusCode)
            }
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
            do {
                return try JSONDecoder().decode(T.self, from: data)
            } catch {
                print("DECODING ERROR: \(error)") 
                throw GeminiError.decodingError
            }
        }
}
