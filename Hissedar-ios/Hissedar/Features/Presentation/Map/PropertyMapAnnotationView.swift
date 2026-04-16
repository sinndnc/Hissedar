//
//  PropertyMapAnnotationView.swift
//  Hissedar
//
//  Created by Sinan Dinç on 4/15/26.
//

import SwiftUI

struct PropertyMapAnnotationView: View {
    
    let item: AssetItem
    let isSelected: Bool
    
    var body: some View {
        VStack(spacing: 0) {
            // Pin bubble
            HStack(spacing: 6) {
                Image(systemName: item.icon)
                    .font(.system(size: 10, weight: .semibold))
                
                Text(item.formattedPrice)
                    .font(.system(size: 11, weight: .bold))
                    .lineLimit(1)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .foregroundStyle(isSelected ? Color.hsBackground : Color.hsTextPrimary)
            .background(isSelected ? Color.hsAccent : Color.hsBackgroundSecondary)
            .clipShape(Capsule())
            .shadow(color: .black.opacity(0.15), radius: 4, y: 2)
            
            // Arrow
            Triangle()
                .fill(isSelected ? Color.hsAccent : Color.hsBackgroundSecondary)
                .frame(width: 12, height: 6)
        }
        .scaleEffect(isSelected ? 1.15 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
    }
}

// MARK: - Triangle Shape

private struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        Path { p in
            p.move(to: CGPoint(x: rect.minX, y: rect.minY))
            p.addLine(to: CGPoint(x: rect.midX, y: rect.maxY))
            p.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
            p.closeSubpath()
        }
    }
}
