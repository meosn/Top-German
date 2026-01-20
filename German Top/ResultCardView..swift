import SwiftUI

struct ResultCardView: View {
    let dto: WordDTO; var isAlreadyAdded: Bool; var onAdd: () -> Void
    @State private var showingDetail = false
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Text(dto.original).font(.headline).bold().foregroundColor(.white)
                    if let g = dto.gender { Text(g).foregroundColor(GermanColors.colorForGender(g)).font(.caption).bold() }
                    Spacer(); Image(systemName: "info.circle").foregroundColor(.blue).font(.caption)
                }
                Text(dto.translation).font(.subheadline).foregroundColor(.gray)
                if let exs = dto.examples, !exs.isEmpty {
                    Text(exs.first!).font(.system(size: 10)).italic().foregroundColor(.gray.opacity(0.8)).lineLimit(1)
                }
            }
            .contentShape(Rectangle()).onTapGesture { showingDetail = true }
            
            Button(action: onAdd) {
                HStack { Image(systemName: isAlreadyAdded ? "checkmark.circle.fill" : "plus"); Text(isAlreadyAdded ? "В словаре" : "Добавить") }
                .frame(maxWidth: .infinity).frame(height: 44).background(isAlreadyAdded ? Color.gray.opacity(0.3) : Color.green).foregroundColor(.white).cornerRadius(10)
            }.disabled(isAlreadyAdded)
        }
        .padding().background(GermanColors.darkCardBG).cornerRadius(15).padding(.horizontal)
        .sheet(isPresented: $showingDetail) { NavigationStack { WordDetailView(dto: dto) } }
    }
}
