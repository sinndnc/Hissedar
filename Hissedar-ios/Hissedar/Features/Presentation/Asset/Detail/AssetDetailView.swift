//
//  AssetDetailView.swift
//  Hissedar
//
//  Market-grade yeniden tasarım — premium fintech seviyesi
//

import SwiftUI
import Factory

struct AssetDetailView: View {
    
    let assetId: String
    
    @Injected(\.marketViewModel) private var vm
    @State private var headerOpacity: Double = 0
    @State private var heroScale: Double = 1.0
    
    private var detail: AssetDetail? { vm.selectedDetail }
    
    var body: some View {
        AssetDetailWrapper(
            itemId: assetId,
            itemType: detail?.assetType.rawValue ?? "",
            isLoading: vm.isLoadingDetail,
            hasItem: detail != nil,
            emptyMessage: "Varlık bulunamadı",
            loadAction: { await vm.fetchDetail(id: assetId) },
            toDisplayItem: { detail!.toDisplayItem }
        ) {
            if let detail {
                contentView(detail)
            }
        }
    }
    private func contentView(_ detail: AssetDetail) -> some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                heroSection(detail)
                
                VStack(spacing: 0) {
                    priceSection(detail)
                    specificSection(detail)
                }
                .padding(.top, 20)
                .padding(.bottom, 100)
            }
        }
        .scrollIndicators(.hidden)
        .ignoresSafeArea(edges: .top)
    }

    // MARK: - Hero

    private func heroSection(_ detail: AssetDetail) -> some View {
        ZStack(alignment: .bottomLeading) {
            heroBackground(detail)
            
            VStack(alignment: .leading, spacing: 6) {
                assetTypePill(detail)
                
                Text(detail.title)
                    .font(.system(size: 24, weight: .bold, design: .default))
                    .foregroundStyle(.white)
                    .lineLimit(2)
                
                if let subtitle = detail.subtitle {
                    HStack(spacing: 5) {
                        Image(systemName: "mappin.circle.fill")
                            .font(.system(size: 12))
                            .foregroundStyle(Color.hsPurple400)
                        Text("\(subtitle) • \(detail.category)")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundStyle(.white.opacity(0.55))
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 20)
            .padding(.bottom, 20)
        }
        .frame(height: 260)
    }
    
    private func heroBackground(_ detail: AssetDetail) -> some View {
        ZStack {
            // Arka plan rengi / görsel
            Group {
                if let url = detail.imageUrl, !url.isEmpty {
                    AsyncImage(url: URL(string: url)) { phase in
                        switch phase {
                        case .success(let img):
                            img.resizable().scaledToFill()
                        default:
                            assetGradientBG(detail)
                        }
                    }
                } else {
                    assetGradientBG(detail)
                }
            }
            .clipped()
            
            // Gradient overlay
            LinearGradient(
                stops: [
                    .init(color: .clear, location: 0),
                    .init(color: Color.hsBackground.opacity(0.3), location: 0.4),
                    .init(color: Color.hsBackground, location: 1)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
        }
    }
    
    private func assetGradientBG(_ detail: AssetDetail) -> some View {
        ZStack {
            Color.hsBackgroundSecondary
            
            // Asset tipine göre accent rengi
            let accent = detail.assetType.accentColor
            RadialGradient(
                colors: [accent.opacity(0.35), .clear],
                center: .init(x: 0.3, y: 0.4),
                startRadius: 0,
                endRadius: 200
            )
            RadialGradient(
                colors: [accent.opacity(0.18), .clear],
                center: .init(x: 0.85, y: 0.15),
                startRadius: 0,
                endRadius: 140
            )
            
            // Büyük icon
            Image(systemName: detail.assetType.icon)
                .font(.system(size: 80, weight: .ultraLight))
                .foregroundStyle(accent.opacity(0.12))
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
                .padding(.trailing, 24)
                .padding(.bottom, 40)
        }
    }
    
    private func assetTypePill(_ detail: AssetDetail) -> some View {
        HStack(spacing: 5) {
            Circle()
                .fill(detail.assetType.accentColor)
                .frame(width: 5, height: 5)
            Text(detail.assetType.label.uppercased())
                .font(.system(size: 10, weight: .bold))
                .tracking(1.2)
                .foregroundStyle(detail.assetType.accentColor)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
        .background(detail.assetType.accentColor.opacity(0.12))
        .overlay(
            Capsule().strokeBorder(detail.assetType.accentColor.opacity(0.3), lineWidth: 0.5)
        )
        .clipShape(Capsule())
    }
    
    // MARK: - Price Section
    @State private var selectedTimeRange = "1H" // Seçili tarih sekmesi
    let timeRanges = ["1G", "1H", "1A", "1Y", "Tümü"]
    
    private func priceSection(_ detail: AssetDetail) -> some View {
        PriceChartView()
    }

    // MARK: - Type-specific Sections
    @ViewBuilder
    private func specificSection(_ detail: AssetDetail) -> some View {
        switch detail.assetType {
        case .property: propertySection(detail)
        case .art:      artSection(detail)
        case .nft:      nftSection(detail)
        }
    }

    // MARK: Property

    private func propertySection(_ d: AssetDetail) -> some View {
        VStack(spacing: 0) {
            FundingStatusCard(detail: d)
            Divider()
            PropertyInfoCard(detail: d)
            Divider()
            BlockchainVerifyCard(detail: d)
            Divider()
//            PropertyStatsGrid(detail: d)
        }
    }

    // MARK: Art

    private func artSection(_ d: AssetDetail) -> some View {
        SectionCard(title: "Eser Detayları", icon: "paintpalette.fill") {
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 8) {
                EnhancedStatCard(title: "Sanatçı",  value: d.artArtistName ?? "—",                   icon: "person.fill",       accent: .hsPurple600)
                EnhancedStatCard(title: "Yıl",      value: d.artYearCreated.map { "\($0)" } ?? "—",  icon: "calendar",          accent: .hsPurple400)
                EnhancedStatCard(title: "Teknik",   value: d.artMedium ?? "—",                       icon: "paintpalette.fill", accent: .hsLavender)
                EnhancedStatCard(title: "Boyut",    value: d.artDimensions ?? "—",                   icon: "ruler",             accent: .hsSuccess)
            }
        }
    }

    // MARK: NFT

    private func nftSection(_ d: AssetDetail) -> some View {
        SectionCard(title: "NFT Bilgileri", icon: "cube.fill") {
            VStack(spacing: 0) {
                InfoRow(icon: "square.grid.3x3.fill", label: "Koleksiyon", value: d.nftCollectionName ?? "—")
                InfoRow(icon: "number",               label: "Token ID",   value: d.nftTokenId.map { "#\($0)" } ?? "—")
                InfoRow(icon: "link",                 label: "Blockchain", value: d.nftBlockchain ?? "—")
                InfoRow(icon: "doc.text.fill",        label: "Kontrat",    value: d.nftContractAddress ?? "—", isCode: true)
            }
        }
    }
}

// MARK: - PriceChangeBadge

struct PriceChangeBadge: View {
    let isPositive: Bool
    let formattedChange: String
    
    private var color: Color { isPositive ? .hsSuccess : .hsError }
    private var icon: String { isPositive ? "arrow.up.right" : "arrow.down.right" }
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 11, weight: .bold))
            Text(formattedChange)
                .font(.system(size: 14, weight: .bold, design: .monospaced))
        }
        .foregroundStyle(color)
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(color.opacity(0.1))
        .overlay(Capsule().strokeBorder(color.opacity(0.25), lineWidth: 0.5))
        .clipShape(Capsule())
    }
}

// MARK: - FundingStatusCard

struct FundingStatusCard: View {
    let detail: AssetDetail

    private var percent: Double { detail.fundingPercent }
    private var progressColor: Color { progressTint(percent) }

    var body: some View {
        SectionCard(title: "Fonlama Durumu", icon: "chart.bar.fill") {
            VStack(spacing: 14) {
                HStack(alignment: .firstTextBaseline) {
                    Text("\(detail.soldTokens ?? 0) / \(detail.totalTokens ?? 0)")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(Color.hsTextPrimary)
                    Text("token")
                        .font(.system(size: 13))
                        .foregroundStyle(Color.hsTextSecondary)
                    Spacer()
                    Text(String(format: "%.1f%%", percent))
                        .font(.system(size: 16, weight: .bold, design: .monospaced))
                        .foregroundStyle(progressColor)
                }
                
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(Color.hsBackgroundTertiary)
                            .frame(height: 8)
                        Capsule()
                            .fill(
                                LinearGradient(
                                    colors: [progressColor.opacity(0.7), progressColor],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(width: max(8, geo.size.width * CGFloat(percent / 100)), height: 8)
                    }
                }
                .frame(height: 8)

                HStack {
                    Label("\(detail.remainingTokens ?? 0) token kaldı", systemImage: "ticket.fill")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(Color.hsTextSecondary)

                    Spacer()

                    if let status = detail.status {
                        StatusPill(status: status)
                    }
                }
            }
        }
    }

    private func progressTint(_ p: Double) -> Color {
        switch p {
        case ..<50:  return .hsPurple400
        case ..<80:  return Color.hsPurple600
        default:     return .hsSuccess
        }
    }
}

// MARK: - StatusPill

struct StatusPill: View {
    let status: AssetStatus

    private var label: String {
        switch status {
        case .active:   return "Aktif"
        case .funded:   return "Fonlandı"
        case .upcoming: return "Yakında"
        case .soldOut:  return "Tükendi"
        case .paused:   return "Durduruldu"
        case .draft:    return "Taslak"
        }
    }

    private var color: Color {
        switch status {
        case .active:   return .hsPurple400
        case .funded:   return .hsSuccess
        case .upcoming: return Color.hsLavender
        case .soldOut:  return .hsError
        case .paused:   return Color.hsTextSecondary
        case .draft:    return Color.hsTextSecondary
        }
    }

    var body: some View {
        Text(label.uppercased())
            .font(.system(size: 10, weight: .bold))
            .tracking(0.8)
            .foregroundStyle(color)
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(color.opacity(0.1))
            .overlay(Capsule().strokeBorder(color.opacity(0.3), lineWidth: 0.5))
            .clipShape(Capsule())
    }
}

// MARK: - PropertyStatsGrid

struct PropertyStatsGrid: View {
    let detail: AssetDetail

    var body: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 8) {
            EnhancedStatCard(
                title: "Toplam Değer",
                value: detail.totalValue.map { "₺\(formatValue($0))" } ?? "—",
                icon: "building.columns.fill",
                accent: .hsPurple600
            )
            EnhancedStatCard(
                title: "Yıllık Getiri",
                value: detail.annualYield.map { String(format: "%%%.1f", $0) } ?? "—",
                icon: "percent",
                accent: .hsSuccess
            )
            EnhancedStatCard(
                title: "Aylık Kira",
                value: detail.propertyMonthlyRent.map { "₺\(formatValue($0))" } ?? "—",
                icon: "calendar.badge.checkmark",
                accent: Color.hsLavender
            )
            EnhancedStatCard(
                title: "SPV",
                value: detail.propertySpvName ?? "—",
                icon: "building.fill",
                accent: .hsPurple400,
                smallValue: true
            )
        }
    }

    private func formatValue(_ decimal: Decimal) -> String {
        NSDecimalNumber(decimal: decimal).intValue.formatted()
    }
}

// MARK: - EnhancedStatCard

struct EnhancedStatCard: View {
    let title: String
    let value: String
    let icon: String
    let accent: Color
    var smallValue: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(accent)
                .frame(width: 30, height: 30)
                .background(accent.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 8))

            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.system(size: 10, weight: .semibold))
                    .tracking(0.6)
                    .foregroundStyle(Color.hsTextSecondary.opacity(0.7))
                    .lineLimit(1)

                Text(value)
                    .font(.system(
                        size: smallValue ? 14 : 18,
                        weight: .bold,
                        design: value.first?.isNumber == true ? .monospaced : .default
                    ))
                    .foregroundStyle(accent == .hsSuccess ? .hsSuccess : Color.hsTextPrimary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(Color.hsBackgroundSecondary)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .strokeBorder(Color.hsBorder, lineWidth: 0.5)
        )
    }
}

// MARK: - PropertyInfoCard

struct PropertyInfoCard: View {
    let detail: AssetDetail

    var body: some View {
        SectionCard(title: "Mülk Bilgileri", icon: "mappin.and.ellipse") {
            VStack(spacing: 0) {
                InfoRow(icon: "mappin",       label: "Adres",         value: detail.propertyAddress ?? "—")
                InfoRow(icon: "building.2",   label: "Şehir",         value: detail.propertyCity ?? "—")
                InfoRow(icon: "tag.fill",      label: "Kategori",      value: detail.category)
                InfoRow(icon: "number",        label: "Toplam Token",  value: "\(detail.totalTokens ?? 0) HSR", isLast: true)
            }
        }
    }
}

// MARK: - InfoRow

struct InfoRow: View {
    let icon: String
    let label: String
    let value: String
    var isCode: Bool = false
    var isLast: Bool = false
    
    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(Color.hsPurple400)
                .frame(width: 28, height: 28)
                .background(Color.hsPurple400.opacity(0.08))
                .clipShape(RoundedRectangle(cornerRadius: 7))
            
            Text(label)
                .font(.system(size: 14))
                .foregroundStyle(Color.hsTextSecondary)
            
            Spacer()
            
            Text(value)
                .font(isCode ? .system(size: 12, design: .monospaced) : .system(size: 14, weight: .semibold))
                .foregroundStyle(Color.hsTextPrimary)
                .lineLimit(1)
                .truncationMode(.middle)
        }
        .padding(.vertical, 5)
        .overlay(alignment: .bottom) {
            if !isLast {
                Divider().padding(.leading, 40)
            }
        }
    }
}

// MARK: - SectionCard

struct SectionCard<Content: View>: View {
    let title: String
    let icon: String
    @ViewBuilder let content: () -> Content
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 5) {
                Image(systemName: icon)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(Color.hsPurple400)
                Text(title)
                    .font(.system(size: 15, weight: .bold))
                    .foregroundStyle(Color.hsTextPrimary)
            }
            
            content()
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.hsBackgroundSecondary)
    }
}

// MARK: - AssetType Extension

extension AssetType {
    var accentColor: Color {
        switch self {
        case .property: return Color.hsPurple400
        case .art:      return Color.hsLavender
        case .nft:      return Color(red: 0.2, green: 0.8, blue: 0.6)
        }
    }
}
