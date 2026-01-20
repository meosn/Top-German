import SwiftUI

struct ContentView: View {
    @State private var selectedTab = 0
    @State private var isTabBarHidden = false
    
    init() { UITabBar.appearance().isHidden = true }
    
    var body: some View {
        ZStack(alignment: .bottom) {
            Group {
                if selectedTab == 0 { WordLibraryView() }
                else if selectedTab == 1 { TrainingView() }
                else if selectedTab == 2 { IrregularVerbsView() } // НОВОЕ
                else if selectedTab == 3 { LearningView() }
                else { DataManagementView() }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .environment(\.isTabBarHidden, $isTabBarHidden)
            
            if !isTabBarHidden {
                HStack(spacing: 25) { // Уменьшил spacing, так как теперь 5 иконок
                    TabButton(icon: "books.vertical.fill", title: "Словарь", isSelected: selectedTab == 0) { selectedTab = 0 }
                    TabButton(icon: "graduationcap.fill", title: "Тренировка", isSelected: selectedTab == 1) { selectedTab = 1 }
                    TabButton(icon: "bolt.fill", title: "Глаголы", isSelected: selectedTab == 2) { selectedTab = 2 } // НОВОЕ
                    TabButton(icon: "book.fill", title: "Обучение", isSelected: selectedTab == 3) { selectedTab = 3 }
                    TabButton(icon: "tray.full.fill", title: "Данные", isSelected: selectedTab == 4) { selectedTab = 4 }
                }
                .padding(.horizontal, 20).padding(.vertical, 15)
                .background(Color(white: 0.15).opacity(0.95)).clipShape(Capsule()).shadow(radius: 10).padding(.bottom, 20)
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .background(Color.black.ignoresSafeArea())
        .animation(.spring(), value: isTabBarHidden)
    }
}

struct TabButton: View {
    let icon: String; let title: String; let isSelected: Bool; let action: () -> Void
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: icon).font(.system(size: 20))
                Text(title).font(.system(size: 10, weight: .medium))
            }.foregroundColor(isSelected ? .blue : .gray)
        }
    }
}
