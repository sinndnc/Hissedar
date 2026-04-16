import SwiftUI

// MARK: - Theme View
struct ThemeView: View {
    
    @State private var selectedTheme: AppTheme = .dark
    @State private var selectedAccent: AccentOption = .jade
    @State private var useSystemAppearance = false
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 28) {
                previewCard
                themeSelection
                accentColorSection
                systemAppearance
            }
            .padding(.horizontal, 20)
            .padding(.top, 8)
            .padding(.bottom, 40)
        }
        .background(Color.hsBackground)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("Tema")
                    .font(.hHeadline)
                    .foregroundStyle(Color.hWhite)
            }
        }
    }
    
    // MARK: - Preview Card
    private var previewCard: some View {
        VStack(spacing: 14) {
            Text("Önizleme")
                .font(.hCaptionMed)
                .foregroundStyle(Color.hsTextPrimary)
            
            // Mini app preview
            VStack(spacing: 10) {
                // Nav bar mock
                HStack {
                    RoundedRectangle(cornerRadius: 3)
                        .fill(Color.hWhite.opacity(0.3))
                        .frame(width: 60, height: 8)
                    Spacer()
                    Circle()
                        .fill(Color.hWhite.opacity(0.2))
                        .frame(width: 20, height: 20)
                }
                .padding(.horizontal, 14)
                .padding(.top, 10)
                
                // Balance mock
                VStack(spacing: 4) {
                    RoundedRectangle(cornerRadius: 2)
                        .fill(Color.hWhite.opacity(0.15))
                        .frame(width: 70, height: 6)
                    RoundedRectangle(cornerRadius: 3)
                        .fill(Color.hWhite.opacity(0.4))
                        .frame(width: 110, height: 14)
                }
                .padding(.vertical, 8)
                
                // Cards mock
                HStack(spacing: 8) {
                    ForEach(0..<3) { i in
                        RoundedRectangle(cornerRadius: 8)
                            .fill(selectedAccent.color.opacity(i == 0 ? 0.2 : 0.08))
                            .frame(height: 50)
                            .overlay(
                                VStack(spacing: 3) {
                                    Circle()
                                        .fill(selectedAccent.color.opacity(i == 0 ? 0.5 : 0.2))
                                        .frame(width: 14, height: 14)
                                    RoundedRectangle(cornerRadius: 1.5)
                                        .fill(Color.hWhite.opacity(0.2))
                                        .frame(width: 24, height: 4)
                                }
                            )
                    }
                }
                .padding(.horizontal, 14)
                
                // List mock
                VStack(spacing: 6) {
                    ForEach(0..<3) { _ in
                        HStack(spacing: 8) {
                            RoundedRectangle(cornerRadius: 6)
                                .fill(Color.hWhite.opacity(0.06))
                                .frame(width: 28, height: 28)
                            VStack(alignment: .leading, spacing: 3) {
                                RoundedRectangle(cornerRadius: 2)
                                    .fill(Color.hWhite.opacity(0.2))
                                    .frame(width: 80, height: 5)
                                RoundedRectangle(cornerRadius: 1.5)
                                    .fill(Color.hWhite.opacity(0.08))
                                    .frame(width: 50, height: 4)
                            }
                            Spacer()
                            RoundedRectangle(cornerRadius: 2)
                                .fill(selectedAccent.color.opacity(0.3))
                                .frame(width: 40, height: 6)
                        }
                    }
                }
                .padding(.horizontal, 14)
                .padding(.bottom, 14)
            }
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(selectedTheme == .dark ? Color(hex: "0D0F14") : Color(hex: "F5F5F7"))
            )
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.hsBackgroundSecondary)
        )
    }
    
    // MARK: - Theme Selection
    private var themeSelection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Görünüm")
                .font(.hBodyMedium)
                .foregroundStyle(Color.hWhite)
                .padding(.leading, 4)
            
            HStack(spacing: 12) {
                ForEach(AppTheme.allCases, id: \.self) { theme in
                    Button {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            selectedTheme = theme
                        }
                    } label: {
                        VStack(spacing: 12) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 14)
                                    .fill(theme == .dark ? Color(hex: "0D0F14") : Color(hex: "F5F5F7"))
                                    .frame(height: 72)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 14)
                                            .stroke(
                                                selectedTheme == theme ? Color.hJade : Color.hWhite.opacity(0.06),
                                                lineWidth: selectedTheme == theme ? 2 : 1
                                            )
                                    )
                                
                                // Mini icon
                                Image(systemName: theme.icon)
                                    .font(.system(size: 22, weight: .semibold))
                                    .foregroundStyle(theme == .dark ? Color.hWhite.opacity(0.5) : Color.black.opacity(0.5))
                            }
                            
                            HStack(spacing: 5) {
                                if selectedTheme == theme {
                                    Image(systemName: "checkmark.circle.fill")
                                        .font(.system(size: 12))
                                        .foregroundStyle(Color.hJade)
                                }
                                
                                Text(theme.title)
                                    .font(.hCaptionMed)
                                    .foregroundStyle(selectedTheme == theme ? Color.hWhite : Color.hsTextPrimary)
                            }
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
    
    // MARK: - Accent Color
    private var accentColorSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Vurgu Rengi")
                .font(.hBodyMedium)
                .foregroundStyle(Color.hWhite)
                .padding(.leading, 4)
            
            VStack(spacing: 0) {
                ForEach(AccentOption.allCases, id: \.self) { option in
                    Button {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            selectedAccent = option
                        }
                    } label: {
                        HStack(spacing: 14) {
                            ZStack {
                                Circle()
                                    .fill(option.color)
                                    .frame(width: 28, height: 28)
                                
                                if selectedAccent == option {
                                    Circle()
                                        .stroke(Color.hWhite, lineWidth: 2)
                                        .frame(width: 28, height: 28)
                                }
                            }
                            
                            Text(option.title)
                                .font(.hBody)
                                .foregroundStyle(Color.hWhite)
                            
                            Spacer()
                            
                            if selectedAccent == option {
                                Image(systemName: "checkmark")
                                    .font(.system(size: 13, weight: .bold))
                                    .foregroundStyle(Color.hJade)
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 13)
                    }
                    .buttonStyle(.plain)
                    
                    if option != AccentOption.allCases.last {
                        Divider()
                            .background(Color.hWhite.opacity(0.06))
                            .padding(.leading, 58)
                    }
                }
            }
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.hsBackgroundSecondary)
            )
        }
    }
    
    // MARK: - System Appearance
    private var systemAppearance: some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.hSilver.opacity(0.12))
                    .frame(width: 38, height: 38)
                
                Image(systemName: "gear")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(Color.hSilver)
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text("Sistem Temasını Kullan")
                    .font(.hBody)
                    .foregroundStyle(Color.hWhite)
                
                Text("Cihaz ayarlarını otomatik takip et")
                    .font(.hLabel)
                    .foregroundStyle(Color.hsTextPrimary)
            }
            
            Spacer()
            
            Toggle("", isOn: $useSystemAppearance)
                .toggleStyle(SwitchToggleStyle(tint: Color.hJade))
                .labelsHidden()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.hsBackgroundSecondary)
        )
    }
}

// MARK: - Theme Enum
enum AppTheme: CaseIterable {
    case dark, light
    
    var title: String {
        switch self {
        case .dark: "Koyu"
        case .light: "Açık"
        }
    }
    
    var icon: String {
        switch self {
        case .dark: "moon.fill"
        case .light: "sun.max.fill"
        }
    }
}

// MARK: - Accent Colors
enum AccentOption: CaseIterable {
    case jade, gold, mint, emerald, rust
    
    var title: String {
        switch self {
        case .jade: "Yeşim (Varsayılan)"
        case .gold: "Altın"
        case .mint: "Nane"
        case .emerald: "Zümrüt"
        case .rust: "Bakır"
        }
    }
    
    var color: Color {
        switch self {
        case .jade: .hJade
        case .gold: .hGold
        case .mint: .hMint
        case .emerald: .hEmerald
        case .rust: .hRust
        }
    }
}
