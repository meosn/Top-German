import SwiftUI
import SwiftData

struct WordLibraryView: View {
    @Environment(\.modelContext) private var context
    // Показываем самые свежие добавленные слова сверху
    @Query(sort: \GermanWord.createdAt, order: .reverse) var words: [GermanWord]
    @State private var search = ""
    @State private var isAdd = false

    var filteredWords: [GermanWord] {
        if search.isEmpty { return words }
        return words.filter { $0.original.localizedCaseInsensitiveContains(search) || $0.translation.localizedCaseInsensitiveContains(search) }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()
                
                VStack {
                    TextField("Поиск...", text: $search)
                        .padding(10)
                        .background(Color.white.opacity(0.1))
                        .cornerRadius(10)
                        .padding()

                    if filteredWords.isEmpty {
                        ContentUnavailableView("Пусто", systemImage: "magnifyingglass")
                    } else {
                        List {
                            ForEach(filteredWords) { word in
                                NavigationLink(destination: WordDetailView(word: word)) {
                                    HStack {
                                        Capsule().fill(GermanColors.colorForGender(word.gender)).frame(width: 4, height: 35)
                                        VStack(alignment: .leading) {
                                            Text(word.original).font(.headline).foregroundColor(.white)
                                            Text(word.translation).font(.subheadline).foregroundColor(.gray)
                                        }
                                    }
                                }
                                .listRowBackground(Color(white: 0.12))
                            }
                            .onDelete(perform: delete)
                        }
                        .listStyle(.plain)
                    }
                }
            }
            .navigationTitle("Словарь")
            .toolbar { Button { isAdd = true } label: { Image(systemName: "plus.circle.fill") } }
            .sheet(isPresented: $isAdd) { AddWordView() }
        }
    }
    
    func delete(at offsets: IndexSet) {
        for i in offsets { context.delete(filteredWords[i]) }
        try? context.save()
    }
}
