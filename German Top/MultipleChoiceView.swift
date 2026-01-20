import SwiftUI

struct MultipleChoiceView: View {
    let words: [GermanWord]
    @State private var index = 0
    @State private var options: [String] = []
    @State private var selected: String? = nil
    @State private var answered = false

    var body: some View {
        VStack(spacing: 30) {
            if index < words.count {
                Text(words[index].original).font(.system(size: 40, weight: .bold)).onTapGesture { SpeechManager.shared.speak(words[index].original) }
                VStack(spacing: 12) {
                    ForEach(options, id: \.self) { opt in
                        Button(action: { check(opt) }) {
                            Text(opt).frame(maxWidth: .infinity).padding().background(answered ? (opt == words[index].translation ? Color.green : (opt == selected ? Color.red : Color.gray.opacity(0.3))) : Color.blue).foregroundColor(.white).cornerRadius(12)
                        }.disabled(answered)
                    }
                }.padding()
                if answered { Button("Далее") { next() }.buttonStyle(.borderedProminent) }
                Spacer()
            } else { Text("Готово!").font(.title) }
        }.navigationTitle("Тест").onAppear { generate() }
    }
    func generate() {
        let correct = words[index].translation
        options = (words.filter({$0.id != words[index].id}).map({$0.translation}).shuffled().prefix(3) + [correct]).shuffled()
    }
    func check(_ ans: String) { selected = ans; answered = true; if ans == words[index].translation { words[index].correctCount += 1 } }
    func next() { index += 1; answered = false; if index < words.count { generate() } }
}
