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
    @State private var lookupItem: WordLookupItem?
    
    let levels = ["A1", "A2", "B1", "B2", "C1"]
    private let gemini = GeminiService()

    var body: some View {
        ZStack {
            GermanColors.deepBlack.ignoresSafeArea()
            
            VStack(spacing: 0) {
                VStack(spacing: 10) {
                    Text("УРОВЕНЬ СЛОЖНОСТИ СЛОВ:")
                        .font(.system(size: 10, weight: .black))
                        .foregroundColor(.gray)
                    
                    Picker("Level", selection: $selectedLevel) {
                        ForEach(levels, id: \.self) { Text($0) }
                    }
                    .pickerStyle(.segmented)
                    .onChange(of: selectedLevel) { _, _ in
                        fetchWords()
                    }
                }
                .padding()
                .background(GermanColors.darkCardBG)

                if isLoading {
                    VStack(spacing: 20) {
                        Spacer()
                        ProgressView()
                            .scaleEffect(1.5)
                        Text("ИИ подбирает слова для темы '\(topicName)'...")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        Spacer()
                    }
                } else {
                    ScrollView {
                        VStack(spacing: 15) {
                            if results.isEmpty {
                                ContentUnavailableView("Ничего не найдено", systemImage: "magnifyingglass")
                                    .padding(.top, 50)
                            }
                            
                            ForEach(results) { dto in
                                ResultCardView(
                                    dto: dto,
                                    isAlreadyAdded: checkIfAdded(dto)
                                ) {
                                    saveWord(dto)
                                }
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    self.lookupItem = WordLookupItem(word: dto.original)
                                }
                            }
                            Spacer(minLength: 120)
                        }
                        .padding()
                    }
                }
            }
        }
        .navigationTitle(topicName)
        .navigationBarTitleDisplayMode(.inline)
        .sheet(item: $lookupItem) { item in
            QuickAddWordView(wordToSearch: item.word)
        }
        .onAppear {
            isTabBarHidden.wrappedValue = true
            if results.isEmpty { fetchWords() }
        }
        .onDisappear {
            isTabBarHidden.wrappedValue = false
        }
    }

    func fetchWords() {
        isLoading = true
        results = []
        
        Task {
            let prompt = "Дай 10 важных немецких слов на тему '\(topicName)' для уровня \(selectedLevel). original: ВСЕГДА нем. нач. форма. translation: ВСЕГДА рус. перевод. Обязательно заполни все грамматические поля и дай примеры. Верни ТОЛЬКО JSON массив WordDTO []."
            
            do {
                let found = try await gemini.fetchWordDetails(for: prompt)
                await MainActor.run {
                    self.results = found
                    self.isLoading = false
                }
            } catch {
                print("Error fetching topic words: \(error)")
                await MainActor.run { self.isLoading = false }
            }
        }
    }

    func checkIfAdded(_ d: WordDTO) -> Bool {
        let normNew = GermanWord.normalized(d.original)
        return allWords.contains { word in
            GermanWord.normalized(word.original) == normNew &&
            word.translation.lowercased() == d.translation.lowercased()
        }
    }

    func saveWord(_ d: WordDTO) {
        if checkIfAdded(d) { return }
        
        let newWord = GermanWord(
            original: d.original,
            translation: d.translation,
            wordType: d.wordType ?? "Noun"
        )
        
        newWord.gender = d.gender
        newWord.plural = d.plural
        newWord.praesens = d.praesens
        newWord.praeteritum = d.praeteritum
        newWord.perfekt = d.perfekt
        newWord.rektion = d.rektion
        newWord.examples = d.examples ?? []
        
        context.insert(newWord)
        
        try? context.save()
        withAnimation {
            results.removeAll { $0.id == d.id }
        }
    }
}
