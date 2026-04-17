//
//  FilterPill.swift
//  Hissedar
//
//  Created by Sinan Dinç on 4/13/26.
//

import SwiftUI

struct FilterPill: View {
    let icon: String
    let label: String
    let isSelected: Bool
    let action: () -> Void
    
    @Environment(ThemeManager.self) private var themeManager
    
    var body: some View {
        Button(action: action) {
            Text(label)
                .font(.system(size: 12, weight: .semibold))
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(
                    isSelected
                    ? themeManager.theme.backgroundTertiary
                    : Color.clear
                )
                .foregroundColor(
                    isSelected
                    ? themeManager.theme.textPrimary
                    : themeManager.theme.textTertiary
                )
                .clipShape(Capsule())
                .overlay(
                    Capsule()
                        .strokeBorder(
                            isSelected
                            ? themeManager.theme.border.opacity(0.3)
                            : themeManager.theme.border,
                            lineWidth: 1
                        )
                )
        }
    }
}
