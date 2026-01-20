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
    private let gemini = GeminiService()

    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()
                ScrollView {
                    VStack(spacing: 20) {
                        HStack {
                            TextField("Слово...", text: $inputText).textFieldStyle(.roundedBorder)
                            Button { analyze() } label: {
                                isLoading ? AnyView(ProgressView()) : AnyView(Image(systemName: "sparkles"))
                            }.buttonStyle(.borderedProminent).disabled(inputText.isEmpty || isLoading)
                        }.padding()
                        ForEach(results) { d in
                            ResultCardView(dto: d, isAlreadyAdded: checkIfAdded(d)) { save(d) }
                        }
                    }
                }
            }
            .navigationTitle(editWord == nil ? "Новое слово" : "Обновить ИИ")
            .toolbar { ToolbarItem(placement: .topBarTrailing) { Button("Готово") { dismiss() } } }
            .onAppear {
                if let w = editWord {
                    inputText = w.original
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        analyze()
                    }
                }
            }
        }
    }
    func analyze() {
        isLoading = true; Task {
            if let f = try? await gemini.fetchWordDetails(for: inputText) { await MainActor.run { results = f; isLoading = false } }
            else { await MainActor.run { isLoading = false } }
        }
    }
    func checkIfAdded(_ d: WordDTO) -> Bool {
        allWords.contains { GermanWord.normalized($0.original) == GermanWord.normalized(d.original) && $0.translation.lowercased() == d.translation.lowercased() }
    }
    func save(_ d: WordDTO) {
        let type = d.wordType ?? "Noun"
        let w = editWord ?? GermanWord(original: d.original, translation: d.translation, wordType: type)
        
        w.original = d.original
        w.translation = d.translation
        w.wordType = type
        w.gender = d.gender
        w.plural = d.plural 
        w.praesens = d.praesens
        w.praeteritum = d.praeteritum
        w.perfekt = d.perfekt
        w.rektion = d.rektion
        w.examples = d.examples ?? []
        
        if editWord == nil { context.insert(w) }
        withAnimation { results.removeAll { $0.id == d.id } }
    }
}
