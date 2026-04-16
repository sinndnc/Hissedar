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
    let iconColor: Color
    let badge: String?
    let badgeColor: Color
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
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.hsBackground
                    .ignoresSafeArea()
                
                ScrollView(.vertical, showsIndicators: false) {
                    LazyVStack(spacing: 0,pinnedViews: .sectionHeaders) {
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
            .toolbarBackground(Color.hsBackground,for: .navigationBar)
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
    private var toolbar: some ToolbarContent{
        ToolbarItem(placement: .principal) {
            Text("Keşfet")
                .foregroundColor(.hsTextPrimary)
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
                    .foregroundColor(.hsTextTertiary)
                
                Text("Gayrimenkul, bölge veya şehir ara...")
                    .lineLimit(1)
                    .font(.system(size: 15))
                    .foregroundColor(.hsTextTertiary)
                
                Spacer()
                
                Image(systemName: "mic.fill")
                    .font(.system(size: 14))
                    .foregroundColor(.hsPurple600)
                    .frame(width: 32, height: 32)
                    .background(Color.hsPurple600.opacity(0.12))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .background(Color.hsBackgroundSecondary)
            .clipShape(RoundedRectangle(cornerRadius: 14))
        }
        .padding(.bottom, 16)
        .padding(.horizontal, 20)
        .background(Color.hsBackground)
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
                    .foregroundColor(.hsPurple400)
                
                Text(section.title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.hsTextPrimary)
                
                Spacer()
            }
            .padding(.horizontal)
            
            VStack(spacing: 0) {
                ForEach(Array(section.items.enumerated()), id: \.element.id) { index, item in
                    discoveryItemRow(item)
                    
                    if index < section.items.count - 1 {
                        Divider()
                            .background(Color.hsBorder)
                            .padding(.leading, 62)
                    }
                }
            }
            .background(Color.hsBackgroundSecondary)
        }
    }
    
    private func discoveryItemRow(_ item: DiscoveryItem) -> some View {
        NavigationLink(value: item.filter) {
            HStack(spacing: 12) {
                Image(systemName: item.icon)
                    .font(.system(size: 16))
                    .foregroundColor(.white)
                    .frame(width: 36, height: 36)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(item.title)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.hsTextPrimary)
                        .lineLimit(1)
                    
                    Text(item.subtitle)
                        .font(.system(size: 12))
                        .foregroundColor(.hsTextTertiary)
                        .lineLimit(1)
                }
                
                Spacer()
                
                if let badge = item.badge {
                    Text(badge)
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(item.badgeColor)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(item.badgeColor.opacity(0.12))
                        .clipShape(Capsule())
                }
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.hsTextTertiary)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
        }
    }
    
    // MARK: - Section Data
    
    private var allSections: [DiscoverySection] {
        [
            DiscoverySection(title: "Piyasa performansı", icon: "chart.line.uptrend.xyaxis", items: [
                DiscoveryItem(title: "En çok yükselen", subtitle: "Son 7 günde en fazla değer kazanan", icon: "flame.fill", iconColor: .hsError, badge: "Sıcak", badgeColor: .hsError, filter: .topGainers7d),
                DiscoveryItem(title: "En çok değer kazanan (30 gün)", subtitle: "Aylık bazda en yüksek getiri", icon: "arrow.up.right.circle.fill", iconColor: .hsSuccess, badge: nil, badgeColor: .clear, filter: .topGainers30d),
                DiscoveryItem(title: "En yüksek kira getirisi", subtitle: "Yıllık kira getirisi en yüksek mülkler", icon: "banknote.fill", iconColor: .hsSuccess, badge: nil, badgeColor: .clear, filter: .highestYield),
            ]),
            DiscoverySection(title: "Fırsat odaklı", icon: "sparkles", items: [
                DiscoveryItem(title: "En çok potansiyel sahibi olanlar", subtitle: "Değer artışı potansiyeli yüksek mülkler", icon: "arrow.up.forward.square.fill", iconColor: .hsPurple600, badge: "Öne Çıkan", badgeColor: .hsPurple400, filter: .highPotential),
                DiscoveryItem(title: "Dolmak üzere olanlar", subtitle: "Token satışı kapanmak üzere", icon: "hourglass.tophalf.filled", iconColor: .hsWarning, badge: "Acele et", badgeColor: .hsWarning, filter: .almostFull),
                DiscoveryItem(title: "Yeni eklenenler", subtitle: "Platforma yeni eklenen gayrimenkuller", icon: "plus.circle.fill", iconColor: .hsPurple400, badge: "Yeni", badgeColor: .hsPurple400, filter: .newlyAdded),
                DiscoveryItem(title: "Erken giriş fırsatları", subtitle: "Düşük doluluk + yüksek potansiyel", icon: "target", iconColor: .hsPurple600, badge: nil, badgeColor: .clear, filter: .earlyEntry),
            ]),
            DiscoverySection(title: "Sosyal kanıt", icon: "person.3.fill", items: [
                DiscoveryItem(title: "En çok yatırımcı çeken", subtitle: "En fazla yatırımcıya sahip mülkler", icon: "person.2.fill", iconColor: .hsPurple400, badge: nil, badgeColor: .clear, filter: .mostInvestors),
                DiscoveryItem(title: "Bu hafta en çok işlem gören", subtitle: "Haftalık en aktif tokenlar", icon: "arrow.left.arrow.right.circle.fill", iconColor: .hsSuccess, badge: "Aktif", badgeColor: .hsSuccess, filter: .mostTradedWeekly),
                DiscoveryItem(title: "Watchlist'e en çok eklenen", subtitle: "Kullanıcıların en çok takip ettiği", icon: "star.fill", iconColor: .hsWarning, badge: nil, badgeColor: .clear, filter: .mostWatchlisted),
            ]),
            DiscoverySection(title: "Kişiselleştirilmiş", icon: "person.crop.circle.badge.checkmark", items: [
                DiscoveryItem(title: "Sana özel öneriler", subtitle: "Portföy analizine göre seçildi", icon: "wand.and.stars", iconColor: .hsPurple600, badge: "AI", badgeColor: .hsPurple400, filter: .personalRecommendation),
                DiscoveryItem(title: "Beğenebileceğin gayrimenkuller", subtitle: "Yatırım geçmişine göre öneriler", icon: "heart.fill", iconColor: .hsError, badge: nil, badgeColor: .clear, filter: .likelyToEnjoy),
                DiscoveryItem(title: "Watchlist'indekine benzer", subtitle: "Takip ettiğin mülklere yakın fırsatlar", icon: "square.on.square", iconColor: .hsPurple400, badge: nil, badgeColor: .clear, filter: .similarToWatchlist),
            ]),
            DiscoverySection(title: "Bölgesel", icon: "map.fill", items: [
                DiscoveryItem(title: "Şehrindeki fırsatlar", subtitle: "Bulunduğun şehirdeki gayrimenkuller", icon: "location.fill", iconColor: .hsPurple600, badge: nil, badgeColor: .clear, filter: .inYourCity),
                DiscoveryItem(title: "Bölgelere göre en iyiler", subtitle: "Her bölgenin en iyi performanslısı", icon: "map.circle.fill", iconColor: .hsPurple400, badge: nil, badgeColor: .clear, filter: .bestByRegion),
                DiscoveryItem(title: "Yükselen bölgeler", subtitle: "Değer artışı trendi gösteren lokasyonlar", icon: "chart.line.uptrend.xyaxis.circle.fill", iconColor: .hsSuccess, badge: "Trend", badgeColor: .hsSuccess, filter: .risingRegions),
            ]),
        ]
    }
}

// MARK: - FilteredAssetsView

struct FilteredAssetsView: View {
    
    let filter: DiscoveryFilter
    let assets: [AssetItem]
    
    var body: some View {
        ZStack {
            Color.hsBackground
                .ignoresSafeArea()
            
            if assets.isEmpty {
                VStack(spacing: 16) {
                    Image(systemName: "tray")
                        .font(.system(size: 44))
                        .foregroundColor(.hsTextTertiary)
                    
                    Text("Henüz sonuç yok")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(.hsTextPrimary)
                    
                    Text("Bu kategoride henüz gayrimenkul bulunmuyor.")
                        .font(.system(size: 14))
                        .foregroundColor(.hsTextSecondary)
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
                            if assets.last?.id != asset.id{
                                Divider()
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
                .foregroundColor(.hsPurple600)
                .frame(width: 44, height: 44)
                .background(Color.hsPurple600.opacity(0.12))
                .clipShape(RoundedRectangle(cornerRadius: 12))
            
            VStack(alignment: .leading, spacing: 4) {
                Text(asset.title)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(.hsTextPrimary)
                    .lineLimit(1)
                
                HStack(spacing: 6) {
                    Text(asset.category)
                        .font(.system(size: 12))
                        .foregroundColor(.hsTextTertiary)
                    
                    if let city = asset.propertyCity {
                        Text("·")
                            .font(.system(size: 12))
                            .foregroundColor(.hsTextTertiary)
                        Text(city)
                            .font(.system(size: 12))
                            .foregroundColor(.hsTextTertiary)
                    }
                }
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text(asset.formattedPrice)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.hsTextPrimary)
                
                Text(asset.formattedChange)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(asset.isPositive ? .hsSuccess : .hsError)
            }
        }
        .padding(14)
        .background(Color.hsBackgroundSecondary)
    }
}

// MARK: - Preview

#if DEBUG
#Preview {
    SearchView()
        .preferredColorScheme(.dark)
}
#endif
