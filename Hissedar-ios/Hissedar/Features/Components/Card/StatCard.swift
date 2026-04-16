//
//  StatCard.swift
//  Hissedar
//
//  Created by Sinan Dinç on 4/8/26.
//

import SwiftUI

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let accent: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(accent)
                .frame(width: 32, height: 32)
                .background(accent.opacity(0.12))
                .clipShape(RoundedRectangle(cornerRadius: 8))
            
            Text(value)
                .font(.system(size: 18, weight: .bold, design: .monospaced))
                .foregroundStyle(Color.hsTextPrimary)
                .lineLimit(1)
            
            Text(title)
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(Color.hsTextSecondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(Color.hsBackgroundSecondary)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .strokeBorder(Color.hsBorder, lineWidth: 1)
        )
    }
}
