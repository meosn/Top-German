import SwiftUI

struct GrammarDetailView: View {
    @Environment(\.isTabBarHidden) var isTabBarHidden
    let lesson: GrammarLesson
    @State private var lookupItem: WordLookupItem?

    var body: some View {
        ZStack {
            GermanColors.deepBlack.ignoresSafeArea()
            
            ScrollView {
                VStack(alignment: .leading, spacing: 25) {
                    
                    // Контент урока
                    ForEach(lesson.sections) { section in
                        VStack(alignment: .leading, spacing: 12) {
                            if let header = section.header {
                                Text(header).font(.title3).bold().foregroundColor(.blue)
                            }
                            
                            Text(section.text)
                                .foregroundColor(.white.opacity(0.9))
                                .lineSpacing(6)
                                .font(.system(size: 17))
                            
                            if let deExample = section.germanExample {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("ПРИМЕР (нажми на слово):")
                                        .font(.system(size: 10, weight: .black))
                                        .foregroundColor(.gray)
                                    
                                    InteractiveTextView(text: deExample) { word in
                                        self.lookupItem = WordLookupItem(word: word)
                                    }
                                    .padding()
                                    .background(Color.blue.opacity(0.1))
                                    .cornerRadius(12)
                                }
                            }
                        }
                        .padding(20)
                        .background(GermanColors.darkCardBG)
                        .cornerRadius(20)
                    }
                    
                    // Внутри VStack в GrammarDetailView.swift

                    HStack(spacing: 15) {
                        // КНОПКА ПОДРОБНЕЕ
                        NavigationLink(destination: GrammarDeepDetailView(topic: lesson.title)) {
                            HStack {
                                Image(systemName: "doc.text.magnifyingglass")
                                Text("Подробнее")
                            }
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.orange)
                            .cornerRadius(15)
                        }

                        // КНОПКА ЧАТА (Уже была)
                        NavigationLink(destination: GrammarChatView(topic: lesson.title)) {
                            HStack {
                                Image(systemName: "sparkles")
                                Text("Спросить ИИ")
                            }
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(15)
                        }
                    }
                    .padding(.top, 10)
                    
                    Spacer(minLength: 100)
                }
                .padding()
            }
        }
        .navigationTitle(lesson.title)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear { isTabBarHidden.wrappedValue = true }
        .sheet(item: $lookupItem) { item in
            QuickAddWordView(wordToSearch: item.word)
        }
    }
}
