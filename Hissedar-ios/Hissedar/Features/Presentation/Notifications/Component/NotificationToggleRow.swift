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
    let accentColor: Color
    
    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(accentColor.opacity(isOn ? 0.12 : 0.05))
                    .frame(width: 38, height: 38)
                
                Image(systemName: icon)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(isOn ? accentColor : Color.hsTextPrimary)
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .foregroundStyle(Color.hsTextPrimary)
                    .font(.system(size: 13,weight: .semibold))
                
                Text(subtitle)
                    .foregroundStyle(Color.hsTextSecondary)
                    .font(.system(size: 12,weight: .semibold))
            }
            
            Spacer()
            
            Toggle("", isOn: $isOn)
                .toggleStyle(SwitchToggleStyle(tint: Color.hJade))
                .labelsHidden()
        }
        .padding(15)
        .animation(.easeInOut(duration: 0.2), value: isOn)
    }
}
