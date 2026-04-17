//
//  WatchlistRow.swift
//  Hissedar
//
//  Zil ikonu eklendi — alarm kurma kısayolu.
//

import Foundation
import SwiftUI

struct WatchlistRow: View {
    let item: AssetItem
    
    @Environment(ThemeManager.self) private var themeManager
    
    var body: some View {
        HStack(spacing: 15) {
            // Icon
            ZStack {
                if let imageUrl = item.imageUrl {
                    AsyncImage(url: URL(string: imageUrl)!) { phase in
                        switch phase {
                        case .success(let image):
                            image
                                .resizable()
                                .scaledToFill()
                        default:
                            Color(hex: "12131A")
                        }
                    }
                    .frame(width: 44, height: 44)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                } else {
                    Text(item.title.prefix(1))
                        .font(.title3)
                        .fontWeight(.semibold)
                        .frame(width: 44, height: 44)
                        .background(Color(hex: "12131A"))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }
            }
            
            VStack(alignment: .leading, spacing: 10) {
                // Info
                VStack(alignment: .leading, spacing: 3) {
                    Text(item.title)
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(themeManager.theme.textPrimary)
                        .lineLimit(1)
                    
                    Text(item.subtitle ?? "")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(themeManager.theme.textSecondary)
                        .lineLimit(1)
                }
                
                ProgressView(value: item.fundingPercent / 100)
                    .frame(height: 3)
                    .progressViewStyle(.linear)
                    .tint(themeManager.theme.accent)
            }
            
            // Price + Change
            VStack(alignment: .trailing, spacing: 3) {
                AmountBadge(
                    price: item.formattedHSRPrice
                )
                
                ChangeBadge(
                    change: item.formattedChange,
                    isPositive: item.isPositive
                )
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 10)
        .background(themeManager.theme.backgroundSecondary)
    }
}
