import SwiftUI
import SwiftData

struct WordLibraryView: View {
    @Environment(\.modelContext) private var context
    @Query(sort: \GermanWord.original) var words: [GermanWord]
    @State private var search = ""
    @State private var isAdd = false

    var filteredWords: [GermanWord] {
        if search.isEmpty { return words }
        return words.filter {
            $0.original.localizedCaseInsensitiveContains(search) ||
            $0.translation.localizedCaseInsensitiveContains(search)
        }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                GermanColors.deepBlack.ignoresSafeArea()
                
                VStack(spacing: 0) {
                    HStack {
                        Image(systemName: "magnifyingglass").foregroundColor(.gray)
                        TextField("Search DE/RU...", text: $search)
                            .foregroundColor(.white)
                            .autocorrectionDisabled()
                    }
                    .padding(12).background(Color(white: 0.15)).cornerRadius(12)
                    .padding(.horizontal)

                    List {
                        ForEach(filteredWords) { word in
                            ZStack {
                                NavigationLink(destination: WordDetailView(word: word)) { EmptyView() }.opacity(0)
                                
                                HStack(spacing: 15) {
                                    Capsule().fill(GermanColors.colorForGender(word.gender)).frame(width: 4, height: 40)
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(word.original).font(.system(size: 19, weight: .bold)).foregroundColor(.white)
                                        Text(word.translation).font(.system(size: 15)).foregroundColor(.gray)
                                    }
                                    Spacer()
                                    Image(systemName: "chevron.right").font(.system(size: 14, weight: .bold)).foregroundColor(Color(white: 0.3))
                                }
                                .padding(.vertical, 12).padding(.horizontal, 16)
                                .background(GermanColors.darkCardBG)
                                .cornerRadius(20)
                            }
                            .listRowBackground(Color.clear)
                            .listRowSeparator(.hidden)
                            .listRowInsets(EdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16))
                        }
                        .onDelete { i in i.forEach { context.delete(filteredWords[$0]) } }

                        Color.clear
                            .frame(height: 100)
                            .listRowBackground(Color.clear)
                            .listRowSeparator(.hidden)
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("Словарь")
            .toolbar {
                Button { isAdd = true } label: { Image(systemName: "plus.circle.fill").foregroundColor(.white).font(.title2) }
            }
            .sheet(isPresented: $isAdd) { AddWordView() }
        }
    }
}
