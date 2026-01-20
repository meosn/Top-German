import SwiftUI
import SwiftData

struct GrammarDeepDetailView: View {
    let topic: String
    @Environment(\.modelContext) private var context
    @Environment(\.isTabBarHidden) var isTabBarHidden
    @Query var savedGrammars: [SavedDeepGrammar]
    
    @State private var isLoading = false
    @State private var lookupItem: WordLookupItem?
    
    private let gemini = GeminiService()
    
    private var current: SavedDeepGrammar? {
        savedGrammars.first(where: { $0.topic == topic })
    }

    var body: some View {
        ZStack {
            GermanColors.deepBlack.ignoresSafeArea()
            
            if isLoading {
                VStack(spacing: 20) {
                    ProgressView().scaleEffect(1.5)
                    Text("ИИ обрабатывает запрос...").foregroundColor(.gray)
                }
            } else if let info = current {
                ScrollView {
                    VStack(alignment: .leading, spacing: 25) {
                        
                        // ПЕРЕКЛЮЧАТЕЛЬ РЕЖИМОВ
                        HStack {
                            Text(info.isDetailedMode ? "ГЛУБОКИЙ РАЗБОР" : "КРАТКИЙ ОБЗОР")
                                .font(.system(size: 10, weight: .black))
                                .padding(6)
                                .background(info.isDetailedMode ? Color.purple : Color.blue)
                                .cornerRadius(6)
                                .foregroundColor(.white)
                            
                            Spacer()
                            
                            Button(info.isDetailedMode ? "Сжать" : "Развернуть") {
                                toggleMode()
                            }
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.blue)
                        }

                        // КОНТЕНТ
                        theoryBlock(info)
                        
                        if info.isDetailedMode {
                            tableBlock(info)
                        }

                        exampleBlock(info)
                        
                        // КНОПКА ЧАТА
                        NavigationLink(destination: GrammarChatView(topic: topic)) {
                            HStack {
                                Image(systemName: "sparkles")
                                Text("Обсудить с ИИ")
                            }
                            .font(.headline).foregroundColor(.white)
                            .frame(maxWidth: .infinity).padding()
                            .background(Color.blue).cornerRadius(15)
                        }
                        
                        Spacer(minLength: 120)
                    }
                    .padding()
                }
            }
        }
        .navigationTitle(topic)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            isTabBarHidden.wrappedValue = true
            if current == nil { loadInitialBrief() }
        }
        .sheet(item: $lookupItem) { item in
            QuickAddWordView(wordToSearch: item.word)
        }
    }

    // MARK: - Блоки контента
    
    private func theoryBlock(_ info: SavedDeepGrammar) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("ТЕОРИЯ").font(.system(size: 12, weight: .black)).foregroundColor(.blue)
            Text(info.isDetailedMode ? (info.theoryDeep ?? "") : info.theoryBrief)
                .foregroundColor(.white).lineSpacing(7)
        }
        .padding().background(GermanColors.darkCardBG).cornerRadius(15)
    }

    @ViewBuilder
    private func tableBlock(_ info: SavedDeepGrammar) -> some View {
        if let table = info.tableDeep, !table.isEmpty {
            VStack(alignment: .leading, spacing: 10) {
                Text("ТАБЛИЦА").font(.system(size: 12, weight: .black)).foregroundColor(.orange)
                VStack(spacing: 0) {
                    ForEach(table, id: \.self) { row in
                        HStack {
                            let cols = row.components(separatedBy: "|")
                            ForEach(cols, id: \.self) { col in
                                // ИСПРАВЛЕННЫЙ МЕТОД ТУТ: trimmingCharacters
                                Text(col.trimmingCharacters(in: .whitespaces))
                                    .font(.system(size: 13))
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                        }
                        .padding(.vertical, 10)
                        Divider().background(Color.white.opacity(0.1))
                    }
                }
                .padding().background(Color.white.opacity(0.05)).cornerRadius(12)
            }
        }
    }

    private func exampleBlock(_ info: SavedDeepGrammar) -> some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("ПРИМЕРЫ").font(.system(size: 12, weight: .black)).foregroundColor(.green)
            let examples = info.isDetailedMode ? (info.examplesDeep ?? []) : info.examplesBrief
            ForEach(examples, id: \.self) { ex in
                InteractiveTextView(text: ex) { word in
                    self.lookupItem = WordLookupItem(word: word)
                }
                .padding().background(Color.green.opacity(0.1)).cornerRadius(12)
            }
        }
    }

    // MARK: - Логика
    
    func toggleMode() {
        guard let info = current else { return }
        if info.isDetailedMode {
            info.isDetailedMode = false
        } else {
            if info.theoryDeep == nil {
                loadDetailedVersion(info)
            } else {
                info.isDetailedMode = true
            }
        }
    }

    func loadInitialBrief() {
        isLoading = true
        Task {
            do {
                let res = try await gemini.fetchDeepGrammar(topic: topic, isExtraDetailed: false)
                await MainActor.run {
                    let newRecord = SavedDeepGrammar(topic: topic, theoryBrief: res.theory, nuancesBrief: res.nuances, examplesBrief: res.manyExamples)
                    context.insert(newRecord)
                    isLoading = false
                }
            } catch { await MainActor.run { isLoading = false } }
        }
    }

    func loadDetailedVersion(_ info: SavedDeepGrammar) {
        isLoading = true
        Task {
            do {
                let res = try await gemini.fetchDeepGrammar(topic: topic, isExtraDetailed: true)
                await MainActor.run {
                    info.theoryDeep = res.theory
                    info.nuancesDeep = res.nuances
                    info.tableDeep = res.table
                    info.examplesDeep = res.manyExamples
                    info.isDetailedMode = true
                    isLoading = false
                }
            } catch { await MainActor.run { isLoading = false } }
        }
    }
}
