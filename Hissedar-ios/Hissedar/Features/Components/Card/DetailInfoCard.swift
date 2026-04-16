//
//  DetailInfoRow.swift
//  Hissedar
//
//  Created by Sinan Dinç on 4/8/26.
//

import SwiftUI

struct DetailInfoRow: Identifiable {
    let id = UUID()
    let label: String
    let value: String
    let icon: String
    var valueColor: Color = Color.hsTextPrimary
}

struct DetailInfoCard: View {
    let rows: [DetailInfoRow]

    var body: some View {
        VStack(spacing: 0) {
            ForEach(Array(rows.enumerated()), id: \.element.id) { index, row in
                HStack {
                    HStack(spacing: 10) {
                        Image(systemName: row.icon)
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(Color.hsPurple400)
                            .frame(width: 20)
                        Text(row.label)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundStyle(Color.hsTextSecondary)
                    }
                    Spacer()
                    Text(row.value)
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(row.valueColor)
                        .lineLimit(1)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 14)

                if index < rows.count - 1 {
                    Rectangle()
                        .fill(Color.hsBorder)
                        .frame(height: 1)
                        .padding(.horizontal, 16)
                }
            }
        }
        .background(Color.hsBackgroundSecondary)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .strokeBorder(Color.hsBorder, lineWidth: 1)
        )
    }
}
