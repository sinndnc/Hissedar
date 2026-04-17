//
//  RentHistoryDetailView.swift
//  Hissedar
//
//  Created by Sinan Dinç on 4/13/26.
//

import SwiftUI
import Factory

// MARK: - RentHistoryDetailView

struct RentHistoryDetailView: View {

    let item: RentHistory

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                headerCard
                detailsCard
                if item.description != nil {
                    descriptionCard
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 16)
            .padding(.bottom, 40)
        }
        .background(Color.hsBackground)
        .navigationTitle("Kira Detayı")
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Header Card

    private var headerCard: some View {
        VStack(spacing: 16) {

            // Thumbnail
            ZStack {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(assetColor(item.assetType).opacity(0.12))
                    .frame(width: 72, height: 72)

                if let urlStr = item.assetImageUrl, let url = URL(string: urlStr) {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .success(let image):
                            image
                                .resizable()
                                .scaledToFill()
                                .frame(width: 72, height: 72)
                                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                        default:
                            assetIcon(size: 30)
                        }
                    }
                } else {
                    assetIcon(size: 30)
                }
            }

            // Asset Title
            VStack(spacing: 4) {
                Text(item.assetTitle ?? item.assetId)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(.primary)
                    .multilineTextAlignment(.center)

                if let city = item.propertyCity {
                    HStack(spacing: 4) {
                        Image(systemName: "mappin.circle.fill")
                            .font(.system(size: 12))
                            .foregroundStyle(.secondary)
                        Text(city)
                            .font(.system(size: 13))
                            .foregroundStyle(.secondary)
                    }
                }
            }

            // Amount + Period
            VStack(spacing: 6) {
                Text(item.formattedAmount)
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundStyle(assetColor(item.assetType))

                Text(item.periodLabel)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 4)
                    .background(.ultraThinMaterial, in: Capsule())
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
        .padding(.horizontal, 16)
        .background(Color.hsBackgroundSecondary)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    // MARK: - Details Card

    private var detailsCard: some View {
        VStack(spacing: 0) {
            detailRow(
                icon: "calendar",
                iconColor: .blue,
                title: "Ödeme Tarihi",
                value: formattedPaidAt
            )
            Divider().padding(.leading, 44)

            detailRow(
                icon: assetIconName(item.assetType),
                iconColor: assetColor(item.assetType),
                title: "Varlık Türü",
                value: item.assetType.capitalized
            )
            Divider().padding(.leading, 44)

            if let sharePercent = item.sharePercent {
                detailRow(
                    icon: "chart.pie.fill",
                    iconColor: shareColor(sharePercent),
                    title: "Pay Yüzdesi",
                    value: sharePercent.percentFormatted
                )
                Divider().padding(.leading, 44)
            }

            if let totalRent = item.propertyTotalRent {
                detailRow(
                    icon: "building.2.fill",
                    iconColor: .indigo,
                    title: "Toplam Mülk Kirası",
                    value: CurrencyFormatter.format(totalRent, currency: .TRY)
                )
                Divider().padding(.leading, 44)
            }

            detailRow(
                icon: "number",
                iconColor: .gray,
                title: "İşlem ID",
                value: item.transactionId,
                isMonospaced: true
            )
        }
        .background(Color.hsBackgroundSecondary)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    // MARK: - Description Card

    private var descriptionCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("Açıklama", systemImage: "text.alignleft")
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(.secondary)

            Text(item.description ?? "")
                .font(.system(size: 15))
                .foregroundStyle(.primary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(Color.hsBackgroundSecondary)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    // MARK: - Detail Row

    private func detailRow(
        icon: String,
        iconColor: Color,
        title: String,
        value: String,
        isMonospaced: Bool = false
    ) -> some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .fill(iconColor.opacity(0.12))
                    .frame(width: 32, height: 32)
                Image(systemName: icon)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(iconColor)
            }

            Text(title)
                .font(.system(size: 15))
                .foregroundStyle(.primary)

            Spacer()

            Text(value)
                .font(isMonospaced
                    ? .system(size: 12, weight: .regular, design: .monospaced)
                    : .system(size: 14, weight: .medium))
                .foregroundStyle(isMonospaced ? .tertiary : .secondary)
                .lineLimit(1)
                .truncationMode(isMonospaced ? .middle : .tail)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }

    // MARK: - Helpers

    private var formattedPaidAt: String {
        guard let date = item.paidAt else { return "—" }
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "tr_TR")
        formatter.dateStyle = .long
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }

    private func assetIcon(size: CGFloat) -> some View {
        Image(systemName: assetIconName(item.assetType))
            .font(.system(size: size, weight: .medium))
            .foregroundStyle(assetColor(item.assetType))
    }

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

    private func shareColor(_ pct: Double) -> Color {
        switch pct {
        case ..<5:    return .gray
        case 5..<15:  return .teal
        case 15..<30: return .blue
        default:      return .indigo
        }
    }
}
