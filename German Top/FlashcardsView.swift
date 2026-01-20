import SwiftUI
import SwiftData

enum SwipeDirection { case left, right }

struct FlashcardsView: View {
    @Environment(\.isTabBarHidden) var isTabBarHidden
    @Environment(\.dismiss) var dismiss
    let words: [GermanWord]
    
    @State private var wordStack: [GermanWord] = []
    @State private var history: [GermanWord] = []
    @State private var selected: GermanWord?

    var body: some View {
        ZStack {
            GermanColors.deepBlack.ignoresSafeArea()
            
            if wordStack.isEmpty && history.isEmpty {
                ProgressView()
            } else if wordStack.isEmpty {
                completionView
            } else {
                cardStackView
            }
        }
        .navigationTitle("Карточки")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear(perform: setupSession)
        .onDisappear { isTabBarHidden.wrappedValue = false }
        .sheet(item: $selected) { word in
            NavigationStack {
                WordDetailView(word: word)
                    .toolbar {
                        ToolbarItem(placement: .topBarLeading) {
                            Button("Закрыть") { selected = nil }
                        }
                    }
            }
        }
    }

    private var completionView: some View {
        VStack(spacing: 20) {
            Text("🎉").font(.system(size: 80))
            Text("Блок пройден!").font(.title2).bold().foregroundColor(.white)
            Button(action: { withAnimation { setupSession() } }) {
                Text("ЗАНОВО")
                    .font(.system(size: 16, weight: .black))
                    .foregroundColor(.white)
                    .frame(width: 200, height: 56)
                    .background(Color.blue)
                    .cornerRadius(28)
            }
        }
    }

    private var cardStackView: some View {
        ZStack {
            ForEach(wordStack, id: \.id) { word in
                CardView(
                    word: word,
                    onRemove: { dir in handleRemove(word: word, direction: dir) },
                    onShowDetail: { selected = word }
                )
                .stacked(at: getIndex(for: word), in: wordStack.count)
            }
            
            undoButtonView
        }
    }

    private var undoButtonView: some View {
        VStack {
            Spacer()
            if !history.isEmpty {
                Button(action: handleUndo) {
                    Label("ВЕРНУТЬ КАРТОЧКУ", systemImage: "arrow.uturn.backward.circle.fill")
                        .font(.system(size: 13, weight: .bold))
                        .padding(.horizontal, 20)
                        .padding(.vertical, 12)
                        .background(.ultraThinMaterial)
                        .foregroundColor(.white)
                        .cornerRadius(25)
                }
                .padding(.bottom, 30)
            }
        }
    }

    private func setupSession() {
        isTabBarHidden.wrappedValue = true
        wordStack = words.shuffled()
        history = []
    }

    private func getIndex(for word: GermanWord) -> Int {
        wordStack.firstIndex(where: { $0.id == word.id }) ?? 0
    }

    private func handleRemove(word: GermanWord, direction: SwipeDirection) {
        withAnimation(.spring()) {
            if direction == .right {
                word.correctCount += 1
            } else {
                word.wrongCount += 1
            }
            history.append(word)
            wordStack.removeAll { $0.id == word.id }
        }
    }

    private func handleUndo() {
        guard let last = history.popLast() else { return }
        withAnimation(.spring()) {
            wordStack.append(last)
        }
    }
}

struct CardView: View {
    let word: GermanWord
    var onRemove: (SwipeDirection) -> Void
    var onShowDetail: () -> Void
    
    @State private var offset = CGSize.zero
    @State private var flipped = false
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 30)
                .fill(GermanColors.darkCardBG)
                .overlay(
                    RoundedRectangle(cornerRadius: 30)
                        .stroke(offset.width > 0 ? Color.green : (offset.width < 0 ? Color.red : Color.clear), lineWidth: 3)
                        .opacity(Double(abs(offset.width) / 150))
                )
            
            VStack {
                HStack {
                    Button { SpeechManager.shared.speak(word.original) } label: {
                        Image(systemName: "speaker.wave.3.fill")
                            .font(.title2).foregroundColor(.blue)
                    }
                    Spacer()
                    Button(action: onShowDetail) {
                        Image(systemName: "info.circle.fill")
                            .font(.title2).foregroundColor(.gray)
                    }
                }
                .padding(25)
                
                Spacer()
                
                VStack(spacing: 15) {
                    Text(flipped ? word.translation : word.original)
                        .font(.system(size: 30, weight: .bold))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    
                    if !flipped, let g = word.gender, !g.isEmpty {
                        Text(g)
                            .font(.headline)
                            .foregroundColor(GermanColors.colorForGender(g))
                    }
                }
                .rotation3DEffect(.degrees(flipped ? 180 : 0), axis: (x: 0, y: 1, z: 0))
                
                Spacer()
                
                Text(flipped ? "ПЕРЕВОД" : "ОРИГИНАЛ")
                    .font(.system(size: 10, weight: .black))
                    .foregroundColor(.gray.opacity(0.4))
                    .padding(.bottom, 25)
            }
        }
        .rotation3DEffect(.degrees(flipped ? 180 : 0), axis: (x: 0, y: 1, z: 0))
        .offset(x: offset.width, y: offset.height * 0.4)
        .rotationEffect(.degrees(Double(offset.width / 15)))
        .gesture(
            DragGesture()
                .onChanged { offset = $0.translation }
                .onEnded { value in
                    if offset.width > 150 { onRemove(.right) }
                    else if offset.width < -150 { onRemove(.left) }
                    else { withAnimation(.spring()) { offset = .zero } }
                }
        )
        .onTapGesture {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
                flipped.toggle()
            }
        }
    }
}


extension View {
    func stacked(at position: Int, in total: Int) -> some View {
        let offsetValue = Double(total - position)
        return self.offset(y: offsetValue * 8)
            .scaleEffect(1.0 - (offsetValue * 0.03))
            .zIndex(Double(position))
    }
}
