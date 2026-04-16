//
//  NotificationRow.swift
//  Hissedar
//
//  Created by Sinan Dinç on 3/23/26.
//

import SwiftUI

struct NotificationRow: View {
    let notification: AppNotification
    
    var body: some View {
        HStack(spacing: 14) {
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 6) {
                    Text(notification.title)
                        .foregroundStyle(Color.hsTextPrimary)
                        .font(.system(size: 14,weight: .medium))
                        .lineLimit(1)
                    if !notification.read {
                        Circle()
                            .fill(Color.hsPurple700)
                            .frame(width: 7, height: 7)
                    }
                    Spacer()
                    
                    Text(notification.createdAt)
                        .foregroundStyle(Color.hsTextTertiary)
                        .font(.system(size: 12,weight: .medium))
                }
                Text(notification.body)
                    .font(.system(size: 12,weight: .medium))
                    .foregroundStyle(Color.hsTextSecondary)
                    .lineLimit(2)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .foregroundStyle(Color.hsTextPrimary)
                .font(.system(size: 11, weight: .semibold))
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .opacity(notification.read ? 0.7 : 1)
        .background(Color.hsBackgroundSecondary)
    }
}
