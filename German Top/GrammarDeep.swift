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
                    ProgressView().scaleEffect(1.5).tint(.blue)
                    Text("ИИ перерабатывает материал...").foregroundColor(.gray)
                }
            } else if let info = current {
                ScrollView {
                    VStack(alignment: .leading, spacing: 25) {
                        
                        HStack(spacing: 12) {
                            Text(info.isDetailedMode ? "ГЛУБОКИЙ РАЗБОР" : "КРАТКИЙ ОБЗОР")
                                .font(.system(size: 10, weight: .black))
                                .padding(6)
                                .background(info.isDetailedMode ? Color.purple : Color.blue)
                                .cornerRadius(6)
                                .foregroundColor(.white)
                            
                            Button {
                                if info.isDetailedMode {
                                    loadDetailedVersion(info, force: true)
                                } else {
                                    updateBriefVersion(info)
                                }
                            } label: {
                                Image(systemName: "arrow.clockwise.circle.fill")
                                    .font(.title3).foregroundColor(.gray)
                            }
                            
                            Spacer()
                            
                            Button(info.isDetailedMode ? "Сжать" : "Развернуть") {
                                toggleMode(info)
                            }
                            .font(.system(size: 12, weight: .bold)).foregroundColor(.blue)
                        }

                        theoryBlock(info)
                        tableBlock(info)
                        exampleBlock(info)
                        
                        NavigationLink(destination: GrammarChatView(topic: topic)) {
                            HStack {
                                Image(systemName: "sparkles")
                                Text("Обсудить теорию с ИИ")
                            }
                            .font(.headline).foregroundColor(.white).frame(maxWidth: .infinity).padding()
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

    @ViewBuilder
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
        let tableData = info.isDetailedMode ? info.tableDeep : info.tableBrief
        if let table = tableData, !table.isEmpty {
            VStack(alignment: .leading, spacing: 10) {
                Text("ТАБЛИЦА").font(.system(size: 12, weight: .black)).foregroundColor(.orange)
                VStack(spacing: 0) {
                    ForEach(Array(table.enumerated()), id: \.offset) { i, row in
                        let isHeader = i == 0
                        HStack {
                            let cols = row.components(separatedBy: "|")
                            ForEach(cols, id: \.self) { col in
                                Text(col.trimmingCharacters(in: .whitespaces))
                                    .font(.system(size: isHeader ? 12 : 14, weight: isHeader ? .black : .medium))
                                    .foregroundColor(isHeader ? .orange : .white).frame(maxWidth: .infinity, alignment: .leading)
                            }
                        }
                        .padding(.vertical, 12).padding(.horizontal, 10)
                        .background(isHeader ? Color.orange.opacity(0.1) : Color.clear)
                        if i < table.count - 1 { Divider().background(Color.white.opacity(0.1)) }
                    }
                }.background(Color.white.opacity(0.03)).cornerRadius(12)
            }
        }
    }

    @ViewBuilder
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


    func toggleMode(_ info: SavedDeepGrammar) {
        if info.isDetailedMode { info.isDetailedMode = false }
        else {
            if info.theoryDeep == nil { loadDetailedVersion(info) }
            else { info.isDetailedMode = true }
        }
    }

    func loadInitialBrief() {
        isLoading = true
        Task {
            do {
                let res = try await gemini.fetchDeepGrammar(topic: topic, isExtraDetailed: false)
                await MainActor.run {
                    let new = SavedDeepGrammar(topic: topic, theoryBrief: res.theory, nuancesBrief: res.nuances, examplesBrief: res.manyExamples, tableBrief: res.table)
                    context.insert(new)
                    isLoading = false
                }
            } catch { isLoading = false }
        }
    }
    func updateBriefVersion(_ info: SavedDeepGrammar) {
        isLoading = true
        Task {
            do {
                let res = try await gemini.fetchDeepGrammar(topic: topic, isExtraDetailed: false)
                await MainActor.run {
                    info.theoryBrief = res.theory
                    info.nuancesBrief = res.nuances
                    info.examplesBrief = res.manyExamples
                    info.tableBrief = res.table
                    try? context.save()
                    isLoading = false
                }
            } catch { isLoading = false }
        }
    }

    func loadDetailedVersion(_ info: SavedDeepGrammar, force: Bool = false) {
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
                    try? context.save()
                    isLoading = false
                }
            } catch { isLoading = false }
        }
    }
}
