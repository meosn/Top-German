import SwiftUI

struct WordDetailView: View {
    // Параметры по умолчанию позволяют вызывать вью гибко
    var word: GermanWord? = nil
    var dto: WordDTO? = nil
    
    @Environment(\.dismiss) var dismiss
    @State private var showManual = false
    @State private var showAI = false

    // MARK: - Вычисляемые свойства (выбирают данные из word или dto)
    
    private var original: String { word?.original ?? dto?.original ?? "" }
    private var translation: String { word?.translation ?? dto?.translation ?? "" }
    private var gender: String { word?.gender ?? dto?.gender ?? "" }
    private var wordType: String { word?.wordType ?? dto?.wordType ?? "" }
    
    // Очистка управления (Rektion) от лингвистического мусора
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
            // Фон всего экрана (глубокий черный)
            GermanColors.deepBlack.ignoresSafeArea()
            
            ScrollView {
                VStack(alignment: .leading, spacing: 25) {
                    
                    // 1. ГЛАВНАЯ КАРТОЧКА (Дизайн как на фото)
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

                    // 2. СЕКЦИЯ: ФОРМЫ ГЛАГОЛА (Только если это глагол или есть формы)
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

                    // 3. СЕКЦИЯ: МНОЖЕСТВЕННОЕ ЧИСЛО
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

                    // 4. СЕКЦИЯ: УПРАВЛЕНИЕ (Стиль Badge)
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

                    // 5. СЕКЦИЯ: ПРИМЕРЫ (С разделителями)
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
                    
                    // Отступ внизу для плавающего меню
                    Spacer(minLength: 150)
                }
                .padding()
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            // Кнопка закрытия
            ToolbarItem(placement: .topBarLeading) {
                Button("Закрыть") { dismiss() }
            }
            
            // Кнопка изменения (показывается только для слов из базы)
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
        // Экран ручной правки
        .sheet(isPresented: $showManual) {
            if let w = word { ManualEditView(word: w) }
        }
        // Экран обновления через ИИ
        .sheet(isPresented: $showAI) {
            if let w = word { AddWordView(editWord: w) }
        }
    }

    // Вспомогательная функция для строк глагола
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
