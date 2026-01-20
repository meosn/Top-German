import SwiftUI
import SwiftData

@main
struct GermanApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: GermanWord.self)
    }
}
