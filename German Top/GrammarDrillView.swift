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
    @FocusState private var isFieldFocused: Bool
    @State private var selectedWord: GermanWord?

    var body: some View {
        ZStack(alignment: .bottom) {
            GermanColors.deepBlack.ignoresSafeArea()
            
            VStack(spacing: 0) {
                if index < words.count {
                    ScrollView {
                        VStack(spacing: 30) {
                            let word = words[index]
                            
                            VStack(spacing: 12) {
                                Text(modeTitle).font(.system(size: 11, weight: .black)).foregroundColor(.gray)
                                Text(word.original)
                                    .font(.system(size: 40, weight: .bold)).foregroundColor(.white)
                                Text(word.translation).italic().foregroundColor(.secondary)
                            }
                            .padding(30).frame(maxWidth: .infinity).background(GermanColors.darkCardBG).cornerRadius(25)

                           
                            if mode == .gender {
                                HStack(spacing: 15) {
                                    ForEach(["der", "die", "das"], id: \.self) { g in
                                        Button(g) { check(g) }
                                            .font(.headline)
                                            .frame(width: 90, height: 60)
                                            .background(GermanColors.colorForGender(g))
                                            .foregroundColor(.white)
                                            .cornerRadius(15)
                                    }
                                }
                            } else {
                                TextField(placeholder, text: $input)
                                    .textFieldStyle(.plain).padding().background(Color(white: 0.15)).cornerRadius(12).foregroundColor(.white)
                                    .focused($isFieldFocused).autocorrectionDisabled().textInputAutocapitalization(.never)
                                    .onSubmit { check(input) }
                            }
                            
                            if let res = result {
                                VStack(spacing: 10) {
                                    Text(res ? "✅ ВЕРНО" : "❌ ОШИБКА").foregroundColor(res ? .green : .red).bold()
                                    if !res { Text(correctAnswer).font(.title2).bold().foregroundColor(.white) }
                                }
                                .padding().frame(maxWidth: .infinity).background(Color.white.opacity(0.05)).cornerRadius(15)
                            }
                        }.padding()
                    }
                } else {
                    completionView
                }
            }
            
            if index < words.count {
                bottomBar
            }
        }
        .navigationTitle("Грамматика")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear { isTabBarHidden.wrappedValue = true; if mode != .gender { isFieldFocused = true } }
        .onDisappear { isTabBarHidden.wrappedValue = false }
        .sheet(item: $selectedWord) { word in
            NavigationStack {
                WordDetailView(word: word)
                    .toolbar {
                        ToolbarItem(placement: .topBarLeading) {
                            Button("Закрыть") { selectedWord = nil }
                        }
                    }
            }
        }
    }

    var modeTitle: String {
        switch mode {
        case .gender: return "ВЫБЕРИТЕ АРТИКЛЬ:"
        case .plural: return "НАПИШИТЕ МНОЖЕСТВЕННОЕ ЧИСЛО:"
        case .verbForms: return "НАПИШИТЕ ФОРМУ PERFEKT:"
        case .rektion: return "НАПИШИТЕ УПРАВЛЕНИЕ:"
        }
    }

    var placeholder: String {
        switch mode {
        case .gender: return ""
        case .plural: return "die ..."
        case .verbForms: return "hat/ist ..."
        case .rektion: return "auf + Akk"
        }
    }

    var correctAnswer: String {
        guard index < words.count else { return "" }
        switch mode {
        case .gender: return words[index].gender ?? ""
        case .plural: return words[index].plural ?? ""
        case .verbForms: return words[index].perfekt ?? ""
        case .rektion: return words[index].rektion ?? ""
        }
    }

    func check(_ val: String) {
        if result == nil {
            result = GermanWord.normalized(val).contains(GermanWord.normalized(correctAnswer))
            if result == true { words[index].correctCount += 1 }
        }
    }

    private var bottomBar: some View {
        VStack(spacing: 0) {
            Divider().background(Color.white.opacity(0.1))
            HStack(spacing: 15) {
                Button { next() } label: {
                    Image(systemName: "forward.fill").font(.title2).foregroundColor(.white)
                        .frame(width: 56, height: 56).background(Color.white.opacity(0.1)).clipShape(Circle())
                }
                Button { selectedWord = words[index] } label: {
                    Image(systemName: "info.circle").font(.title2).foregroundColor(.white)
                        .frame(width: 56, height: 56).background(Color.white.opacity(0.1)).clipShape(Circle())
                }
                
                Button(action: {
                    if result != nil {
                        next()
                    } else if !input.isEmpty {
                        check(input)
                    }
                }) {
                    Text(result != nil ? "ДАЛЕЕ" : "ПРОВЕРИТЬ")
                        .font(.system(size: 16, weight: .black))
                        .foregroundColor(.white) 
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(
                            result == nil && input.isEmpty ? Color.gray.opacity(0.3) :
                            (result != nil ? Color.green : Color.blue)
                        )
                        .cornerRadius(28)
                }
                .disabled(mode != .gender && input.isEmpty && result == nil)
            }
            .padding(.horizontal, 20).padding(.vertical, 15).background(GermanColors.deepBlack)
        }
    }

    private var completionView: some View {
        VStack(spacing: 20) {
            Text("🎉").font(.system(size: 80))
            Text("Блок завершен!").font(.title).bold().foregroundColor(.white)
            Button("ЗАКОНЧИТЬ") { dismiss() }
                .font(.headline).foregroundColor(.white)
                .frame(width: 200, height: 56).background(Color.blue).cornerRadius(28)
        }.frame(maxHeight: .infinity)
    }

    func next() {
        index += 1; input = ""; result = nil; if index < words.count && mode != .gender { isFieldFocused = true }
    }
}
