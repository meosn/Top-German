import SwiftUI

enum FlashcardDirection { case left, right }

struct FlashcardsView: View {
    @Environment(\.isTabBarHidden) var isTabBarHidden
    let words: [GermanWord]
    
    @State private var wordStack: [GermanWord] = []
    @State private var swipedHistory: [GermanWord] = []
    @State private var selectedWord: GermanWord?

    var body: some View {
        ZStack {
            GermanColors.deepBlack.ignoresSafeArea()
            
            if wordStack.isEmpty && swipedHistory.isEmpty {
                ProgressView().onAppear(perform: startSession)
            } else if wordStack.isEmpty {
                completionView
            } else {
                ZStack {
                    ForEach(wordStack, id: \.id) { word in
                        FlashcardItem(
                            word: word,
                            onRemove: { dir in removeCard(word: word, dir: dir) },
                            onShowDetail: { selectedWord = word }
                        )
                        .applyStackingEffect(at: getIndex(for: word), in: wordStack.count)
                    }
                }
            }
        }
        .navigationTitle("Карточки")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear { isTabBarHidden.wrappedValue = true }
        .onDisappear { isTabBarHidden.wrappedValue = false }
        .sheet(item: $selectedWord) { word in
            NavigationStack { WordDetailView(word: word) }
        }
    }

    private var completionView: some View {
        VStack(spacing: 20) {
            Text("🎉").font(.system(size: 80))
            Text("Блок пройден!").font(.title2).bold().foregroundColor(.white)
            Button("ЗАНОВО") { withAnimation { startSession() } }
                .font(.headline).foregroundColor(.white).frame(width: 200, height: 56).background(Color.blue).cornerRadius(28)
        }
    }


    private func startSession() { wordStack = words.shuffled(); swipedHistory = [] }
    private func getIndex(for word: GermanWord) -> Int { wordStack.firstIndex(where: { $0.id == word.id }) ?? 0 }
    private func removeCard(word: GermanWord, dir: FlashcardDirection) {
        withAnimation(.spring()) {
            if dir == .right { word.correctCount += 1 } else { word.wrongCount += 1 }
            swipedHistory.append(word)
            wordStack.removeAll { $0.id == word.id }
        }
    }
    private func undoSwipe() {
        guard let last = swipedHistory.popLast() else { return }
        withAnimation(.spring()) { wordStack.append(last) }
    }
}

struct FlashcardItem: View {
    let word: GermanWord; var onRemove: (FlashcardDirection) -> Void; var onShowDetail: () -> Void
    @State private var offset = CGSize.zero; @State private var flipped = false
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 30).fill(GermanColors.darkCardBG)
                .overlay(RoundedRectangle(cornerRadius: 30).stroke(offset.width > 0 ? Color.green : (offset.width < 0 ? Color.red : Color.clear), lineWidth: 3).opacity(Double(abs(offset.width) / 150)))
            VStack {
                HStack {
                    Button { SpeechManager.shared.speak(word.original) } label: { Image(systemName: "speaker.wave.3.fill") }
                    Spacer()
                    Button { onShowDetail() } label: { Image(systemName: "info.circle.fill") }
                }.font(.title2).foregroundColor(.blue).padding(25)
                Spacer()
                VStack(spacing: 15) {
                    Text(flipped ? word.translation : word.original).font(.system(size: 32, weight: .bold)).foregroundColor(.white).multilineTextAlignment(.center)
                    if !flipped, let g = word.gender { Text(g).font(.headline).foregroundColor(GermanColors.colorForGender(g)) }
                }.rotation3DEffect(.degrees(flipped ? 180 : 0), axis: (x: 0, y: 1, z: 0))
                Spacer(); Text(flipped ? "ПЕРЕВОД" : "ОРИГИНАЛ").font(.system(size: 10, weight: .black)).foregroundColor(.gray.opacity(0.4)).padding(.bottom, 25)
            }
        }.rotation3DEffect(.degrees(flipped ? 180 : 0), axis: (x: 0, y: 1, z: 0))
        .padding().offset(x: offset.width, y: offset.height * 0.4).rotationEffect(.degrees(Double(offset.width / 15)))
        .gesture(DragGesture().onChanged { offset = $0.translation }.onEnded { _ in if abs(offset.width) > 150 { onRemove(offset.width > 0 ? .right : .left) } else { withAnimation { offset = .zero } } })
        .onTapGesture { withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) { flipped.toggle() } }
    }
}

extension View {
    func applyStackingEffect(at pos: Int, in total: Int) -> some View {
        let off = Double(total - pos); return self.offset(y: off * 8).scaleEffect(1.0 - (off * 0.03)).zIndex(Double(pos))
    }
}
