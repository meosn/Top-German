import SwiftUI

struct LearningView: View {
    @Environment(\.isTabBarHidden) var isTabBarHidden
    @State private var customTopic: String = ""
    @State private var navigateToCustom = false

    var body: some View {
        NavigationStack {
            ZStack {
                GermanColors.deepBlack.ignoresSafeArea()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 30) {
                        ForEach(GrammarData.contents) { part in
                            VStack(alignment: .leading, spacing: 15) {
                                Text(part.title)
                                    .font(.system(size: 14, weight: .black))
                                    .foregroundColor(.blue)
                                    .padding(.leading, 5)
                                
                                ForEach(part.chapters) { chapter in
                                    DisclosureGroup {
                                        VStack(spacing: 10) {
                                            ForEach(chapter.lessons) { lesson in
                                                NavigationLink(destination: GrammarDetailView(lesson: lesson)) {
                                                    HStack {
                                                        VStack(alignment: .leading, spacing: 4) {
                                                            Text(lesson.title)
                                                                .font(.headline).foregroundColor(.white)
                                                            Text(lesson.description)
                                                                .font(.caption).foregroundColor(.gray)
                                                        }
                                                        Spacer()
                                                        Image(systemName: "book.closed.fill").foregroundColor(.blue.opacity(0.7))
                                                    }
                                                    .padding()
                                                    .background(Color.white.opacity(0.05))
                                                    .cornerRadius(12)
                                                }
                                                .buttonStyle(.plain)
                                            }
                                        }
                                        .padding(.top, 10)
                                    } label: {
                                        Text(chapter.title)
                                            .font(.system(size: 18, weight: .bold))
                                            .foregroundColor(.white)
                                            .padding(.vertical, 5)
                                    }
                                    .padding()
                                    .background(GermanColors.darkCardBG)
                                    .cornerRadius(18)
                                }
                            }
                        }
                        VStack(alignment: .leading, spacing: 15) {
                            Text("Темы слов").font(.title2).bold().foregroundColor(.white)
                            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 15) {
                                TopicNavigationCard(title: "Путешествия", icon: "airplane", color: .orange)
                                TopicNavigationCard(title: "Работа", icon: "briefcase.fill", color: .blue)
                                TopicNavigationCard(title: "Еда", icon: "fork.knife", color: .green)
                                TopicNavigationCard(title: "Здоровье", icon: "heart.fill", color: .red)
                            }
                        }
                        VStack(alignment: .leading, spacing: 15) {
                            
                            HStack {
                                TextField("О чем хотите узнать?", text: $customTopic)
                                    .padding()
                                    .background(GermanColors.darkCardBG)
                                    .cornerRadius(12)
                                    .foregroundColor(.white)
                                    .onSubmit { if !customTopic.isEmpty { navigateToCustom = true } }
                                
                                Button { if !customTopic.isEmpty { navigateToCustom = true } } label: {
                                    Image(systemName: "sparkles")
                                        .font(.title2).foregroundColor(.white)
                                        .frame(width: 54, height: 54)
                                        .background(customTopic.isEmpty ? Color.gray.opacity(0.3) : Color.blue)
                                        .cornerRadius(12)
                                }
                            }
                        }

                        
                        Spacer(minLength: 120)
                    }
                    .padding()
                }
                
                NavigationLink(destination: TopicWordsView(topicName: customTopic), isActive: $navigateToCustom) {
                    EmptyView()
                }
            }
            .navigationTitle("Обучение")
            .onAppear {
                            isTabBarHidden.wrappedValue = false
                        }
        }
    }
}


struct TopicNavigationCard: View {
    let title: String
    let icon: String
    let color: Color
    
    var body: some View {
        NavigationLink(destination: TopicWordsView(topicName: title)) {
            VStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.title)
                    .foregroundColor(color)
                Text(title)
                    .font(.headline)
                    .foregroundColor(.white)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 25)
            .background(GermanColors.darkCardBG)
            .cornerRadius(20)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(color.opacity(0.3), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}
