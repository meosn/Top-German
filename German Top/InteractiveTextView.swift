import SwiftUI

struct InteractiveTextView: View {
    let text: String
    var onWordTap: (String) -> Void

    var body: some View {
        let words = text.components(separatedBy: .whitespacesAndNewlines)
            .filter { !$0.isEmpty }
            .enumerated()
            .map { InteractiveWord(id: $0, content: $1) }
        
        FlowLayout(spacing: 8) {
            ForEach(words) { word in
                let clean = word.content.trimmingCharacters(in: .punctuationCharacters)
                Button { if !clean.isEmpty { onWordTap(clean) } } label: {
                    Text(word.content)
                        .font(.body).foregroundColor(.blue)
                        .padding(.horizontal, 4).padding(.vertical, 2)
                        .background(Color.blue.opacity(0.1)).cornerRadius(4)
                }.buttonStyle(.plain)
            }
        }
    }
}


struct InteractiveWord: Identifiable { let id: Int; let content: String }

struct FlowLayout: Layout {
    var spacing: CGFloat
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let width = proposal.width ?? .infinity
        var h: CGFloat = 0, x: CGFloat = 0, y: CGFloat = 0, rowH: CGFloat = 0
        for v in subviews {
            let s = v.sizeThatFits(.unspecified)
            if x + s.width > width { x = 0; y += rowH + spacing; rowH = 0 }
            x += s.width + spacing; rowH = max(rowH, s.height); h = max(h, y + rowH)
        }
        return CGSize(width: width, height: h)
    }
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        var x = bounds.minX, y = bounds.minY, rowH: CGFloat = 0
        for v in subviews {
            let s = v.sizeThatFits(.unspecified)
            if x + s.width > bounds.maxX { x = bounds.minX; y += rowH + spacing; rowH = 0 }
            v.place(at: CGPoint(x: x, y: y), proposal: .unspecified)
            x += s.width + spacing; rowH = max(rowH, s.height)
        }
    }
}
