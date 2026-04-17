//
//  NotificationToggleRow.swift
//  Hissedar
//
//  Created by Sinan Dinç on 4/13/26.
//

import SwiftUI

// MARK: - Toggle Row
struct NotificationToggleRow: View {
    let icon: String
    let title: String
    let subtitle: String
    @Binding var isOn: Bool
    
    @Environment(ThemeManager.self) private var themeManager
    
    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(themeManager.theme.accent.opacity(isOn ? 0.12 : 0.05))
                    .frame(width: 38, height: 38)
                
                Image(systemName: icon)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(
                        isOn ?
                        themeManager.theme.accent :
                        themeManager.theme.textPrimary
                    )
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .foregroundStyle(themeManager.theme.textPrimary)
                    .font(.system(size: 13,weight: .semibold))
                
                Text(subtitle)
                    .foregroundStyle(themeManager.theme.textSecondary)
                    .font(.system(size: 12,weight: .semibold))
            }
            
            Spacer()
            
            Toggle("", isOn: $isOn)
                .toggleStyle(SwitchToggleStyle(tint: themeManager.theme.accent))
                .labelsHidden()
        }
        .padding(15)
        .animation(.easeInOut(duration: 0.2), value: isOn)
    }
}
