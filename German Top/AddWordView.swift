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
    @State private var errorMessage: String?

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
        if checkIfAdded(d) && editWord == nil { return }
        
        let type = d.wordType ?? "Word"
        let w = editWord ?? GermanWord(original: d.original, translation: d.translation, wordType: type)
        
        w.original = d.original
        w.translation = d.translation
        w.wordType = type
        w.gender = d.gender
        w.plural = d.plural
        w.rektion = d.rektion
        w.praesens = d.praesens
        w.praeteritum = d.praeteritum
        w.perfekt = d.perfekt
        w.examples = d.examples ?? []
        
        if editWord == nil { context.insert(w) }
        
        try? context.save()
        if editWord != nil { dismiss() }
        else { withAnimation { results.removeAll { $0.id == d.id } } }
    }
}
