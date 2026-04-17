//
//  SearchView.swift
//  Hissedar
//
//  Keşfet ekranı — fake arama çubuğu, 3 segment picker,
//  kategorize edilmiş keşif item'ları.
//  SearchViewModel'i sahiplenir, ActiveSearchView ile paylaşır.
//

import SwiftUI

// MARK: - Discovery Item Model

struct DiscoveryItem: Identifiable, Hashable {
    let id = UUID()
    let title: String
    let subtitle: String
    let icon: String
    let badge: String?
    let filter: DiscoveryFilter
    
    func hash(into hasher: inout Hasher) { hasher.combine(id) }
    static func == (lhs: DiscoveryItem, rhs: DiscoveryItem) -> Bool { lhs.id == rhs.id }
}

// MARK: - Discovery Section Model

struct DiscoverySection: Identifiable {
    let id = UUID()
    let title: String
    let icon: String
    let items: [DiscoveryItem]
}

// MARK: - SearchView

struct SearchView: View {
    
    @State private var viewModel = SearchViewModel()
    @State private var showActiveSearch = false
    @Environment(ThemeManager.self) private var themeManager
    
    var body: some View {
        NavigationStack {
            ZStack {
                themeManager.theme.background
                    .ignoresSafeArea()
                
                ScrollView(.vertical, showsIndicators: false) {
                    LazyVStack(spacing: 0, pinnedViews: .sectionHeaders) {
                        Section {
                            discoveryContent
                        } header: {
                            searchBarSection
                        }
                    }
                    .padding(.bottom, 100)
                }
            }
            .toolbar{ toolbar }
            .navigationBarTitleDisplayMode(.inline)
            .toolbarVisibility(.visible, for: .navigationBar)
            .toolbarBackground(themeManager.theme.background, for: .navigationBar)
            .task {
                await viewModel.loadAssets()
            }
            .fullScreenCover(isPresented: $showActiveSearch) {
                NavigationStack {
                    ActiveSearchView(viewModel: viewModel)
                }
            }
            .navigationDestination(for: DiscoveryFilter.self) { filter in
                FilteredAssetsView(
                    filter: filter,
                    assets: filter.apply(to: viewModel.assets)
                )
            }
            .navigationDestination(for: AssetItem.self) { asset in
                AssetDetailView(assetId: asset.id)
            }
        }
    }
    
    
    @ToolbarContentBuilder
    private var toolbar: some ToolbarContent {
        ToolbarItem(placement: .principal) {
            Text(String.localized("search.nav_title"))
                .font(.system(size: 17, weight: .bold))
                .foregroundColor(themeManager.theme.textPrimary)
        }
    }
    
    // MARK: - Search Bar (Fake)
    private var searchBarSection: some View {
        Button {
            showActiveSearch = true
        } label: {
            HStack(spacing: 10) {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(themeManager.theme.textTertiary)
                
                Text(String.localized("search.placeholder"))
                    .lineLimit(1)
                    .font(.system(size: 15))
                    .foregroundColor(themeManager.theme.textTertiary)
                
                Spacer()
                
                Image(systemName: "mic.fill")
                    .font(.system(size: 14))
                    .foregroundColor(themeManager.theme.accent)
                    .frame(width: 32, height: 32)
                    .background(themeManager.theme.accent.opacity(0.12))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .background(themeManager.theme.backgroundSecondary)
            .clipShape(RoundedRectangle(cornerRadius: 14))
        }
        .padding(.bottom, 16)
        .padding(.horizontal, 20)
        .background(themeManager.theme.background)
    }
    
    
    // MARK: - Discovery Content
    private var discoveryContent: some View {
        LazyVStack(spacing: 28) {
            ForEach(allSections) { section in
                sectionView(section)
            }
        }
    }
    
    private func sectionView(_ section: DiscoverySection) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: section.icon)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(themeManager.theme.accent)
                
                Text(section.title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(themeManager.theme.textPrimary)
                
                Spacer()
            }
            .padding(.horizontal)
            
            VStack(spacing: 0) {
                ForEach(Array(section.items.enumerated()), id: \.element.id) { index, item in
                    discoveryItemRow(item)
                    
                    if index < section.items.count - 1 {
                        Divider()
                            .background(themeManager.theme.border)
                            .padding(.leading, 62)
                    }
                }
            }
            .background(themeManager.theme.backgroundSecondary)
        }
    }
    
    private func discoveryItemRow(_ item: DiscoveryItem) -> some View {
        NavigationLink(value: item.filter) {
            HStack(spacing: 12) {
                Image(systemName: item.icon)
                    .font(.system(size: 16))
                    .frame(width: 36, height: 36)
                    .foregroundColor(themeManager.theme.accent)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(item.title)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(themeManager.theme.textPrimary)
                        .lineLimit(1)
                    
                    Text(item.subtitle)
                        .font(.system(size: 12))
                        .foregroundColor(themeManager.theme.textTertiary)
                        .lineLimit(1)
                }
                
                Spacer()
                
                if let badge = item.badge {
                    Text(badge)
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(themeManager.theme.accent)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(themeManager.theme.accent.opacity(0.12))
                        .clipShape(Capsule())
                }
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(themeManager.theme.textSecondary)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
        }
        .buttonStyle(.plain)
    }
    
    // MARK: - Section Data
    
    private var allSections: [DiscoverySection] {
        [
            DiscoverySection(
                title: String.localized("search.section.market.title"),
                icon: "chart.line.uptrend.xyaxis",
                items: [
                    DiscoveryItem(
                        title: String.localized("search.item.top_gainers.title"),
                        subtitle: String.localized("search.item.top_gainers.subtitle"),
                        icon: "flame.fill",
                        badge: String.localized("search.badge.hot"),
                        filter: .topGainers7d
                    ),
                    DiscoveryItem(
                        title: String.localized("search.item.monthly_gainers.title"),
                        subtitle: String.localized("search.item.monthly_gainers.subtitle"),
                        icon: "arrow.up.right.circle.fill",
                        badge: nil,
                        filter: .topGainers30d
                    ),
                    DiscoveryItem(
                        title: String.localized("search.item.highest_yield.title"),
                        subtitle: String.localized("search.item.highest_yield.subtitle"),
                        icon: "banknote.fill",
                        badge: nil,
                        filter: .highestYield
                    ),
                ]
            ),
            DiscoverySection(
                title: String.localized("search.section.opportunity.title"),
                icon: "sparkles",
                items: [
                    DiscoveryItem(
                        title: String.localized("search.item.high_potential.title"),
                        subtitle: String.localized("search.item.high_potential.subtitle"),
                        icon: "arrow.up.forward.square.fill",
                        badge: String.localized("search.badge.featured"),
                        filter: .highPotential
                    ),
                    DiscoveryItem(
                        title: String.localized("search.item.almost_full.title"),
                        subtitle: String.localized("search.item.almost_full.subtitle"),
                        icon: "hourglass.tophalf.filled",
                        badge: String.localized("search.badge.hurry"),
                        filter: .almostFull
                    ),
                    DiscoveryItem(
                        title: String.localized("search.item.newly_added.title"),
                        subtitle: String.localized("search.item.newly_added.subtitle"),
                        icon: "plus.circle.fill",
                        badge: String.localized("search.badge.new"),
                        filter: .newlyAdded
                    ),
                    DiscoveryItem(
                        title: String.localized("search.item.early_entry.title"),
                        subtitle: String.localized("search.item.early_entry.subtitle"),
                        icon: "target",
                        badge: nil,
                        filter: .earlyEntry
                    ),
                ]
            ),
            DiscoverySection(
                title: String.localized("search.section.social.title"),
                icon: "person.3.fill",
                items: [
                    DiscoveryItem(
                        title: String.localized("search.item.most_investors.title"),
                        subtitle: String.localized("search.item.most_investors.subtitle"),
                        icon: "person.2.fill",
                        badge: nil,
                        filter: .mostInvestors
                    ),
                    DiscoveryItem(
                        title: String.localized("search.item.most_traded.title"),
                        subtitle: String.localized("search.item.most_traded.subtitle"),
                        icon: "arrow.left.arrow.right.circle.fill",
                        badge: String.localized("search.badge.active"),
                        filter: .mostTradedWeekly
                    ),
                    DiscoveryItem(
                        title: String.localized("search.item.most_watchlist.title"),
                        subtitle: String.localized("search.item.most_watchlist.subtitle"),
                        icon: "star.fill",
                        badge: nil,
                        filter: .mostWatchlisted
                    ),
                ]
            ),
            DiscoverySection(
                title: String.localized("search.section.personal.title"),
                icon: "person.crop.circle.badge.checkmark",
                items: [
                    DiscoveryItem(
                        title: String.localized("search.item.personal_rec.title"),
                        subtitle: String.localized("search.item.personal_rec.subtitle"),
                        icon: "wand.and.stars",
                        badge: "AI",
                        filter: .personalRecommendation
                    ),
                    DiscoveryItem(
                        title: String.localized("search.item.likely_to_enjoy.title"),
                        subtitle: String.localized("search.item.likely_to_enjoy.subtitle"),
                        icon: "heart.fill",
                        badge: nil,
                        filter: .likelyToEnjoy
                    ),
                    DiscoveryItem(
                        title: String.localized("search.item.similar_watchlist.title"),
                        subtitle: String.localized("search.item.similar_watchlist.subtitle"),
                        icon: "square.on.square",
                        badge: nil,
                        filter: .similarToWatchlist
                    ),
                ]
            ),
            DiscoverySection(
                title: String.localized("search.section.regional.title"),
                icon: "map.fill",
                items: [
                    DiscoveryItem(
                        title: String.localized("search.item.in_your_city.title"),
                        subtitle: String.localized("search.item.in_your_city.subtitle"),
                        icon: "location.fill",
                        badge: nil,
                        filter: .inYourCity
                    ),
                    DiscoveryItem(
                        title: String.localized("search.item.best_by_region.title"),
                        subtitle: String.localized("search.item.best_by_region.subtitle"),
                        icon: "map.circle.fill",
                        badge: nil,
                        filter: .bestByRegion
                    ),
                    DiscoveryItem(
                        title: String.localized("search.item.rising_regions.title"),
                        subtitle: String.localized("search.item.rising_regions.subtitle"),
                        icon: "chart.line.uptrend.xyaxis.circle.fill",
                        badge: String.localized("search.badge.trend"),
                        filter: .risingRegions
                    ),
                ]
            ),
        ]
    }
}

// MARK: - FilteredAssetsView

struct FilteredAssetsView: View {
    
    let filter: DiscoveryFilter
    let assets: [AssetItem]
    @Environment(ThemeManager.self) private var themeManager
    
    var body: some View {
        ZStack {
            themeManager.theme.background
                .ignoresSafeArea()
            
            if assets.isEmpty {
                VStack(spacing: 16) {
                    Image(systemName: "tray")
                        .font(.system(size: 44))
                        .foregroundColor(themeManager.theme.textTertiary)
                    
                    Text(String.localized("search.empty.title"))
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(themeManager.theme.textPrimary)
                    
                    Text(String.localized("search.empty.subtitle"))
                        .font(.system(size: 14))
                        .foregroundColor(themeManager.theme.textSecondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.horizontal, 40)
            } else {
                ScrollView(.vertical, showsIndicators: false) {
                    LazyVStack(spacing: 0) {
                        ForEach(assets) { asset in
                            NavigationLink(value: asset) {
                                assetRow(asset)
                            }
                            if assets.last?.id != asset.id {
                                Divider()
                                    .background(themeManager.theme.border)
                            }
                        }
                    }
                    .padding(.top)
                }
            }
        }
        .navigationTitle(filter.title)
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func assetRow(_ asset: AssetItem) -> some View {
        HStack(spacing: 14) {
            Image(systemName: asset.icon)
                .font(.system(size: 18))
                .foregroundColor(themeManager.theme.accent)
                .frame(width: 44, height: 44)
                .background(themeManager.theme.accent.opacity(0.12))
                .clipShape(RoundedRectangle(cornerRadius: 12))
            
            VStack(alignment: .leading, spacing: 4) {
                Text(asset.title)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(themeManager.theme.textPrimary)
                    .lineLimit(1)
                
                HStack(spacing: 6) {
                    Text(asset.category)
                        .font(.system(size: 12))
                        .foregroundColor(themeManager.theme.textTertiary)
                    
                    if let city = asset.propertyCity {
                        Text("·")
                            .font(.system(size: 12))
                            .foregroundColor(themeManager.theme.textTertiary)
                        Text(city)
                            .font(.system(size: 12))
                            .foregroundColor(themeManager.theme.textTertiary)
                    }
                }
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text(asset.formattedPrice)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(themeManager.theme.textPrimary)
                
                Text(asset.formattedChange)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(asset.isPositive ? themeManager.theme.success : themeManager.theme.error)
            }
        }
        .padding(14)
        .background(themeManager.theme.backgroundSecondary)
    }
}
