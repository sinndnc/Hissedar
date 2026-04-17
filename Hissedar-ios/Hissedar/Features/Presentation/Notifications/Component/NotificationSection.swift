//
//  NotificationSection.swift
//  Hissedar
//
//  Created by Sinan Dinç on 4/13/26.
//

import SwiftUI

struct NotificationSection<Content: View>: View {
    let title: String
    @ViewBuilder let content: Content
    @Environment(ThemeManager.self) private var themeManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .padding(.horizontal)
                .foregroundStyle(themeManager.theme.textPrimary)
                .font(.system(size: 14, weight: .semibold))
            
            VStack(spacing: 0) {
                content
            }
            .background(themeManager.theme.backgroundSecondary)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .strokeBorder(themeManager.theme.border, lineWidth: 0.5)
            )
            .padding(.horizontal)
        }
    }
}
