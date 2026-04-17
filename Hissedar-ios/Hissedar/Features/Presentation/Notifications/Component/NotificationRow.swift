//
//  NotificationSection.swift
//  Hissedar
//
//  Created by Sinan Dinç on 4/13/26.
//

import SwiftUI

struct NotificationRow: View {
    let notification: AppNotification
    @Environment(ThemeManager.self) private var themeManager
    
    var body: some View {
        HStack(spacing: 14) {
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 6) {
                    Text(notification.title)
                        .foregroundStyle(themeManager.theme.textPrimary)
                        .font(.system(size: 14, weight: .medium))
                        .lineLimit(1)
                    
                    if !notification.read {
                        Circle()
                            .fill(themeManager.theme.accent)
                            .frame(width: 7, height: 7)
                    }
                    
                    Spacer()
                    
                    Text(notification.createdAt) // ViewModel'den gelen localize edilmiş tarih
                        .foregroundStyle(themeManager.theme.textTertiary)
                        .font(.system(size: 11, weight: .medium))
                }
                
                Text(notification.body)
                    .font(.system(size: 12, weight: .regular))
                    .foregroundStyle(themeManager.theme.textSecondary)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .foregroundStyle(themeManager.theme.textTertiary)
                .font(.system(size: 10, weight: .semibold))
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(notification.read ? Color.clear : themeManager.theme.accent.opacity(0.03))
        .background(themeManager.theme.backgroundSecondary)
    }
}
