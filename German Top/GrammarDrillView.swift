import SwiftUI

enum GrammarMode { case gender, plural, verbForms, rektion }

struct GrammarDrillView: View {
    @Environment(\.isTabBarHidden) var isTabBarHidden
    @Environment(\.dismiss) var dismiss
    let mode: GrammarMode
    let words: [GermanWord]
    
    @State private var index = 0
    @State private var input = ""
    @State private var result: Bool?
    @State private var selectedWord: GermanWord?

    var body: some View {
        ZStack(alignment: .bottom) {
            GermanColors.deepBlack.ignoresSafeArea()
            VStack {
                if index < words.count {
                    ScrollView {
                        VStack(spacing: 30) {
                            let word = words[index]
                            VStack(spacing: 15) {
                                Text(modeTitle).font(.system(size: 11, weight: .black)).foregroundColor(.gray)
                                Text(word.original).font(.system(size: 45, weight: .bold)).foregroundColor(.white)
                                Text(word.translation).font(.title3).foregroundColor(.gray)
                            }.padding(40).frame(maxWidth: .infinity).background(GermanColors.darkCardBG).cornerRadius(25)

                            if mode == .gender {
                                HStack(spacing: 20) {
                                    ForEach(["der", "die", "das"], id: \.self) { g in
                                        Button(g) { check(g) }.font(.headline).frame(width: 90, height: 60).background(GermanColors.colorForGender(g)).foregroundColor(.white).cornerRadius(15)
                                    }
                                }
                            } else {
                                TextField("Ответ...", text: $input).textFieldStyle(.plain).padding().background(Color(white: 0.15)).cornerRadius(12).foregroundColor(.white).autocorrectionDisabled()
                            }

                            if let res = result {
                                VStack(spacing: 10) {
                                    Text(res ? "✅ ВЕРНО" : "❌ ОШИБКА").font(.headline).foregroundColor(res ? .green : .red)
                                    if !res { Text(correctAnswer).font(.title2).bold().foregroundColor(.white) }
                                }.padding().frame(maxWidth: .infinity).background(Color.white.opacity(0.05)).cornerRadius(15)
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
        .sheet(item: $selectedWord) { word in
            NavigationStack {
                WordDetailView(word: word)
            }
        }
    }

    private var bottomBar: some View {
        VStack {
            Divider().background(Color.white.opacity(0.1))
            HStack(spacing: 15) {
                Button { next() } label: { Image(systemName: "forward.fill").font(.title2).foregroundColor(.white).frame(width: 56, height: 56).background(Color.white.opacity(0.1)).clipShape(Circle()) }
                Button { selectedWord = words[index] } label: { Image(systemName: "info.circle").font(.title2).foregroundColor(.white).frame(width: 56, height: 56).background(Color.white.opacity(0.1)).clipShape(Circle()) }
                Button(action: { if result != nil { next() } else { check(input) } }) {
                    Text(result != nil ? "ДАЛЕЕ" : "ПРОВЕРИТЬ").font(.system(size: 16, weight: .black)).frame(maxWidth: .infinity).frame(height: 56).background(mode != .gender && input.isEmpty && result == nil ? Color.gray.opacity(0.3) : (result != nil ? Color.green : Color.blue)).foregroundColor(.white).cornerRadius(28)
                }.disabled(mode != .gender && input.isEmpty && result == nil)
            }.padding(.horizontal, 20).padding(.vertical, 15).background(GermanColors.deepBlack)
        }
    }

    private var completionView: some View {
        VStack(spacing: 20) { Text("🎉").font(.system(size: 80)); Text("Готово!").foregroundColor(.white); Button("ЗАКОНЧИТЬ") { dismiss() }.buttonStyle(.borderedProminent) }.frame(maxHeight: .infinity)
    }

    var modeTitle: String {
        switch mode { case .gender: return "РОД:"; case .plural: return "PLURAL:"; case .verbForms: return "PERFEKT:"; case .rektion: return "УПРАВЛЕНИЕ:" }
    }
    var correctAnswer: String {
        guard index < words.count else { return "" }
        switch mode { case .gender: return words[index].gender ?? ""; case .plural: return words[index].plural ?? ""; case .verbForms: return words[index].perfekt ?? ""; case .rektion: return words[index].rektion ?? "" }
    }
    func check(_ v: String) { if result == nil { result = GermanWord.normalized(v).contains(GermanWord.normalized(correctAnswer)) } }
    func next() { index += 1; input = ""; result = nil }
}
