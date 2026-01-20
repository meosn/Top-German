import SwiftUI
import SwiftData

struct AddWordView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) var dismiss
    @Query var allWords: [GermanWord]
    var editWord: GermanWord?

    @State private var inputText = ""
    @State private var isLoading = false
    @State private var results: [WordDTO] = []
    @State private var errorMessage: String? // Для отображения ошибок

    private let gemini = GeminiService()

    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()
                ScrollView {
                    VStack(spacing: 20) {
                        HStack {
                            TextField("Слово (DE/RU)", text: $inputText)
                                .textFieldStyle(.roundedBorder)
                                .autocorrectionDisabled()
                            
                            Button(action: analyze) {
                                isLoading ? AnyView(ProgressView().tint(.white)) : AnyView(Image(systemName: "sparkles"))
                            }
                            .buttonStyle(.borderedProminent)
                            .disabled(inputText.isEmpty || isLoading)
                        }
                        .padding()
                        
                        if let error = errorMessage {
                            Text(error)
                                .foregroundStyle(.red)
                                .font(.caption)
                                .padding(.horizontal)
                        }

                        ForEach(results) { d in
                            ResultCardView(dto: d, isAlreadyAdded: checkIfAdded(d)) {
                                save(d)
                            }
                        }
                    }
                }
            }
            .navigationTitle(editWord == nil ? "Новое слово" : "Обновить ИИ")
            .toolbar { Button("Готово") { dismiss() } }
            .onAppear { if let w = editWord { inputText = w.original; analyze() } }
        }
    }

    func analyze() {
        isLoading = true
        errorMessage = nil
        Task {
            do {
                let found = try await gemini.fetchWordDetails(for: inputText)
                await MainActor.run { self.results = found; self.isLoading = false }
            } catch {
                await MainActor.run {
                    self.errorMessage = "Ошибка: \(error.localizedDescription)"
                    self.isLoading = false
                }
            }
        }
    }

    func checkIfAdded(_ d: WordDTO) -> Bool {
        allWords.contains { word in
            if let editingId = editWord?.id, word.id == editingId { return false }
            return GermanWord.normalized(word.original) == GermanWord.normalized(d.original) &&
                   word.translation.lowercased() == d.translation.lowercased()
        }
    }

    func save(_ d: WordDTO) {
        // 1. Проверяем дубликат
        if allWords.contains(where: {
            GermanWord.normalized($0.original) == GermanWord.normalized(d.original) &&
            $0.translation.lowercased() == d.translation.lowercased() &&
            editWord == nil // В режиме правки дубликат не ищем
        }) {
            return
        }

        // 2. Создаем или обновляем
        if let existing = editWord {
            existing.original = d.original
            existing.translation = d.translation
            existing.gender = d.gender
            existing.rektion = d.rektion
            existing.plural = d.plural
            existing.praesens = d.praesens
            existing.perfekt = d.perfekt
            existing.examples = d.examples ?? []
        } else {
            let newWord = GermanWord(original: d.original, translation: d.translation, wordType: d.wordType ?? "Noun")
            newWord.gender = d.gender
            newWord.plural = d.plural
            newWord.rektion = d.rektion
            newWord.praesens = d.praesens
            newWord.perfekt = d.perfekt
            newWord.examples = d.examples ?? []
            context.insert(newWord)
        }

        // 3. ПРИНУДИТЕЛЬНОЕ СОХРАНЕНИЕ В ПАМЯТЬ
        do {
            try context.save()
            if editWord == nil {
                withAnimation { results.removeAll { $0.id == d.id } }
            } else {
                dismiss()
            }
        } catch {
            print("CRITICAL SAVE ERROR: \(error)")
        }
    }
}
