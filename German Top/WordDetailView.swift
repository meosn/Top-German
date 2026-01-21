import SwiftUI

struct WordDetailView: View {
    var word: GermanWord? = nil
    var dto: WordDTO? = nil
    
    @Environment(\.dismiss) var dismiss
    @State private var showManual = false
    @State private var showAI = false

    
    private var original: String { word?.original ?? dto?.original ?? "" }
    private var translation: String { word?.translation ?? dto?.translation ?? "" }
    private var gender: String { word?.gender ?? dto?.gender ?? "" }
    private var wordType: String { word?.wordType ?? dto?.wordType ?? "" }
    
    private var rektion: String {
        let r = word?.rektion ?? dto?.rektion ?? ""
        let junk = ["intransitive", "transitive", "refl", "—", "none"]
        if junk.contains(where: { r.lowercased().contains($0) }) {
            return ""
        }
        return r
    }
    
    private var plural: String { word?.plural ?? dto?.plural ?? "" }
    private var praesens: String { word?.praesens ?? dto?.praesens ?? "" }
    private var praeteritum: String { word?.praeteritum ?? dto?.praeteritum ?? "" }
    private var perfekt: String { word?.perfekt ?? dto?.perfekt ?? "" }
    private var examples: [String] { word?.examples ?? dto?.examples ?? [] }

    var body: some View {
        ZStack {
            GermanColors.deepBlack.ignoresSafeArea()
            
            ScrollView {
                VStack(alignment: .leading, spacing: 25) {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack(alignment: .firstTextBaseline, spacing: 10) {
                            Text(original)
                                .font(.system(size: 38, weight: .bold))
                                .foregroundColor(.white)
                            
                            if !gender.isEmpty {
                                Text(gender)
                                    .font(.title2)
                                    .bold()
                                    .foregroundColor(GermanColors.colorForGender(gender))
                            }
                            
                            Spacer()
                            
                            Button {
                                SpeechManager.shared.speak(original)
                            } label: {
                                Image(systemName: "speaker.wave.3.fill")
                                    .foregroundColor(.blue)
                                    .font(.title2)
                            }
                        }
                        
                        Text(translation)
                            .font(.title3)
                            .foregroundColor(.gray)
                    }
                    .padding(25)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(GermanColors.darkCardBG)
                    .cornerRadius(25)

                    if wordType.lowercased().contains("verb") || !perfekt.isEmpty {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Формы глагола").font(.headline).foregroundColor(.secondary).padding(.leading, 5)
                            VStack(alignment: .leading, spacing: 12) {
                                verbFormRow(label: "Präsens (3. p.)", value: praesens)
                                Divider().background(Color.white.opacity(0.1))
                                verbFormRow(label: "Präteritum (3. p.)", value: praeteritum)
                                Divider().background(Color.white.opacity(0.1))
                                verbFormRow(label: "Perfekt", value: perfekt)
                            }
                            .padding()
                            .background(GermanColors.darkCardBG)
                            .cornerRadius(18)
                        }
                    }
                    if !plural.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Множественное число").font(.headline).foregroundColor(.secondary).padding(.leading, 5)
                            Text(plural)
                                .font(.system(size: 20, weight: .medium))
                                .foregroundColor(.orange)
                                .padding()
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(GermanColors.darkCardBG)
                                .cornerRadius(15)
                        }
                    }
                    if !rektion.isEmpty {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Управление").font(.headline).foregroundColor(.secondary).padding(.leading, 5)
                            HStack {
                                Image(systemName: "link")
                                    .font(.system(size: 18, weight: .bold))
                                Text(rektion)
                                    .font(.system(size: 20, weight: .bold, design: .rounded))
                            }
                            .foregroundColor(.blue)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 15)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color.blue.opacity(0.1))
                            .cornerRadius(15)
                            .overlay(
                                RoundedRectangle(cornerRadius: 15)
                                    .stroke(Color.blue.opacity(0.3), lineWidth: 1)
                            )
                        }
                    }
                    if !examples.isEmpty {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Примеры").font(.headline).foregroundColor(.secondary).padding(.leading, 5)
                            VStack(alignment: .leading, spacing: 0) {
                                ForEach(examples, id: \.self) { ex in
                                    Text(ex)
                                        .font(.system(size: 17))
                                        .italic()
                                        .foregroundColor(.white)
                                        .padding(.vertical, 15)
                                    
                                    if ex != examples.last {
                                        Divider().background(Color.white.opacity(0.1))
                                    }
                                }
                            }
                            .padding(.horizontal, 20)
                            .background(GermanColors.darkCardBG)
                            .cornerRadius(22)
                        }
                    }
                    Spacer(minLength: 150)
                }
                .padding()
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button("Закрыть") { dismiss() }
            }
            if let w = word {
                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        Button { showManual = true } label: {
                            Label("Вручную", systemImage: "keyboard")
                        }
                        Button { showAI = true } label: {
                            Label("Через ИИ", systemImage: "sparkles")
                        }
                    } label: {
                        Text("Изменить").bold()
                    }
                }
            }
        }
        .sheet(isPresented: $showManual) {
            if let w = word { ManualEditView(word: w) }
        }
        .sheet(isPresented: $showAI) {
            if let w = word { AddWordView(editWord: w) }
        }
    }

    private func verbFormRow(label: String, value: String) -> some View {
        HStack {
            Text(label).font(.caption).foregroundColor(.gray)
            Spacer()
            Text(value.isEmpty ? "—" : value)
                .font(.headline)
                .foregroundColor(.white)
        }
    }
}
