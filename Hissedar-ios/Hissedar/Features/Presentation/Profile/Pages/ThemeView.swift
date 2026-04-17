import SwiftUI


struct ThemeView: View {
    @Environment(ThemeManager.self) private var themeManager
    
    // Grid yapısı için kolonlar
    private let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                
                // MARK: - Önizleme Bölümü
                VStack(alignment: .leading, spacing: 12) {
                    Text(String.localized("proifle.theme.view"))
                        .font(.headline)
                        .foregroundStyle(themeManager.theme.textPrimary)
                    
                    LazyVGrid(columns: columns, spacing: 16) {
                        ForEach(ThemeType.allCases) { type in
                            ThemePreviewCard(
                                type: type,
                                isSelected: themeManager.currentThemeType == type,
                                theme: themeForType(type)
                            )
                            .onTapGesture {
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                    themeManager.setTheme(type)
                                }
                            }
                        }
                    }
                }
            }
            .padding()
        }
        .navigationTitle(String.localized("proifle.theme.title"))
        .background(themeManager.theme.background)
    }
    
    // Yardımcı fonksiyon: Tip'e göre örnek tema objesi döner
    private func themeForType(_ type: ThemeType) -> AppTheme {
        switch type {
        case .light: return LightTheme()
        case .dark: return DarkTheme()
        // Varsa system veya diğer temalar buraya
        }
    }
}

struct ThemePreviewCard: View {
    let type: ThemeType
    let isSelected: Bool
    let theme: AppTheme
    
    var body: some View {
        VStack(spacing: 12) {
            // Mini Arayüz Önizlemesi
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(theme.background)
                    .frame(height: 100)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(isSelected ? theme.accent : theme.border, lineWidth: isSelected ? 2 : 1)
                    )
                
                // İçerik Simülasyonu (Örn: Bir kart ve yazı)
                VStack(spacing: 6) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(theme.cardGradient)
                        .frame(width: 50, height: 30)
                    
                    RoundedRectangle(cornerRadius: 2)
                        .fill(theme.textSecondary.opacity(0.5))
                        .frame(width: 40, height: 4)
                    
                    RoundedRectangle(cornerRadius: 2)
                        .fill(theme.textTertiary.opacity(0.3))
                        .frame(width: 30, height: 4)
                }
            }
            
            // Etiket
            HStack {
                Image(systemName: type.systemImage)
                Text(type.displayName)
                    .font(.system(size: 14, weight: .medium))
            }
            .foregroundStyle(isSelected ? theme.accent : theme.textSecondary)
        }
        .padding(8)
        .background(isSelected ? theme.accent.opacity(0.05) : Color.clear)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}
