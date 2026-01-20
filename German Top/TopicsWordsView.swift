import SwiftUI
import SwiftData

struct TopicWordsView: View {
    let topicName: String
    @Environment(\.modelContext) private var context
    @Environment(\.isTabBarHidden) var isTabBarHidden
    @Query var allWords: [GermanWord]
    
    @State private var results: [WordDTO] = []
    @State private var isLoading = true
    @State private var selectedLevel = "A1"
    let levels = ["A1", "A2", "B1", "B2", "C1"]
    
    private let gemini = GeminiService()

    var body: some View {
        ZStack {
            GermanColors.deepBlack.ignoresSafeArea()
            
            VStack(spacing: 0) {
                Picker("Level", selection: $selectedLevel) {
                    ForEach(levels, id: \.self) { Text($0) }
                }
                .pickerStyle(.segmented).padding()
                .background(GermanColors.darkCardBG)
                .onChange(of: selectedLevel) { _ in fetch() }

                if isLoading {
                    Spacer(); ProgressView(); Text("ИИ подбирает слова..."); Spacer()
                } else {
                    ScrollView {
                        VStack(spacing: 15) {
                            ForEach(results) { dto in
                                ResultCardView(dto: dto, isAlreadyAdded: checkIfAdded(dto)) {
                                    save(dto)
                                }
                            }
                        }.padding()
                    }
                }
            }
        }
        .navigationTitle(topicName)
        .onAppear { isTabBarHidden.wrappedValue = true; fetch() }
    }

    func fetch() {
        isLoading = true
        Task {
            do {
                let q = "Дай 10 слов на тему \(topicName) для уровня \(selectedLevel)"
                let found = try await gemini.fetchWordDetails(for: q)
                await MainActor.run { results = found; isLoading = false }
            } catch { await MainActor.run { isLoading = false } }
        }
    }

    func checkIfAdded(_ d: WordDTO) -> Bool {
        allWords.contains { GermanWord.normalized($0.original) == GermanWord.normalized(d.original) }
    }

    func save(_ d: WordDTO) {
        let n = GermanWord(original: d.original, translation: d.translation, wordType: d.wordType ?? "Noun")
        n.gender = d.gender; n.plural = d.plural; n.rektion = d.rektion; n.examples = d.examples ?? []
        context.insert(n)
        withAnimation { results.removeAll { $0.id == d.id } }
    }
}
