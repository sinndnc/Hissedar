//
//  SearchBar.swift
//  Hissedar
//
//  Created by Sinan Dinç on 3/26/26.
//

import SwiftUI

struct SearchBar: View {
    
    @Binding var searchText: String
    @Environment(ThemeManager.self) private var themeManager
    
    var body: some View{
        return HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(themeManager.theme.textPrimary.opacity(0.6))
            
            TextField("", text: $searchText, prompt: Text(String.localized("search.placeholder"))
                .foregroundColor(themeManager.theme.textPrimary.opacity(0.5))
            )
            .font(.system(size: 15))
            .foregroundColor(themeManager.theme.textTertiary)
            .autocorrectionDisabled()
            .textInputAutocapitalization(.never)
            
            if !searchText.isEmpty {
                Button {
                    withAnimation { searchText = "" }
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 16))
                        .foregroundColor(themeManager.theme.accent.opacity(0.5))
                }
            }
        }
        .padding(12)
        .background(themeManager.theme.backgroundSecondary)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .strokeBorder(
                    searchText.isEmpty
                    ? themeManager.theme.border
                    : themeManager.theme.border.opacity(0.3),
                    lineWidth: 1
                )
        )
    }
}
