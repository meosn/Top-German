import SwiftUI
import SwiftData

@main
struct GermanApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        // Перечисляем все модели. SwiftData сама создаст базу.
        .modelContainer(for: [
            GermanWord.self,
            IrregularVerb.self,
            SavedDeepGrammar.self
        ])
    }
}
