// MARK: - MarketListRow.swift
// Hissedar — Piyasa Liste Satırı (Tüm varlık tipleri için)

import SwiftUI

struct MarketListRow<Icon: View>: View {
    let rank: Int
    let icon: Icon
    let title: String
    let meta: [String]
    let sparklineData: [Double]?
    let isPositive: Bool
    let price: String
    let change: String
    
    init(
        rank: Int,
        title: String,
        meta: [String],
        sparklineData: [Double]? = nil,
        isPositive: Bool,
        price: String,
        change: String,
        @ViewBuilder icon: () -> Icon
    ) {
        self.rank = rank
        self.title = title
        self.meta = meta
        self.sparklineData = sparklineData
        self.isPositive = isPositive
        self.price = price
        self.change = change
        self.icon = icon()
    }
    
    var body: some View {
        HStack(spacing: 12) {
            // Rank
            Text("\(rank)")
                .font(.system(size: 12, weight: .medium, design: .monospaced))
                .foregroundColor(Color.hsTextTertiary)
                .frame(width: 18)
            
            // Icon
            icon
                .frame(width: 44, height: 44)
                .background(Color.hsBackgroundSecondary)
                .clipShape(RoundedRectangle(cornerRadius: 15))
                .overlay(
                    RoundedRectangle(cornerRadius: 15)
                        .strokeBorder(Color.hsBorder, lineWidth: 1)
                )
            
            // Info
            VStack(alignment: .leading, spacing: 10) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(Color.hsTextPrimary)
                        .lineLimit(1)
                    
                    HStack(spacing: 6) {
                        ForEach(Array(meta.enumerated()), id: \.offset) { index, item in
                            if index > 0 {
                                Circle()
                                    .fill(Color.hsTextTertiary)
                                    .frame(width: 3, height: 3)
                            }
                            Text(item)
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(Color.hsTextSecondary)
                        }
                    }
                }
                
                ProgressView(value: Double.random(in: 0.0...0.9))
                    .frame(height: 3)
                    .progressViewStyle(.linear)
                    .tint(Color.hsPurple400)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            // Price + Change
            VStack(alignment: .trailing, spacing: 2) {
                AmountBadge(
                    price: price
                )
                
                ChangeBadge(
                    change: change,
                    isPositive: isPositive
                )
            }
        }
        .padding(.horizontal)
        .padding(.vertical,10)
        .background(Color.hsBackgroundSecondary)
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: 0) {
        MarketListRow(
            rank: 1,
            title: "Levent Tower Hisse",
            meta: ["İstanbul", "Ticari"],
            sparklineData: [0.3, 0.5, 0.6, 0.8, 0.9],
            isPositive: true,
            price: "₺2.450",
            change: "+12.4%"
        ) {
            Text("🏢").font(.title2)
        }

        Divider()

        MarketListRow(
            rank: 2,
            title: "Ankara Kızılay İş Mrk",
            meta: ["Ankara", "Ticari"],
            sparklineData: [0.8, 0.6, 0.5, 0.3, 0.2],
            isPositive: false,
            price: "₺980",
            change: "-3.1%"
        ) {
            Text("🏗️").font(.title2)
        }
    }
    .padding(.horizontal, 24)
}
