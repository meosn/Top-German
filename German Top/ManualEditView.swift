import SwiftUI

struct ManualEditView: View {
    @Environment(\.dismiss) var dismiss
    let word: GermanWord
    private let gemini = GeminiService()
    
    @State private var original = ""
    @State private var translation = ""
    @State private var wordType = "Noun"
    
    @State private var gender = ""
    @State private var plural = ""
    @State private var rektion = ""
    @State private var praesens = ""
    @State private var praeteritum = ""
    @State private var perfekt = ""
    @State private var examples: [String] = []
    
    @State private var newEx = ""
    @State private var isGen = false

    var body: some View {
        NavigationStack {
            Form {
                Section("Основное") {
                    TextField("Немецкий", text: $original)
                    TextField("Перевод", text: $translation)
                    
                    Picker("Тип слова", selection: $wordType) {
                        Text("Сущ.").tag("Noun")
                        Text("Глаг.").tag("Verb")
                        Text("Прил.").tag("Adjective")
                        Text("Фраза").tag("Phrase")
                    }
                    .pickerStyle(.segmented)
                }
                
                if wordType == "Noun" {
                    Section("Грамматика существительного") {
                        Picker("Род", selection: $gender) {
                            Text("нет").tag("")
                            Text("der").tag("der")
                            Text("die").tag("die")
                            Text("das").tag("das")
                        }.pickerStyle(.segmented)
                        
                        TextField("Множественное число", text: $plural)
                    }
                }
                
                if wordType == "Verb" {
                    Section("Формы глагола") {
                        TextField("Präsens (3. p.)", text: $praesens)
                        TextField("Präteritum (3. p.)", text: $praeteritum)
                        TextField("Perfekt (hat/ist...)", text: $perfekt)
                    }
                }
                
                if wordType != "Phrase" {
                    Section("Дополнительно") {
                        TextField("Управление (Rektion)", text: $rektion)
                    }
                }
                
                Section("Примеры") {
                    ForEach(examples, id: \.self) { Text($0).font(.caption) }.onDelete { examples.remove(atOffsets: $0) }
                    HStack {
                        TextField("Свой пример", text: $newEx)
                        Button { if !newEx.isEmpty { examples.append(newEx); newEx = "" } } label: { Image(systemName: "plus.circle") }
                    }
                    Button("Сгенерировать ИИ пример") {
                        isGen = true
                        Task {
                            if let ex = try? await gemini.generateExtraExample(for: original) {
                                await MainActor.run { examples.append(ex); isGen = false }
                            }
                        }
                    }.disabled(isGen || original.isEmpty)
                }
                
            }
            .navigationTitle("Правка")
            .toolbar { Button("Готово") { save(); dismiss() }.bold() }
            .onAppear {
                original = word.original
                translation = word.translation
                wordType = word.wordType
                gender = word.gender ?? ""
                plural = word.plural ?? ""
                rektion = word.rektion ?? ""
                praesens = word.praesens ?? ""
                praeteritum = word.praeteritum ?? ""
                perfekt = word.perfekt ?? ""
                examples = word.examples
            }
        }
    }

    func save() {
        word.original = original
        word.translation = translation
        word.wordType = wordType 
        word.gender = gender.isEmpty ? nil : gender
        word.plural = plural.isEmpty ? nil : plural
        word.rektion = rektion.isEmpty ? nil : rektion
        word.praesens = praesens.isEmpty ? nil : praesens
        word.praeteritum = praeteritum.isEmpty ? nil : praeteritum
        word.perfekt = perfekt.isEmpty ? nil : perfekt
        word.examples = examples
    }
}
