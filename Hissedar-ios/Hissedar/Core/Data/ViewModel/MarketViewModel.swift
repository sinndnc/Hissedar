//
//  MarketViewModel.swift
//  Hissedar
//
//  Created by Sinan Dinç on 4/8/26.
//

import SwiftUI
import Factory

@MainActor
@Observable
final class MarketViewModel: BaseViewModel, MarketLoadable {
    
    private let authService = Container.shared.authService()
    private let repository = Container.shared.marketRepository()
    
    // MARK: - State
    var error: String?
    var searchText = ""
    var selected: AssetItem?
    var selectedDetail: AssetDetail?
    var assets: [AssetItem] = []
    var selectedFilter: AssetFilter = .all
    var selectedSort: AssetSort = .popular
    var showPurchaseSheet = false
    var isLoadingDetail = false

    // MARK: - Computed

    var filteredAssets: [AssetItem] {
        var result = assets
        
        if let typeValue = selectedFilter.assetType?.queryValue {
            result = result.filter { $0.assetType.rawValue == typeValue }
        }
        
        if !searchText.isEmpty {
            result = result.filter {
                $0.title.localizedCaseInsensitiveContains(searchText) ||
                ($0.subtitle?.localizedCaseInsensitiveContains(searchText) ?? false) ||
                $0.category.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        switch selectedSort {
        case .popular:   result.sort { ($0.soldTokens ?? 0) > ($1.soldTokens ?? 0) }
        case .priceLow:  result.sort { $0.currentValue < $1.currentValue }
        case .priceHigh: result.sort { $0.currentValue > $1.currentValue }
        case .newest:    result.sort { ($0.createdAt ?? "") > ($1.createdAt ?? "") }
        case .yieldHigh: result.sort { ($0.annualYield ?? 0) > ($1.annualYield ?? 0) }
        }
        
        return result
    }

    var assetCounts: [AssetFilter: Int] {
        [
            .all:      assets.count,
            .type(.property): assets.filter { $0.assetType == .property }.count,
            .type(.art):      assets.filter { $0.assetType == .art }.count,
            .type(.nft):      assets.filter { $0.assetType == .nft }.count
        ]
    }

    // MARK: - Load All

    func refresh() async { await load() }

    func load() async {
        guard !isLoading else { return }
        guard (await authService.currentUserId) != nil else { return }
        isLoading = true
        error = nil
        defer { isLoading = false }

        do {
            assets = try await repository.fetchAssets()
        } catch {
            print("🔴 Assets fetch error: \(error)")
            assets = []
        }
    }

    // MARK: - Fetch Detail

    func fetchDetail(id: String) async {
        guard !isLoadingDetail else { return }
        isLoadingDetail = true
        selectedDetail = nil
        defer { isLoadingDetail = false }

        do {
            selectedDetail = try await repository.fetchAsset(id: id)
        } catch {
            print("🔴 Asset detail fetch error: \(error)")
        }
    }

    // MARK: - Select

    func selectAsset(_ asset: AssetItem) {
        selected = asset
        showPurchaseSheet = true
        Task { await fetchDetail(id: asset.id) }
    }
}
