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
    
    var body: some View {
        Button(action: action) {
            Text(label)
                .font(.system(size: 12, weight: .semibold))
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(
                    isSelected
                    ? Color.hsBackgroundTertiary
                    : Color.clear
                )
                .foregroundColor(
                    isSelected
                    ? Color.hsTextPrimary
                    : Color.hsTextTertiary
                )
                .clipShape(Capsule())
                .overlay(
                    Capsule()
                        .strokeBorder(
                            isSelected
                            ? Color.hsBackgroundSecondary.opacity(0.3)
                            : Color.hsBorder,
                            lineWidth: 1
                        )
                )
        }
    }
}
