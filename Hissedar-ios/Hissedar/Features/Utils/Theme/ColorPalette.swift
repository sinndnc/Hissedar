import SwiftUI

// MARK: - Hissedar Color Palette (Palet A)
// Kömür siyah + mor accent — sade, güçlü, fintech
extension Color {
    
    // MARK: - Backgrounds
    
    /// Ana arka plan
    /// Hex: #0A0B0F
    static let hsBackground = Color(hex: "#0A0B0F")
    
    /// İkincil arka plan — kartlar, sheet'ler
    /// Hex: #181A24
    static let hsBackgroundSecondary = Color(hex: "#181A24")
    
    /// Üçüncül arka plan — yükseltilmiş yüzeyler, input'lar, hover
    /// Hex: #222430
    static let hsBackgroundTertiary = Color(hex: "#222430")
    
    /// Elevated — modal, popup, dropdown
    /// Hex: #2A2C3A
    static let hsBackgroundElevated = Color(hex: "#2A2C3A")
    
    // MARK: - Brand Purple Ramp (Koyu → Açık)
    
    /// En koyu mor — gölgeler, derinlik
    /// Hex: #5B21B6
    static let hsPurple900 = Color(hex: "#5B21B6")
    
    /// Koyu mor
    /// Hex: #6D28D9
    static let hsPurple800 = Color(hex: "#6D28D9")
    
    /// Orta-koyu mor
    /// Hex: #7C3AED
    static let hsPurple700 = Color(hex: "#7C3AED")
    
    /// Primary — ana marka rengi, butonlar, aktif tab
    /// Hex: #8B5CF6
    static let hsPurple600 = Color(hex: "#8B5CF6")
    static let hsPurple500 = Color(hex: "#8B5CF6")
    /// Açık mor — vurgular, ikincil aksiyon
    /// Hex: #A78BFA
    static let hsPurple400 = Color(hex: "#A78BFA")
    
    /// Orta-açık mor
    /// Hex: #C4B5FD
    static let hsPurple300 = Color(hex: "#C4B5FD")
    
    /// Çok açık mor - Arka plan vurguları
    /// Hex: #DDD6FE
    static let hsPurple200 = Color(hex: "#DDD6FE")
    
    /// Pastel mor - Yumuşak yüzeyler
    /// Hex: #EDE9FE
    static let hsPurple100 = Color(hex: "#EDE9FE")
    
    /// En açık mor - Sayfa arka planları veya hafif hover durumları
    /// Hex: #F5F3FF
    static let hsPurple50 = Color(hex: "#F5F3FF")
    
    /// Lavanta — öne çıkan elementler, link'ler
    /// Hex: #C4B5FD
    static let hsLavender = Color(hex: "#C4B5FD")
    
    /// En açık lavanta — subtle badge, başlıklar
    /// Hex: #EDE9FE
    static let hsLavenderLight = Color(hex: "#EDE9FE")
    
    // MARK: - Text
    
    /// Primary text — ana metin, başlıklar
    /// Hex: #E4E4E8
    static let hsTextPrimary = Color(hex: "#E4E4E8")
    
    /// Secondary text — açıklamalar, alt başlıklar
    /// Hex: #8A8A92
    static let hsTextSecondary = Color(hex: "#8A8A92")
    
    /// Tertiary text — placeholder, hint, devre dışı
    /// Hex: #4A4A52
    static let hsTextTertiary = Color(hex: "#4A4A52")
    
    // MARK: - Semantic
    
    /// Primary accent
    static let hsAccent = Color.hsPurple600
    
    /// Secondary accent
    static let hsAccentSecondary = Color.hsPurple400
    
    /// Border — kartlar, input'lar
    static let hsBorder = Color.hsPurple600.opacity(0.12)
    
    /// Border aktif — focus, selected
    static let hsBorderActive = Color.hsPurple600.opacity(0.35)
    
    /// Success — pozitif değişim, onay
    /// Hex: #34D399
    static let hsSuccess = Color(hex: "#34D399")
    
    /// Warning — dikkat, uyarı
    /// Hex: #FBBF24
    static let hsWarning = Color(hex: "#FBBF24")
    
    /// Error — negatif değişim, hata
    /// Hex: #F87171
    static let hsError = Color(hex: "#F87171")
    
    // MARK: - Token Parça Renkleri (Icon Quadrants)
    
    static let hsTokenTopLeft = Color.hsLavender
    static let hsTokenTopRight = Color.hsPurple600
    static let hsTokenBottomLeft = Color.hsPurple400.opacity(0.7)
    static let hsTokenBottomRight = Color.hsPurple700
}
 
// MARK: - Gradient Tanımları
 
extension LinearGradient {
    
    /// Buton gradient
    static let hsButtonGradient = LinearGradient(
        colors: [.hsPurple600, .hsPurple700],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    /// Kart arka planı
    static let hsCardGradient = LinearGradient(
        colors: [.hsBackgroundSecondary, .hsBackgroundTertiary],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    /// Avatar gradient (mülk kartları)
    static let hsAvatarGradient = LinearGradient(
        colors: [.hsPurple600, .hsPurple800],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
}
