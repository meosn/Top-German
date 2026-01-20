import SwiftUI

struct SynonymExamView: View {
    @Environment(\.isTabBarHidden) var isTabBarHidden
    @Environment(\.dismiss) var dismiss
    let words: [GermanWord]
    
    @State private var index = 0
    @State private var input = ""
    @State private var feedback: SentenceVerification?
    @State private var loading = false
    @State private var hint: String?
    @State private var lookup: WordLookupItem?
    @State private var selectedWord: GermanWord?
    private let gemini = GeminiService()

    var body: some View {
        ZStack(alignment: .bottom) {
            GermanColors.deepBlack.ignoresSafeArea()
            VStack {
                if index < words.count {
                    ScrollView {
                        VStack(spacing: 25) {
                            VStack(spacing: 12) {
                                Text("СИНОНИМ К СЛОВУ:").font(.system(size: 11, weight: .black)).foregroundColor(.gray)
                                Text(words[index].original).font(.system(size: 40, weight: .bold)).foregroundColor(.white)
                                Text("(\(words[index].translation))").italic().foregroundColor(.gray)
                            }.padding(25).frame(maxWidth: .infinity).background(GermanColors.darkCardBG).cornerRadius(20)
                            
                            TextField("Введите синоним...", text: $input).textFieldStyle(.plain).padding().background(Color(white: 0.15)).cornerRadius(12).foregroundColor(.white).onChange(of: input) { feedback = nil }
                            
                            if let h = hint {
                                VStack(alignment: .leading) {
                                    Text("ПОДСКАЗКИ:").font(.caption2).bold()
                                    InteractiveTextView(text: h) { lookup = WordLookupItem(word: $0) }
                                }.padding().background(Color.blue.opacity(0.1)).cornerRadius(15)
                            }
                            
                            if let f = feedback {
                                VStack(alignment: .leading, spacing: 12) {
                                    Text(f.isCorrect ? "✅ ОТЛИЧНО" : "ПОЧТИ").foregroundColor(f.isCorrect ? .green : .orange).bold()
                                    Text(f.feedback).foregroundColor(.white)
                                    if let c = f.correctedVersion { Divider(); InteractiveTextView(text: c) { lookup = WordLookupItem(word: $0) } }
                                }.padding(20).background(Color.white.opacity(0.05)).cornerRadius(20)
                            }
                            Spacer(minLength: 120)
                        }.padding()
                    }
                } else { completionView }
            }
            if index < words.count { bottomBar }
        }
        .onAppear { isTabBarHidden.wrappedValue = true }
        .onDisappear { isTabBarHidden.wrappedValue = false }
        .sheet(item: $lookup) { QuickAddWordView(wordToSearch: $0.word) }
        .sheet(item: $selectedWord) { word in NavigationStack { WordDetailView(word: word) } }
    }

    private var bottomBar: some View {
        VStack {
            Divider().background(Color.white.opacity(0.1))
            HStack(spacing: 15) {
                Button { Task { hint = try? await gemini.fetchSynonymHint(for: words[index].original) } } label: { Image(systemName: "lightbulb.fill").font(.title2).foregroundColor(.white).frame(width: 56, height: 56).background(Color.yellow.opacity(0.2)).clipShape(Circle()) }
                Button { next() } label: { Image(systemName: "forward.fill").font(.title2).foregroundColor(.white).frame(width: 56, height: 56).background(Color.white.opacity(0.1)).clipShape(Circle()) }
                Button { selectedWord = words[index] } label: { Image(systemName: "info.circle").font(.title2).foregroundColor(.white).frame(width: 56, height: 56).background(Color.white.opacity(0.1)).clipShape(Circle()) }
                Button(action: { if feedback?.isCorrect == true { next() } else { verify() } }) {
                    HStack { if loading { ProgressView().tint(.white) } else { Text(feedback?.isCorrect == true ? "ДАЛЕЕ" : "ПРОВЕРИТЬ").font(.system(size: 16, weight: .black)) } }
                    .frame(maxWidth: .infinity).frame(height: 56).background(input.isEmpty ? Color.gray.opacity(0.3) : (feedback?.isCorrect == true ? Color.green : Color.blue)).foregroundColor(.white).cornerRadius(28)
                }.disabled(input.isEmpty || loading)
            }.padding(.horizontal, 20).padding(.vertical, 15).background(GermanColors.deepBlack)
        }
    }

    private var completionView: some View {
        VStack(spacing: 20) { Text("🧠").font(.system(size: 80)); Text("Готово!").foregroundColor(.white); Button("ЗАКОНЧИТЬ") { dismiss() }.buttonStyle(.borderedProminent) }.frame(maxHeight: .infinity)
    }

    func verify() { loading = true; Task { feedback = try? await gemini.verifySynonym(userWord: input, targetWord: words[index].original); loading = false } }
    func next() { index += 1; input = ""; feedback = nil; hint = nil }
}
