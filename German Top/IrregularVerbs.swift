import SwiftUI
import SwiftData

struct IrregularVerbsView: View {
    @Environment(\.modelContext) private var context
    @Query(sort: \IrregularVerb.original, order: .forward) var suggestedVerbs: [IrregularVerb]
    @Query var allWords: [GermanWord]
    
    @State private var isLoading = false
    @AppStorage("selectedVerbLevel") private var selectedLevel = "A1"
    @State private var lookupItem: WordLookupItem?

    var body: some View {
        NavigationStack {
            ZStack {
                GermanColors.deepBlack.ignoresSafeArea()
                VStack(spacing: 0) {
                    Picker("Level", selection: $selectedLevel) {
                        ForEach(["A1", "A2", "B1", "B2", "C1"], id: \.self) { Text($0) }
                    }.pickerStyle(.segmented).padding().background(GermanColors.darkCardBG)
                    .onChange(of: selectedLevel) { loadVerbs() }

                    ScrollView {
                        VStack(spacing: 15) {
                            ForEach(suggestedVerbs) { verb in
                                VerbSuggestionCard(verb: verb, isAdded: checkIfAdded(verb.original)) {
                                    addToDictionary(verb)
                                } onInfo: {
                                    lookupItem = WordLookupItem(word: verb.original)
                                }
                            }
                            
                            if isLoading {
                                ProgressView("ИИ ищет...").padding()
                            } else {
                                Button("Загрузить новые глаголы") { loadVerbs() }
                                    .font(.headline).foregroundColor(.white).padding().frame(maxWidth: .infinity)
                                    .background(Color.blue).cornerRadius(12)
                            }
                            Spacer(minLength: 120)
                        }.padding()
                    }
                }
            }
            .navigationTitle("Глаголы")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        suggestedVerbs.forEach { context.delete($0) }
                        try? context.save()
                    } label: { Image(systemName: "trash").foregroundColor(.red) }
                }
            }
            .sheet(item: $lookupItem) { item in QuickAddWordView(wordToSearch: item.word) }
        }
    }

    func loadVerbs() {
        isLoading = true
        Task {
            do {
                let found = try await GeminiService().fetchIrregularVerbs(level: selectedLevel)
                await MainActor.run {
                    for d in found {
                        if !allWords.contains(where: { $0.original.lowercased() == d.original.lowercased() }) {
                            let newV = IrregularVerb(
                                original: d.original,
                                translation: d.translation,
                                praesens: d.praesens ?? "",
                                praeteritum: d.praeteritum ?? "",
                                perfekt: d.perfekt ?? "",
                                level: selectedLevel,
                                examples: d.examples ?? []
                            )
                            context.insert(newV)
                        }
                    }
                    try? context.save()
                    isLoading = false
                }
            } catch { isLoading = false }
        }
    }
    func addToDictionary(_ verb: IrregularVerb) {
        let n = GermanWord(original: verb.original.lowercased(), translation: verb.translation, wordType: "Verb")
        n.praesens = verb.praesens; n.praeteritum = verb.praeteritum; n.perfekt = verb.perfekt; n.examples = verb.examples
        context.insert(n)
        context.delete(verb)
        try? context.save()
    }
    
    func checkIfAdded(_ original: String) -> Bool {
        allWords.contains { GermanWord.normalized($0.original) == GermanWord.normalized(original) }
    }
}


struct VerbSuggestionCard: View {
    let verb: IrregularVerb
    var isAdded: Bool
    var onAdd: () -> Void
    var onInfo: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(verb.original).font(.title3).bold().foregroundColor(.white)
                Spacer()
                Button(action: onInfo) {
                    Image(systemName: "info.circle").foregroundColor(.blue)
                }
            }
            Text(verb.translation).foregroundColor(.gray)
            Text("\(verb.praesens) | \(verb.praeteritum) | \(verb.perfekt)").font(.system(size: 11, design: .monospaced)).foregroundColor(.blue)
            
            Button(action: onAdd) {
                Text(isAdded ? "Уже в словаре" : "Добавить в словарь")
                    .font(.headline).frame(maxWidth: .infinity).frame(height: 44)
                    .background(isAdded ? Color.gray.opacity(0.3) : Color.green)
                    .foregroundColor(.white).cornerRadius(10)
            }.disabled(isAdded)
        }
        .padding().background(GermanColors.darkCardBG).cornerRadius(20)
    }
}
