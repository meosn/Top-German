import SwiftUI
import SwiftData

struct QuickAddWordView: View {
    let wordToSearch: String
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) var dismiss
    @Query var allWords: [GermanWord]
    @State private var results: [WordDTO] = []
    @State private var isLoading = true
    private let gemini = GeminiService()

    var body: some View {
        NavigationStack {
            VStack {
                if isLoading { ProgressView("Анализ ИИ...") }
                else {
                    ScrollView {
                        VStack(spacing: 16) {
                            ForEach(results) { dto in
                                ResultCardView(dto: dto, isAlreadyAdded: checkIfAdded(dto)) { save(dto) }
                            }
                        }.padding()
                    }
                }
            }
            .navigationTitle(wordToSearch)
            .toolbar { ToolbarItem(placement: .topBarTrailing) { Button("Готово") { dismiss() } } }
            .onAppear { search() }
        }
    }
    func search() { Task { if let f = try? await gemini.fetchWordDetails(for: wordToSearch) { await MainActor.run { results = f; isLoading = false } } } }
    func checkIfAdded(_ d: WordDTO) -> Bool {
        allWords.contains { GermanWord.normalized($0.original) == GermanWord.normalized(d.original) && $0.translation.lowercased() == d.translation.lowercased() }
    }
    func save(_ d: WordDTO) {
        let n = GermanWord(original: d.original, translation: d.translation, wordType: d.wordType ?? "Word")
        n.gender = d.gender; n.rektion = d.rektion; n.examples = d.examples ?? []
        context.insert(n); withAnimation { results.removeAll { $0.id == d.id } }
    }
}
