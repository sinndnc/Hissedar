//
//  DiscoverListRow.swift
//  Hissedar
//
//  Piyasa Liste Satırı (Tüm varlık tipleri için)
//

import SwiftUI

struct DiscoverListRow<Icon: View>: View {
    let rank: Int
    let item: AssetItem
    let icon: Icon
    
    @Environment(ThemeManager.self) private var themeManager
    
    init(
        rank: Int,
        item: AssetItem,
        @ViewBuilder icon: () -> Icon
    ) {
        self.rank = rank
        self.item = item
        self.icon = icon()
    }
    
    var body: some View {
        HStack(spacing: 12) {
            // Rank
            Text("\(rank)")
                .font(.system(size: 12, weight: .medium, design: .monospaced))
                .foregroundColor(themeManager.theme.textTertiary)
                .frame(width: 18)
            
            // Icon
            icon
                .frame(width: 44, height: 44)
                .background(themeManager.theme.backgroundSecondary)
                .clipShape(RoundedRectangle(cornerRadius: 15))
                .overlay(
                    RoundedRectangle(cornerRadius: 15)
                        .strokeBorder(themeManager.theme.border, lineWidth: 1)
                )
            
            // Info
            VStack(alignment: .leading, spacing: 10) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(item.title)
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(themeManager.theme.textPrimary)
                        .lineLimit(1)
                    
                    HStack(spacing: 6) {
                        ForEach(Array(item.listMeta.enumerated()), id: \.offset) { index, metaItem in
                            if index > 0 {
                                Circle()
                                    .fill(themeManager.theme.textTertiary)
                                    .frame(width: 3, height: 3)
                            }
                            Text(metaItem)
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(themeManager.theme.textSecondary)
                        }
                    }
                }
                
                // Fonlama ilerlemesi
                ProgressView(value: item.fundingPercent / 100)
                    .frame(height: 3)
                    .progressViewStyle(.linear)
                    .tint(themeManager.theme.accent)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            // Price + Change
            VStack(alignment: .trailing, spacing: 2) {
                AmountBadge(price: item.formattedPrice)
                ChangeBadge(change: item.formattedChange, isPositive: item.isPositive)
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 10)
        .background(themeManager.theme.backgroundSecondary)
    }
}
