import SwiftUI
import SwiftData

struct TrainingView: View {
    @Query var words: [GermanWord]
    var wordBlocks: [[GermanWord]] { words.chunked(into: 10) }

    var body: some View {
        NavigationStack {
            ZStack {
                GermanColors.deepBlack.ignoresSafeArea()
                ScrollView {
                    VStack(spacing: 25) {
                        let mastered = words.filter { $0.correctCount >= 5 }.count
                        ProgressView(value: Double(mastered), total: Double(max(1, words.count))) {
                            Text("Изучено: \(mastered) / \(words.count)").foregroundColor(.white).font(.headline)
                        }.tint(.green).padding().background(GermanColors.darkCardBG).cornerRadius(15)

                        VStack(alignment: .leading, spacing: 15) {
                            Text("Блоки по 10 слов").font(.title3).bold().foregroundColor(.gray)
                            ForEach(0..<wordBlocks.count, id: \.self) { i in
                                NavigationLink(destination: TrainingModePicker(words: wordBlocks[i])) {
                                    HStack {
                                        Text("Блок \(i+1)").font(.headline)
                                        Spacer(); Text("\(wordBlocks[i].count) слов").foregroundColor(.gray)
                                        Image(systemName: "chevron.right").foregroundColor(.gray)
                                    }.padding().background(GermanColors.darkCardBG).cornerRadius(15)
                                }.buttonStyle(.plain)
                            }
                        }
                    }.padding()
                }
            }.navigationTitle("Тренировка")
        }
    }
}

struct TrainingModePicker: View {
    let words: [GermanWord]
    var body: some View {
        List {
            Section("Интеллектуальные") {
                NavigationLink("Перевод предложений (ИИ)") { SentenceExamView(words: words) }
                NavigationLink("Карточки") { FlashcardsView(words: words) }
                NavigationLink("Синонимы (ИИ)") { SynonymExamView(words: words) }
                NavigationLink("Письмо") { WritingExamView(words: words) }
            }
            Section("Грамматика") {
                NavigationLink("Род (der/die/das)") { GrammarDrillView(mode: .gender, words: words.filter{$0.wordType == "Noun" && $0.gender != nil}) }
                NavigationLink("Множественное число") { GrammarDrillView(mode: .plural, words: words.filter{$0.plural != nil && !$0.plural!.isEmpty}) }
                NavigationLink("Формы глагола (Perfekt)") { GrammarDrillView(mode: .verbForms, words: words.filter{$0.wordType == "Verb" && $0.perfekt != nil}) }
                NavigationLink("Управление (Rektion)") { GrammarDrillView(mode: .rektion, words: words.filter{$0.rektion != nil && !$0.rektion!.isEmpty}) }
            }
        }
        .navigationTitle("Режим")
        .preferredColorScheme(.dark)
    }
}
