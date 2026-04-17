//
//  ThemeType.swift
//  Hissedar
//
//  Created by Sinan Dinç on 4/16/26.
//


import SwiftUI
import Observation

// MARK: - Tema Tipi
enum ThemeType: String, CaseIterable, Identifiable {
    case dark  = "dark"
    case light = "light"
    
    var id: String { rawValue }
    
    var displayName: String {
        switch self {
        case .dark:  return String.localized("theme.dark")
        case .light: return String.localized("theme.light")
        }
    }
    
    var systemImage: String {
        switch self {
        case .dark:  return "moon.fill"
        case .light: return "sun.max.fill"
        }
    }
}

// MARK: - ThemeManager
@Observable
final class ThemeManager {
    
    // MARK: - Singleton
    static let shared = ThemeManager()
    
    // MARK: - Saklanan tercih (@AppStorage ile UserDefaults'a yazılır)
    // @Observable + @AppStorage birlikte çalışmaz; bu yüzden
    // didSet ile manuel senkronizasyon yapıyoruz.
    private(set) var currentThemeType: ThemeType {
        didSet {
            UserDefaults.standard.set(currentThemeType.rawValue, forKey: "hs_theme")
        }
    }
    
    // MARK: - Aktif tema nesnesi
    var theme: any AppTheme {
        switch currentThemeType {
        case .dark:  return DarkTheme()
        case .light: return LightTheme()
        }
    }
    
    // MARK: - Init
    private init() {
        let saved = UserDefaults.standard.string(forKey: "hs_theme") ?? ""
        self.currentThemeType = ThemeType(rawValue: saved) ?? .dark
    }
    
    // MARK: - Tema Değiştirme
    func setTheme(_ type: ThemeType) {
        withAnimation(.easeInOut(duration: 0.25)) {
            currentThemeType = type
        }
    }
    
    func toggleTheme() {
        setTheme(currentThemeType == .dark ? .light : .dark)
    }
}
