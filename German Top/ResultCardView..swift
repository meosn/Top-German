import SwiftUI

struct ResultCardView: View {
    let dto: WordDTO
    var isAlreadyAdded: Bool
    var onAdd: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text(dto.original).font(.headline).bold().foregroundColor(.white)
                if let g = dto.gender { Text(g).foregroundColor(GermanColors.colorForGender(g)).font(.caption).bold() }
                Spacer()
                Text(dto.wordType ?? "Word").font(.system(size: 10)).padding(4).background(.secondary.opacity(0.1)).cornerRadius(5)
            }
            Text(dto.translation).font(.subheadline).foregroundColor(.gray)
            
            if dto.wordType?.lowercased().contains("verb") == true {
                VStack(alignment: .leading, spacing: 4) {
                    if let p = dto.praesens { infoRow("Pres:", p) }
                    if let pf = dto.perfekt { infoRow("Perf:", pf) }
                }
            }
            
            if let pl = dto.plural, !pl.isEmpty { infoRow("Plural:", pl, color: .orange) }
            if let r = dto.rektion, !r.isEmpty { infoRow("Rek:", r, color: .purple) }
            
            Button(action: onAdd) {
                HStack {
                    Image(systemName: isAlreadyAdded ? "checkmark.circle.fill" : "plus")
                    Text(isAlreadyAdded ? "Уже в словаре" : "Добавить")
                }
                .frame(maxWidth: .infinity).frame(height: 44)
                .background(isAlreadyAdded ? Color.gray.opacity(0.3) : Color.green)
                .foregroundColor(.white).cornerRadius(10)
            }.disabled(isAlreadyAdded)
        }
        .padding().background(GermanColors.darkCardBG).cornerRadius(15).padding(.horizontal)
    }
    
    func infoRow(_ label: String, _ value: String, color: Color = .blue) -> some View {
        HStack {
            Text(label).font(.system(size: 10)).foregroundColor(.secondary)
            Text(value).font(.system(size: 10, weight: .bold)).foregroundColor(color)
        }
    }
}
