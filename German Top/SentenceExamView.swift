import SwiftUI

struct SentenceExamView: View {
    @Environment(\.isTabBarHidden) var isTabBarHidden
    @Environment(\.dismiss) var dismiss
    let words: [GermanWord]
    @State private var index = 0
    @State private var russian = "Генерация..."
    @State private var input = ""
    @State private var feedback: SentenceVerification?
    @State private var loading = false
    @State private var lookup: WordLookupItem?
    private let gemini = GeminiService()

    var body: some View {
        ZStack(alignment: .bottom) {
            GermanColors.deepBlack.ignoresSafeArea()
            VStack(spacing: 0) {
                if index < words.count {
                    ScrollView {
                        VStack(spacing: 25) {
                            VStack(alignment: .leading, spacing: 10) {
                                Text("ПЕРЕВЕДИТЕ:").font(.system(size: 11, weight: .black)).foregroundColor(.gray)
                                InteractiveTextView(text: russian) { lookup = WordLookupItem(word: $0) }
                            }.padding(20).frame(maxWidth: .infinity, alignment: .leading).background(GermanColors.darkCardBG).cornerRadius(20)
                            TextField("Ваш перевод...", text: $input, axis: .vertical).textFieldStyle(.plain).padding().background(Color(white: 0.15)).cornerRadius(12).foregroundColor(.white).lineLimit(3...5)
                                .onChange(of: input) { if feedback != nil { feedback = nil } }
                            if let f = feedback {
                                VStack(alignment: .leading, spacing: 15) {
                                    HStack { Image(systemName: f.isCorrect ? "checkmark.circle.fill" : "exclamationmark.triangle.fill"); Text(f.isCorrect ? "ВЕРНО" : "ОШИБКА").font(.system(size: 14, weight: .black)) }.foregroundColor(f.isCorrect ? .green : .red)
                                    Text(f.feedback).foregroundColor(.white)
                                    if let c = f.correctedVersion { Divider(); InteractiveTextView(text: c) { lookup = WordLookupItem(word: $0) } }
                                }.padding(20).background(f.isCorrect ? Color.green.opacity(0.1) : Color.red.opacity(0.1)).cornerRadius(20)
                            }
                            Spacer(minLength: 120)
                        }.padding()
                    }
                } else {
                    VStack(spacing: 20) { Text("🎉").font(.system(size: 80)); Text("Блок завершен!").font(.title).bold(); Button("ЗАКОНЧИТЬ") { dismiss() }.buttonStyle(.borderedProminent) }.frame(maxHeight: .infinity)
                }
            }
            if index < words.count {
                VStack {
                    Divider().background(Color.white.opacity(0.1))
                    HStack(spacing: 15) {
                        Button { next() } label: { Image(systemName: "forward.fill").font(.title2).foregroundColor(.white).frame(width: 56, height: 56).background(Color.white.opacity(0.1)).clipShape(Circle()) }
                        Button(action: { if feedback?.isCorrect == true { next() } else { verify() } }) {
                            HStack { if loading { ProgressView().tint(.white) } else { Text(feedback?.isCorrect == true ? "ДАЛЕЕ" : "ПРОВЕРИТЬ ИИ").font(.system(size: 16, weight: .black)) } }
                            .frame(maxWidth: .infinity).frame(height: 56).background(input.isEmpty ? Color.gray.opacity(0.3) : (feedback?.isCorrect == true ? Color.green : Color.blue)).foregroundColor(.white).cornerRadius(28)
                        }.disabled(input.trimmingCharacters(in: .whitespaces).isEmpty || loading)
                    }.padding(.horizontal, 20).padding(.vertical, 15).background(GermanColors.deepBlack)
                }
            }
        }
        .onAppear { isTabBarHidden.wrappedValue = true; load() }
        .onDisappear { isTabBarHidden.wrappedValue = false }
        .sheet(item: $lookup) { QuickAddWordView(wordToSearch: $0.word) }
    }
    func load() { loading = true; Task { russian = try await gemini.generateSentence(for: words[index]); loading = false } }
    func verify() { loading = true; Task { feedback = try await gemini.verifyTranslation(userText: input, russianSentence: russian, targetWord: words[index].original); loading = false } }
    func next() { index += 1; input = ""; feedback = nil; if index < words.count { load() } }
}
