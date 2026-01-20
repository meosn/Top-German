import SwiftUI

struct WordDetailView: View {
    let word: GermanWord
    @State private var showManual = false
    @State private var showAI = false

    var body: some View {
        ZStack {
            GermanColors.deepBlack.ignoresSafeArea()
            
            ScrollView {
                VStack(alignment: .leading, spacing: 25) {
                    
                    VStack(alignment: .leading, spacing: 12) {
                        HStack(alignment: .firstTextBaseline, spacing: 10) {
                            Text(word.original).font(.system(size: 38, weight: .bold)).foregroundColor(.white)
                            if let g = word.gender, !g.isEmpty {
                                Text(g).font(.title2).bold().foregroundColor(GermanColors.colorForGender(g))
                            }
                            Spacer()
                            Button { SpeechManager.shared.speak(word.original) } label: {
                                Image(systemName: "speaker.wave.3.fill").foregroundColor(.blue).font(.title2)
                            }
                        }
                        Text(word.translation).font(.title3).foregroundColor(.gray)
                    }
                    .padding(25).frame(maxWidth: .infinity, alignment: .leading)
                    .background(GermanColors.darkCardBG).cornerRadius(25)

                    if word.wordType.lowercased().contains("verb") {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Формы глагола").font(.headline).foregroundColor(.secondary).padding(.leading, 5)
                            VStack(alignment: .leading, spacing: 12) {
                                verbRow(label: "Präsens", value: word.praesens)
                                Divider().background(Color.white.opacity(0.1))
                                verbRow(label: "Präteritum", value: word.praeteritum)
                                Divider().background(Color.white.opacity(0.1))
                                verbRow(label: "Perfekt", value: word.perfekt)
                            }
                            .padding().background(GermanColors.darkCardBG).cornerRadius(15)
                        }
                    }

                    if let pl = word.plural, !pl.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Множественное число").font(.headline).foregroundColor(.secondary).padding(.leading, 5)
                            Text(pl).font(.system(size: 20, weight: .medium)).foregroundColor(.orange)
                                .padding().frame(maxWidth: .infinity, alignment: .leading)
                                .background(GermanColors.darkCardBG).cornerRadius(15)
                        }
                    }

                    if let rek = word.rektion, !rek.isEmpty {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Управление").font(.headline).foregroundColor(.secondary).padding(.leading, 5)
                            Text(rek).font(.system(size: 18, weight: .medium)).foregroundColor(.blue)
                                .padding().frame(maxWidth: .infinity, alignment: .leading)
                                .background(GermanColors.darkCardBG).cornerRadius(15)
                        }
                    }

                    if !word.examples.isEmpty {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Примеры").font(.headline).foregroundColor(.secondary).padding(.leading, 5)
                            VStack(alignment: .leading, spacing: 0) {
                                ForEach(word.examples, id: \.self) { example in
                                    Text(example).font(.system(size: 17)).italic().foregroundColor(.white).padding(.vertical, 15)
                                    if example != word.examples.last {
                                        Divider().background(Color.white.opacity(0.1))
                                    }
                                }
                            }
                            .padding(.horizontal, 20).background(GermanColors.darkCardBG).cornerRadius(22)
                        }
                    }
                    
                    Spacer(minLength: 150)
                }
                .padding()
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Menu("Изменить") {
                    Button { showManual = true } label: { Label("Вручную", systemImage: "keyboard") }
                    Button { showAI = true } label: { Label("Через ИИ", systemImage: "sparkles") }
                }
            }
        }
        .sheet(isPresented: $showManual) { ManualEditView(word: word) }
        .sheet(isPresented: $showAI) { AddWordView(editWord: word) }
    }
    
    func verbRow(label: String, value: String?) -> some View {
        HStack {
            Text(label).font(.caption).foregroundColor(.gray)
            Spacer()
            Text(value ?? "—").font(.headline).foregroundColor(.white)
        }
    }
}
