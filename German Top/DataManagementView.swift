import SwiftUI
import SwiftData
internal import UniformTypeIdentifiers

struct DataManagementView: View {
    @Environment(\.modelContext) private var context
    @Query var allWords: [GermanWord]
    
    @State private var exportURL: URL?
    @State private var isFilePresented = false
    @State private var alertMsg = ""
    @State private var isAlertPresented = false

    var body: some View {
        NavigationStack {
            ZStack {
                GermanColors.deepBlack.ignoresSafeArea()
                
                List {
                    Section {
                        Button {
                            exportJSON()
                        } label: {
                            Label("Экспорт в JSON", systemImage: "doc.badge.arrow.up")
                                .foregroundColor(.blue)
                        }
                    } header: {
                        Text("Бэкап").foregroundColor(.gray)
                    }
                    .listRowBackground(GermanColors.darkCardBG)
                    
                    Section {
                        Button {
                            isFilePresented = true
                        } label: {
                            Label("Файл .json", systemImage: "folder.badge.plus")
                                .foregroundColor(.green)
                        }
                        
                        Button {
                            importFromClipboard()
                        } label: {
                            Label("Буфер обмена", systemImage: "doc.on.clipboard")
                                .foregroundColor(.orange)
                        }
                    } header: {
                        Text("Импорт").foregroundColor(.gray)
                    }
                    .listRowBackground(GermanColors.darkCardBG)
                    
                    Section {
                        HStack {
                            Text("Всего слов:")
                            Spacer()
                            Text("\(allWords.count)")
                                .bold()
                                .foregroundColor(.blue)
                        }
                    }
                    .listRowBackground(GermanColors.darkCardBG)
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("Данные")
            .fileImporter(
                isPresented: $isFilePresented,
                allowedContentTypes: [.json],
                allowsMultipleSelection: false
            ) { result in
                switch result {
                case .success(let urls):
                    if let url = urls.first {
                        importFromFile(url: url)
                    }
                case .failure(let error):
                    alertMsg = "Ошибка выбора файла: \(error.localizedDescription)"
                    isAlertPresented = true
                }
            }
            .sheet(item: $exportURL) { url in
                ShareSheet(items: [url])
            }
            .alert("Данные", isPresented: $isAlertPresented) {
                Button("OK") { }
            } message: {
                Text(alertMsg)
            }
        }
        .preferredColorScheme(.dark)
    }


    func exportJSON() {
        let dtos = allWords.map { word in
            WordDTO(
                original: word.original,
                translation: word.translation,
                wordType: word.wordType,
                gender: word.gender,
                plural: word.plural,
                praesens: word.praesens,
                praeteritum: word.praeteritum,
                perfekt: word.perfekt,
                rektion: word.rektion,
                examples: word.examples
            )
        }
        
        do {
            let data = try JSONEncoder().encode(dtos)
            let url = FileManager.default.temporaryDirectory.appendingPathComponent("GermanBackup.json")
            try data.write(to: url)
            exportURL = url
        } catch {
            alertMsg = "Ошибка при создании бэкапа"
            isAlertPresented = true
        }
    }

    func importFromFile(url: URL) {
        if url.startAccessingSecurityScopedResource() {
            defer { url.stopAccessingSecurityScopedResource() }
            if let data = try? Data(contentsOf: url) {
                processData(data)
            } else {
                alertMsg = "Не удалось прочитать файл"
                isAlertPresented = true
            }
        }
    }

    func importFromClipboard() {
        if let string = UIPasteboard.general.string, let data = string.data(using: .utf8) {
            processData(data)
        } else {
            alertMsg = "Буфер обмена пуст"
            isAlertPresented = true
        }
    }

    func processData(_ data: Data) {
        do {
            let dtos = try JSONDecoder().decode([WordDTO].self, from: data)
            let existing = Set(allWords.map { "\(GermanWord.normalized($0.original))|\($0.translation.lowercased())" })
            var count = 0
            
            for d in dtos {
                let pair = "\(GermanWord.normalized(d.original))|\(d.translation.lowercased())"
                if !existing.contains(pair) {
                    let w = GermanWord(
                        original: d.original,
                        translation: d.translation,
                        wordType: d.wordType ?? "Noun"
                    )
                    w.gender = d.gender
                    w.plural = d.plural
                    w.rektion = d.rektion
                    w.examples = d.examples ?? []
                    context.insert(w)
                    count += 1
                }
            }
            alertMsg = "Успешно импортировано слов: \(count)"
            isAlertPresented = true
        } catch {
            alertMsg = "Ошибка: неверный формат JSON"
            isAlertPresented = true
        }
    }
}


struct ShareSheet: UIViewControllerRepresentable {
    var items: [Any]
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

extension URL: @retroactive Identifiable {
    public var id: String { absoluteString }
}
