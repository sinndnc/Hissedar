//
//  SearchViewModel.swift
//  Hissedar
//
//  SearchView + ActiveSearchView için tek ViewModel.
//  Asset'leri repository'den çeker, arama/filtre/son aramalar
//  ve keşfet section'larının tüm mantığını yönetir.
//

import SwiftUI
import Combine
import Factory

// MARK: - Search Result Type

enum SearchResultType: Hashable {
    case asset(AssetItem)
    case location(name: String, city: String?, assetCount: Int)
    case category(name: String, subtitle: String)
    case filter(name: String, subtitle: String)
    
    var id: String {
        switch self {
        case .asset(let item):              return "asset_\(item.id)"
        case .location(let name, _, _):     return "loc_\(name)"
        case .category(let name, _):        return "cat_\(name)"
        case .filter(let name, _):          return "fil_\(name)"
        }
    }
    
    var displayTitle: String {
        switch self {
        case .asset(let item):              return item.title
        case .location(let name, _, _):     return name
        case .category(let name, _):        return name
        case .filter(let name, _):          return name
        }
    }
    
    var displaySubtitle: String? {
        switch self {
        case .asset(let item):
            return [item.category, item.propertyCity].compactMap { $0 }.joined(separator: " · ")
        case .location(_, let city, let count):
            return [city, "\(count) gayrimenkul"].compactMap { $0 }.joined(separator: " · ")
        case .category(_, let sub):         return sub
        case .filter(_, let sub):           return sub
        }
    }
    
    var icon: String {
        switch self {
        case .asset(let item): return item.icon
        case .location:        return "mappin.circle.fill"
        case .category:        return "square.grid.2x2.fill"
        case .filter:          return "line.3.horizontal.decrease.circle.fill"
        }
    }
    
    var iconColor: Color {
        switch self {
        case .asset:     return .hsPurple600
        case .location:  return .hsSuccess
        case .category:  return .hsPurple400
        case .filter:    return .hsWarning
        }
    }
    
    var badge: String? {
        if case .asset(let item) = self { return item.badge }
        return nil
    }
    
    var priceText: String? {
        if case .asset(let item) = self { return item.formattedPrice }
        return nil
    }
    
    var changeText: String? {
        if case .asset(let item) = self { return item.formattedChange }
        return nil
    }
    
    var isPositive: Bool {
        if case .asset(let item) = self { return item.isPositive }
        return true
    }
    
    var sortOrder: Int {
        switch self {
        case .asset:    return 0
        case .location: return 1
        case .category: return 2
        case .filter:   return 3
        }
    }
}

// MARK: - Discovery Filter

enum DiscoveryFilter: Hashable {
    case topGainers7d
    case topGainers30d
    case highestYield
    case highPotential
    case almostFull
    case newlyAdded
    case earlyEntry
    case mostInvestors
    case mostTradedWeekly
    case mostWatchlisted
    case personalRecommendation
    case similarToWatchlist
    case likelyToEnjoy
    case inYourCity
    case bestByRegion
    case risingRegions
    
    var title: String {
        switch self {
        case .topGainers7d:           return "En çok yükselen"
        case .topGainers30d:          return "En çok değer kazanan (30 gün)"
        case .highestYield:           return "En yüksek kira getirisi"
        case .highPotential:          return "En çok potansiyel sahibi olanlar"
        case .almostFull:             return "Dolmak üzere olanlar"
        case .newlyAdded:             return "Yeni eklenenler"
        case .earlyEntry:             return "Erken giriş fırsatları"
        case .mostInvestors:          return "En çok yatırımcı çeken"
        case .mostTradedWeekly:       return "Bu hafta en çok işlem gören"
        case .mostWatchlisted:        return "Watchlist'e en çok eklenen"
        case .personalRecommendation: return "Sana özel öneriler"
        case .similarToWatchlist:     return "Watchlist'indekine benzer"
        case .likelyToEnjoy:          return "Beğenebileceğin gayrimenkuller"
        case .inYourCity:             return "Şehrindeki fırsatlar"
        case .bestByRegion:           return "Bölgelere göre en iyiler"
        case .risingRegions:          return "Yükselen bölgeler"
        }
    }
    
    func apply(to assets: [AssetItem]) -> [AssetItem] {
        switch self {
        case .topGainers7d, .topGainers30d, .mostTradedWeekly, .risingRegions:
            return assets.sorted { $0.priceChangePercent > $1.priceChangePercent }
        case .highestYield, .bestByRegion:
            return assets.sorted { $0.annualYieldPercent > $1.annualYieldPercent }
        case .highPotential:
            return assets.filter { $0.fundingPercent < 60 && $0.annualYieldPercent > 7 }
                .sorted { $0.annualYieldPercent > $1.annualYieldPercent }
        case .almostFull:
            return assets.filter { $0.fundingPercent >= 80 }
                .sorted { $0.fundingPercent > $1.fundingPercent }
        case .newlyAdded:
            return assets.sorted { ($0.createdAt ?? "") > ($1.createdAt ?? "") }
        case .earlyEntry:
            return assets.filter { $0.fundingPercent < 30 }
                .sorted { $0.annualYieldPercent > $1.annualYieldPercent }
        case .mostInvestors:
            return assets.sorted { ($0.soldTokens ?? 0) > ($1.soldTokens ?? 0) }
        case .mostWatchlisted, .personalRecommendation, .similarToWatchlist, .likelyToEnjoy, .inYourCity:
            return assets // TODO: Backend-driven
        }
    }
}

// MARK: - Popular Search

struct PopularSearch: Identifiable, Hashable {
    let id = UUID()
    let text: String
    let color: Color
}

// MARK: - SearchViewModel

@MainActor
@Observable
final class SearchViewModel {
    
    
    private var repository = Container.shared.marketRepository()
    
    // MARK: - Assets State
    private(set) var assets: [AssetItem] = []
    var isLoadingAssets = false
    var assetsError: String?
    
    // MARK: - Search State
    var searchText = "" {
        didSet { searchTextSubject.send(searchText) }
    }
    var searchResults: [SearchResultType] = []
    var isSearching = false
    var recentSearches: [String] = []
    
    // MARK: - Navigation State
    var selectedAsset: AssetItem?
    
    // MARK: - Static Data
    
    let popularSearches: [PopularSearch] = [
        PopularSearch(text: "İstanbul Avrupa", color: .hsPurple400),
        PopularSearch(text: "İstanbul Anadolu", color: .hsPurple400),
        PopularSearch(text: "%10+ getiri", color: .hsSuccess),
        PopularSearch(text: "Yeni eklenen", color: .hsSuccess),
        PopularSearch(text: "Konut", color: .hsPurple600),
        PopularSearch(text: "Ticari", color: .hsPurple600),
        PopularSearch(text: "Az kalan", color: .hsWarning),
        PopularSearch(text: "Düşük fiyat", color: .hsWarning),
    ]
    
    // MARK: - Private
    
    private let searchTextSubject = PassthroughSubject<String, Never>()
    private var cancellables = Set<AnyCancellable>()
    private let recentSearchesKey = "hissedar_recent_searches"
    private let maxRecentSearches = 10
    
    private let locationSuggestions: [(name: String, city: String?, count: Int)] = [
        ("Kadıköy", "İstanbul", 5), ("Beşiktaş", "İstanbul", 3),
        ("Ataşehir", "İstanbul", 4), ("Levent", "İstanbul", 2),
        ("Üsküdar", "İstanbul", 3), ("Bahçelievler", "İstanbul", 2),
        ("Ankara", nil, 8), ("İzmir", nil, 6),
        ("Antalya", nil, 4), ("Bursa", nil, 3),
    ]
    
    private let categorySuggestions: [(name: String, subtitle: String)] = [
        ("Konut", "Tüm konut gayrimenkulleri"),
        ("Ticari", "Ofis, mağaza, iş merkezi"),
        ("Arsa", "Yatırımlık arsalar"),
        ("Ofis", "Ofis gayrimenkulleri"),
        ("Depo", "Lojistik ve depolama"),
    ]
    
    private let filterSuggestions: [(name: String, subtitle: String)] = [
        ("Yüksek getiri", "%8+ kira getirisi olan mülkler"),
        ("Düşük fiyat", "₺300 altı token fiyatı"),
        ("Yeni eklenen", "Son 30 günde eklenen"),
        ("Dolmak üzere", "%80+ doluluk oranı"),
    ]
    
    // MARK: - Init
    
    init() {
        loadRecentSearches()
        setupSearchDebounce()
    }
    
    // MARK: - Load Assets
    
    func loadAssets() async {
        guard assets.isEmpty else { return } // Zaten yüklüyse tekrar çekme
        
        isLoadingAssets = true
        assetsError = nil
        
        do {
            assets = try await repository.fetchAssets()
            
            isLoadingAssets = false
        } catch {
            assetsError = error.localizedDescription
            isLoadingAssets = false
        }
    }
    
    // MARK: - Search Debounce
    
    private func setupSearchDebounce() {
        searchTextSubject
            .debounce(for: .milliseconds(250), scheduler: RunLoop.main)
            .removeDuplicates()
            .sink { [weak self] query in
                self?.performSearch(query: query)
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Search
    
    private func performSearch(query: String) {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        
        guard !trimmed.isEmpty else {
            searchResults = []
            isSearching = false
            return
        }
        
        isSearching = true
        
        var results: [SearchResultType] = []
        
        // 1. AssetItem'larda ara
        let matchedAssets = assets.filter { asset in
            asset.title.lowercased().contains(trimmed) ||
            (asset.subtitle?.lowercased().contains(trimmed) ?? false) ||
            asset.category.lowercased().contains(trimmed) ||
            (asset.propertyCity?.lowercased().contains(trimmed) ?? false) ||
            (asset.propertyAddress?.lowercased().contains(trimmed) ?? false)
        }
        results.append(contentsOf: matchedAssets.prefix(5).map { .asset($0) })
        
        // 2. Bölgelerde ara
        let matchedLocs = locationSuggestions.filter {
            $0.name.lowercased().contains(trimmed) ||
            ($0.city?.lowercased().contains(trimmed) ?? false)
        }
        results.append(contentsOf: matchedLocs.prefix(3).map {
            .location(name: $0.name, city: $0.city, assetCount: $0.count)
        })
        
        // 3. Kategorilerde ara
        let matchedCats = categorySuggestions.filter {
            $0.name.lowercased().contains(trimmed) ||
            $0.subtitle.lowercased().contains(trimmed)
        }
        results.append(contentsOf: matchedCats.prefix(2).map {
            .category(name: $0.name, subtitle: $0.subtitle)
        })
        
        // 4. Filtrelerde ara
        let matchedFilters = filterSuggestions.filter {
            $0.name.lowercased().contains(trimmed) ||
            $0.subtitle.lowercased().contains(trimmed)
        }
        results.append(contentsOf: matchedFilters.prefix(2).map {
            .filter(name: $0.name, subtitle: $0.subtitle)
        })
        
        searchResults = results.sorted { $0.sortOrder < $1.sortOrder }
        isSearching = false
    }
    
    // MARK: - Recent Searches
    
    func addToRecentSearches(_ text: String) {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        
        recentSearches.removeAll { $0.lowercased() == trimmed.lowercased() }
        recentSearches.insert(trimmed, at: 0)
        
        if recentSearches.count > maxRecentSearches {
            recentSearches = Array(recentSearches.prefix(maxRecentSearches))
        }
        saveRecentSearches()
    }
    
    func removeRecentSearch(at index: Int) {
        guard recentSearches.indices.contains(index) else { return }
        recentSearches.remove(at: index)
        saveRecentSearches()
    }
    
    func clearRecentSearches() {
        recentSearches.removeAll()
        saveRecentSearches()
    }
    
    private func loadRecentSearches() {
        recentSearches = UserDefaults.standard.stringArray(forKey: recentSearchesKey) ?? []
    }
    
    private func saveRecentSearches() {
        UserDefaults.standard.set(recentSearches, forKey: recentSearchesKey)
    }
    
    // MARK: - Actions
    
    func selectResult(_ result: SearchResultType) {
        addToRecentSearches(result.displayTitle)
        
        switch result {
        case .asset(let item):
            selectedAsset = item
        case .location, .category, .filter:
            break // TODO: Navigate to filtered list
        }
    }
    
    func selectPopularSearch(_ search: PopularSearch) {
        searchText = search.text
        addToRecentSearches(search.text)
    }
    
    func submitSearch() {
        let trimmed = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        addToRecentSearches(trimmed)
    }
}
