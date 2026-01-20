import SwiftUI
import SwiftData

struct IrregularVerbsView: View {
    @Environment(\.modelContext) private var context
    @Query(sort: \IrregularVerb.createdAt, order: .forward) var suggestedVerbs: [IrregularVerb]
    @Query var allWords: [GermanWord]
    
    @State private var isLoading = false
    @AppStorage("selectedVerbLevel") private var selectedLevel = "A1"
    private let gemini = GeminiService()

    var body: some View {
        NavigationStack {
            ZStack {
                GermanColors.deepBlack.ignoresSafeArea()
                VStack(spacing: 0) {
                    Picker("Level", selection: $selectedLevel) {
                        ForEach(["A1", "A2", "B1", "B2", "C1"], id: \.self) { Text($0) }
                    }
                    .pickerStyle(.segmented).padding().background(GermanColors.darkCardBG)
                    .onChange(of: selectedLevel) { _, _ in loadVerbs() }

                    ScrollViewReader { proxy in
                        ScrollView {
                            VStack(spacing: 15) {
                                ForEach(suggestedVerbs) { verb in
                                    VerbSuggestionCard(verb: verb, onAdd: { addToDictionary(verb) }, onTap: { /* ... */ })
                                }
                                
                                if isLoading {
                                    ProgressView("ИИ ищет...").id("bottomLoader").padding()
                                } else {
                                    Button(action: loadVerbs) {
                                        Label("Загрузить еще 10", systemImage: "plus.circle.fill")
                                            .foregroundColor(.white).frame(maxWidth: .infinity).padding().background(Color.blue).cornerRadius(15)
                                    }.padding()
                                }
                                Spacer(minLength: 120)
                            }
                            .padding()
                        }
                    }
                }
            }
            .navigationTitle("Глаголы")
            .onAppear { if suggestedVerbs.isEmpty { loadVerbs() } }
        }
    }

    func loadVerbs() {
        guard !isLoading else { return }
        isLoading = true
        
        Task {
            do {
                let found = try await gemini.fetchIrregularVerbs(level: selectedLevel)
                await MainActor.run {
                    for d in found {
                        let verb = IrregularVerb(
                            original: d.original,
                            translation: d.translation,
                            praesens: d.praesens ?? "",
                            praeteritum: d.praeteritum ?? "",
                            perfekt: d.perfekt ?? "",
                            level: selectedLevel,
                            examples: d.examples ?? []
                        )
                        context.insert(verb)
                    }
                    try? context.save() // СОХРАНИТЬ
                    isLoading = false
                }
            } catch {
                print("AI FETCH ERROR: \(error)")
                await MainActor.run { isLoading = false }
            }
        }
    }
    func addToDictionary(_ verb: IrregularVerb) {
        let n = GermanWord(original: verb.original, translation: verb.translation, wordType: "Verb")
        n.praesens = verb.praesens; n.praeteritum = verb.praeteritum; n.perfekt = verb.perfekt; n.examples = verb.examples
        context.insert(n)
        context.delete(verb)
        try? context.save()
    }
}


struct VerbSuggestionCard: View {
    let verb: IrregularVerb
    var onAdd: () -> Void
    var onTap: () -> Void
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Button(action: onTap) {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text(verb.original).font(.title3).bold().foregroundColor(.white)
                        Spacer()
                        Image(systemName: "info.circle").foregroundColor(.blue)
                    }
                    Text(verb.translation).foregroundColor(.gray)
                    Text("\(verb.praesens) | \(verb.praeteritum) | \(verb.perfekt)").font(.system(size: 11, design: .monospaced)).foregroundColor(.blue)
                }
            }.buttonStyle(.plain)
            Button(action: onAdd) {
                Label("Добавить", systemImage: "plus").bold().frame(maxWidth: .infinity).frame(height: 44).background(Color.green).foregroundColor(.white).cornerRadius(12)
            }
        }.padding().background(GermanColors.darkCardBG).cornerRadius(20)
    }
}
