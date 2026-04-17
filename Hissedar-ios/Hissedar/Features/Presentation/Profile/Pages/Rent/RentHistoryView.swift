//
//  RentHistoryView.swift
//  Hissedar
//
//  Created by Sinan Dinç on 4/13/26.
//

import SwiftUI
import Factory

// MARK: - RentHistoryView

struct RentHistoryView: View {
    
    @Injected(\.rentViewModel) private var vm
    @Environment(ThemeManager.self) private var themeManager
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 0, pinnedViews: .sectionHeaders) {
                if vm.items.isEmpty {
                    emptyState
                        .padding(.top, 80)
                } else {
                    // Not: Eğer ViewModel'de veriler yıllara göre gruplanmışsa
                    // buraya Section(header: yearHeader(year)) eklenebilir.
                    ForEach(vm.items) { item in
                        NavigationLink(destination: RentHistoryDetailView(item: item)) {
                            RentHistoryRowView(item: item)
                        }
                        .buttonStyle(.plain)
                        
                        if vm.items.last?.id != item.id {
                            Divider()
                                .padding(.leading, 75) // Thumbnail + Spacing kadar offset
                        }
                    }
                    Spacer(minLength: 40)
                }
            }
        }
        .background(themeManager.theme.background)
        .navigationTitle(String.localized("rent.history.title"))
        .task { await vm.load() }
        .refreshable { await vm.refresh() }
        .navigationBarTitleDisplayMode(.large)
    }

    // MARK: - Year Header

    private func yearHeader(_ year: Int) -> some View {
        HStack {
            Text(year == 0 ? String.localized("rent.history.unknown_period") : "\(year)")
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(themeManager.theme.textSecondary)
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
            Spacer()
        }
        .background(.ultraThinMaterial)
    }

    // MARK: - Empty State

    private var emptyState: some View {
        VStack(spacing: 14) {
            Image(systemName: "tray.and.arrow.down")
                .font(.system(size: 44, weight: .light))
                .foregroundStyle(themeManager.theme.textSecondary.opacity(0.5))
            
            Text(String.localized("rent.history.empty_title"))
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(themeManager.theme.textPrimary)
            
            Text(String.localized("rent.history.empty_desc"))
                .font(.system(size: 13))
                .foregroundStyle(themeManager.theme.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - RentHistoryRowView

struct RentHistoryRowView: View {
    
    let item: RentHistory
    @Environment(ThemeManager.self) private var themeManager
    
    var body: some View {
        HStack(spacing: 14) {
            
            // MARK: Thumbnail
            thumbnailView
            
            // MARK: Center Info
            VStack(alignment: .leading, spacing: 4) {
                Text(item.assetTitle ?? item.assetId)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(themeManager.theme.textPrimary)
                    .lineLimit(1)
                
                HStack(spacing: 6) {
                    if let city = item.propertyCity {
                        Text(city)
                            .font(.system(size: 12))
                            .foregroundStyle(themeManager.theme.textSecondary)
                        
                        Text("•")
                            .foregroundStyle(themeManager.theme.textTertiary)
                            .font(.system(size: 10))
                    }
                    
                    Text(item.periodLabel)
                        .font(.system(size: 12))
                        .foregroundStyle(themeManager.theme.textSecondary)
                }
                
                Text(item.transactionId)
                    .font(.system(size: 11, weight: .medium, design: .monospaced))
                    .foregroundStyle(themeManager.theme.textTertiary)
                    .lineLimit(1)
            }
            
            Spacer(minLength: 4)
            
            // MARK: Amount + Share
            VStack(alignment: .trailing, spacing: 5) {
                AmountBadge(
                    price: item.formattedAmount
                )
                
                if let i = item.sharePercent {
                    ChangeBadge(
                        change: i.percentFormatted,
                        isPositive: i > 0.0
                    )
                }
            }
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
        .background(themeManager.theme.backgroundSecondary)
    }
    
    // MARK: - Thumbnail
    
    @ViewBuilder
    private var thumbnailView: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(assetColor(item.assetType).opacity(0.12))
                .frame(width: 48, height: 48)
            
            if let urlStr = item.assetImageUrl, let url = URL(string: urlStr) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFill()
                            .frame(width: 48, height: 48)
                            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                    default:
                        assetIcon
                    }
                }
            } else {
                assetIcon
            }
        }
    }
    
    private var assetIcon: some View {
        Image(systemName: assetIconName(item.assetType))
            .font(.system(size: 18, weight: .medium))
            .foregroundStyle(assetColor(item.assetType))
    }
    
    // MARK: - Helpers (Localized Labels for Asset Types if needed)
    
    private func assetIconName(_ type: String) -> String {
        switch type.lowercased() {
        case "apartment", "konut": return "building.2.fill"
        case "office", "ofis":    return "building.columns.fill"
        case "land", "arsa":      return "map.fill"
        case "shop", "dukkan":    return "storefront.fill"
        default:                  return "house.fill"
        }
    }
    
    private func assetColor(_ type: String) -> Color {
        switch type.lowercased() {
        case "apartment", "konut": return .blue
        case "office", "ofis":    return .indigo
        case "land", "arsa":      return .green
        case "shop", "dukkan":    return .orange
        default:                  return .teal
        }
    }
}
