import SwiftUI

struct GrammarChatView: View {
    let topic: String
    @State private var question: String = ""
    @State private var chatHistory: [ChatMessage] = []
    @State private var isLoading = false
    private let gemini = GeminiService()

    var body: some View {
        VStack {
            ScrollViewReader { proxy in
                ScrollView {
                    VStack(spacing: 15) {
                        Text("Вы обсуждаете тему: \(topic)")
                            .font(.caption).bold().padding(10)
                            .background(Color.gray.opacity(0.2)).cornerRadius(10)
                            .padding(.bottom)

                        ForEach(chatHistory) { msg in
                            HStack {
                                if msg.isUser { Spacer() }
                                Text(msg.text)
                                    .padding()
                                    .background(msg.isUser ? Color.blue : GermanColors.darkCardBG)
                                    .cornerRadius(15)
                                    .foregroundColor(.white)
                                if !msg.isUser { Spacer() }
                            }
                            .id(msg.id)
                        }
                        
                        if isLoading { ProgressView().padding() }
                    }
                    .padding()
                }
                .onChange(of: chatHistory.count) { _ in
                    withAnimation { proxy.scrollTo(chatHistory.last?.id) }
                }
            }
            
            HStack {
                TextField("Задать вопрос по теме...", text: $question)
                    .padding()
                    .background(Color(white: 0.15))
                    .cornerRadius(15)
                    .foregroundColor(.white)
                
                Button(action: ask) {
                    Image(systemName: "paperplane.fill")
                        .font(.title2).foregroundColor(.white)
                        .frame(width: 50, height: 50)
                        .background(Color.blue).cornerRadius(15)
                }
                .disabled(question.isEmpty || isLoading)
            }
            .padding()
        }
        .navigationTitle("Ассистент")
        .background(Color.black.ignoresSafeArea())
    }

    func ask() {
        let q = question
        chatHistory.append(ChatMessage(text: q, isUser: true))
        question = ""
        isLoading = true
        
        Task {
            do {
                let response = try await gemini.askAnything(topic: topic, question: q)
                await MainActor.run {
                    chatHistory.append(ChatMessage(text: response, isUser: false))
                    isLoading = false
                }
            } catch {
                await MainActor.run { isLoading = false }
            }
        }
    }
}

struct ChatMessage: Identifiable {
    let id = UUID()
    let text: String
    let isUser: Bool
}
