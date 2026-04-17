//
//  LanguageManager.swift
//  Hissedar
//
//  Created by Sinan Dinç on 4/17/26.
//

import SwiftUI
import Observation

// MARK: - Desteklenen Diller
enum AppLanguage: String, CaseIterable, Identifiable {
    case turkish = "tr"
    case english = "en"
    
    var id: String { rawValue }
    
    var displayName: String {
        switch self {
        case .turkish: return "Türkçe"
        case .english: return "English"
        }
    }
    
    var flag: String {
        switch self {
        case .turkish: return "🇹🇷"
        case .english: return "🇬🇧"
        }
    }
    
    var localizedName: String {
        switch self {
        case .turkish: return String(localized: "language.turkish", bundle: LanguageManager.shared.bundle)
        case .english: return String(localized: "language.english", bundle: LanguageManager.shared.bundle)
        }
    }
}

// MARK: - LanguageManager
@Observable
final class LanguageManager {
    
    static let shared = LanguageManager()
    
    private(set) var currentLanguage: AppLanguage
    private(set) var bundle: Bundle
    
    private init() {
        let language: AppLanguage
        if let saved = UserDefaults.standard.string(forKey: "hs_language"),
           let saved = AppLanguage(rawValue: saved) {
            language = saved
        } else {
            let preferred = Locale.preferredLanguages.first ?? "tr"
            language = preferred.hasPrefix("en") ? .english : .turkish
        }
        self.currentLanguage = language
        self.bundle = Self.loadBundle(for: language)
    }
    
    func setLanguage(_ language: AppLanguage) {
        guard language != currentLanguage else { return }
        
        UserDefaults.standard.set(language.rawValue, forKey: "hs_language")
        UserDefaults.standard.set([language.rawValue], forKey: "AppleLanguages")
        
        withAnimation(.easeInOut(duration: 0.25)) {
            self.bundle = Self.loadBundle(for: language)
            self.currentLanguage = language
        }
    }
    
    private static func loadBundle(for language: AppLanguage) -> Bundle {
        guard let path = Bundle.main.path(forResource: language.rawValue, ofType: "lproj"),
              let bundle = Bundle(path: path) else {
            return .main
        }
        return bundle
    }
}
