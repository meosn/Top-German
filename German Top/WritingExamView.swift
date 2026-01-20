import SwiftUI
import SwiftData

struct WritingExamView: View {
    @Environment(\.isTabBarHidden) var isTabBarHidden
    @Environment(\.dismiss) var dismiss
    let words: [GermanWord]
    
    @State private var index = 0
    @State private var input = ""
    @State private var showRes = false
    @State private var selected: GermanWord?
    @FocusState private var isFieldFocused: Bool

    var body: some View {
        ZStack(alignment: .bottom) {
            GermanColors.deepBlack.ignoresSafeArea()
            
            VStack(spacing: 0) {
                if index < words.count {
                    ScrollView {
                        VStack(spacing: 30) {
                            VStack(spacing: 12) {
                                Text("ПЕРЕВЕДИТЕ НА НЕМЕЦКИЙ:")
                                    .font(.system(size: 11, weight: .black))
                                    .foregroundColor(.gray)
                                
                                Text(words[index].translation)
                                    .font(.system(size: 32, weight: .bold))
                                    .foregroundColor(.white)
                                    .multilineTextAlignment(.center)
                            }
                            .padding(30)
                            .frame(maxWidth: .infinity)
                            .background(GermanColors.darkCardBG)
                            .cornerRadius(20)

                            VStack(alignment: .leading, spacing: 8) {
                                Text("ВАШ ВАРИАНТ (С АРТИКЛЕМ ДЛЯ СУЩ.):")
                                    .font(.system(size: 11, weight: .black))
                                    .foregroundColor(.gray)
                                
                                TextField("Введите слово...", text: $input)
                                    .textFieldStyle(.plain)
                                    .padding()
                                    .background(Color(white: 0.15))
                                    .cornerRadius(12)
                                    .foregroundColor(.white)
                                    .focused($isFieldFocused)
                                    .autocorrectionDisabled()
                                    .textInputAutocapitalization(.never)
                            }
                            
                            if showRes {
                                let target = getTarget()
                                let ok = GermanWord.normalized(input) == GermanWord.normalized(target)
                                
                                VStack(spacing: 10) {
                                    Text(ok ? "✅ ВЕРНО" : "❌ ОШИБКА")
                                        .font(.system(size: 14, weight: .black))
                                        .foregroundColor(ok ? .green : .red)
                                    
                                    Text(target)
                                        .font(.title2)
                                        .bold()
                                        .foregroundColor(.white)
                                }
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.white.opacity(0.05))
                                .cornerRadius(15)
                                .transition(.move(edge: .top).combined(with: .opacity))
                            }
                        }
                        .padding()
                    }
                } else {
                    VStack(spacing: 20) {
                        Text("🎉").font(.system(size: 80))
                        Text("Блок завершен!").font(.title).bold().foregroundColor(.white)
                        Button(action: { dismiss() }) {
                            Text("ЗАКОНЧИТЬ")
                                .font(.system(size: 16, weight: .black))
                                .foregroundColor(.white)
                                .frame(width: 200, height: 56)
                                .background(Color.blue)
                                .cornerRadius(28)
                        }
                    }
                    .frame(maxHeight: .infinity)
                }
            }
            
            if index < words.count {
                VStack(spacing: 0) {
                    Divider().background(Color.white.opacity(0.1))
                    
                    HStack(spacing: 15) {
                        Button {
                            next()
                        } label: {
                            Image(systemName: "forward.fill")
                                .font(.title2)
                                .foregroundColor(.white)
                                .frame(width: 56, height: 56)
                                .background(Color.white.opacity(0.1))
                                .clipShape(Circle())
                        }
                        
                        Button {
                            selected = words[index]
                        } label: {
                            Image(systemName: "info.circle")
                                .font(.title2)
                                .foregroundColor(.white)
                                .frame(width: 56, height: 56)
                                .background(Color.white.opacity(0.1))
                                .clipShape(Circle())
                        }

                        Button(action: {
                            if showRes {
                                next()
                            } else {
                                showRes = true
                            }
                        }) {
                            Text(showRes ? "ДАЛЕЕ" : "ПРОВЕРИТЬ")
                                .font(.system(size: 16, weight: .black))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 56)
                                .background(input.isEmpty ? Color.gray.opacity(0.3) : (showRes ? Color.green : Color.blue))
                                .cornerRadius(28)
                        }
                        .disabled(input.isEmpty && !showRes)
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 15)
                    .background(GermanColors.deepBlack)
                }
            }
        }
        .navigationTitle("Письмо")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            isTabBarHidden.wrappedValue = true
            isFieldFocused = true
        }
        .onDisappear {
            isTabBarHidden.wrappedValue = false
        }
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

    func getTarget() -> String {
        let w = words[index]
        if w.wordType == "Noun", let g = w.gender, !g.isEmpty {
            return "\(g) \(w.original)"
        }
        return w.original
    }

    func next() {
        index += 1
        input = ""
        showRes = false
        if index < words.count {
            isFieldFocused = true
        }
    }
}
