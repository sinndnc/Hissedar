//
//  LanguageSettingsView.swift
//  Hissedar
//
//  Created by Sinan Dinç on 4/17/26.
//

import SwiftUI

struct LanguageSettingsView: View {
    
    @Environment(\.dismiss) private var dismiss
    
    private let theme = ThemeManager.shared.theme
    private let languageManager = LanguageManager.shared
    
    
    var body: some View {
        List {
            Section {
                ForEach(AppLanguage.allCases) { language in
                    languageRow(language)
                }
            } footer: {
                Text(String.localized("language.restart.hint"))
            }
        }
        .navigationTitle(String.localized("language.title"))
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func languageRow(_ language: AppLanguage) -> some View {
        Button {
            guard language != languageManager.currentLanguage else { return }
            languageManager.setLanguage(language)
        } label: {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(language.displayName)
                        .foregroundStyle(theme.textPrimary)
                    
                    Text(language.localizedName)
                        .font(.caption)
                        .foregroundStyle(theme.textSecondary)
                }
                
                Spacer()
                
                if languageManager.currentLanguage == language {
                    Image(systemName: "checkmark")
                        .font(.body.weight(.semibold))
                        .foregroundStyle(theme.accent)
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        LanguageSettingsView()
    }
}
