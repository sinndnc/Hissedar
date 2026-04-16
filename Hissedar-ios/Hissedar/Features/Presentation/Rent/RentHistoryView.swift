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
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 0, pinnedViews: .sectionHeaders) {
                if vm.items.isEmpty {
                    emptyState
                        .padding(.top, 80)
                } else {
                    ForEach(vm.items) { item in
                        NavigationLink(destination: RentHistoryDetailView(item: item)) {
                            RentHistoryRowView(item: item)
                        }
                        .buttonStyle(.plain)
                        
                        if vm.items.last?.id != item.id {
                            Divider()
                        }
                    }
                    Spacer(minLength: 40)
                }
            }
        }
        .background(Color.hsBackground)
        .navigationTitle("Kira Geçmişi")
        .task { await vm.load() }
        .refreshable { await vm.refresh() }
        .navigationBarTitleDisplayMode(.large)
    }

    // MARK: - Year Header

    private func yearHeader(_ year: Int) -> some View {
        HStack {
            Text(year == 0 ? "Bilinmeyen Dönem" : "\(year)")
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(.secondary)
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
            Spacer()
        }
        .background(.ultraThinMaterial)
    }

    // MARK: - Empty State

    private var emptyState: some View {
        VStack(spacing: 14) {
            Image(systemName: "tray")
                .font(.system(size: 44, weight: .light))
                .foregroundStyle(.quaternary)
            Text("Kira geçmişi bulunamadı")
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(.secondary)
            Text("Henüz bir kira ödemesi kaydedilmemiş.")
                .font(.system(size: 13))
                .foregroundStyle(.tertiary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 40)
    }
}

// MARK: - RentHistoryRowView

struct RentHistoryRowView: View {

    let item: RentHistory
    
    var body: some View {
        HStack(spacing: 14) {

            // MARK: Thumbnail
            thumbnailView
            
            // MARK: Center Info
            VStack(alignment: .leading, spacing: 4) {
                Text(item.assetTitle ?? item.assetId)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(.primary)
                    .lineLimit(1)
                
                HStack(spacing: 6) {
                    if let city = item.propertyCity {
                        Text(city)
                            .font(.system(size: 12))
                            .foregroundStyle(.secondary)
                    }
                    if item.propertyCity != nil {
                        Text("·")
                            .foregroundStyle(.tertiary)
                            .font(.system(size: 12))
                    }
                    Text(item.periodLabel)
                        .font(.system(size: 12))
                        .foregroundStyle(.secondary)
                }
                
                Text(item.transactionId)
                    .font(.system(size: 12))
                    .foregroundStyle(.tertiary)
                    .lineLimit(1)
            }
            
            Spacer(minLength: 4)
            
            // MARK: Amount + Share
            VStack(alignment: .trailing, spacing: 3) {
                AmountBadge(
                    price: item.formattedAmount
                )
                
                if let i = item.sharePercent{
                    ChangeBadge(
                        change: i.percentFormatted,
                        isPositive: i > 0.0
                    )
                }
            }
        }
        .padding(.vertical, 7)
        .padding(.horizontal, 15)
        .background(Color.hsBackgroundSecondary)
    }

    // MARK: - Thumbnail

    @ViewBuilder
    private var thumbnailView: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10, style: .continuous)
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
                            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
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
            .font(.system(size: 20, weight: .medium))
            .foregroundStyle(assetColor(item.assetType))
    }

    // MARK: - Helpers

    private func assetIconName(_ type: String) -> String {
        switch type.lowercased() {
        case "apartment", "konut": return "building.2"
        case "office", "ofis":    return "building.columns"
        case "land", "arsa":      return "map"
        case "shop", "dukkan":    return "storefront"
        default:                  return "house"
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

    private func shareColor(_ pct: Double?) -> Color {
        guard let pct else { return .gray }
        switch pct {
        case ..<5:   return .gray
        case 5..<15: return .teal
        case 15..<30: return .blue
        default:     return .indigo
        }
    }
}
