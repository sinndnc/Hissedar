//
//  WatchlistViewModel.swift
//  Hissedar
//
//  Created by Sinan Dinç on 3/27/26.
//

import Factory
import SwiftUI

@MainActor
@Observable
final class WatchlistViewModel {
    
    private let repository = Container.shared.watchlistRepository()
    private let authService = Container.shared.authService()
    
    var items: [AssetItem] = []
    var isLoading = false
    var error: String?
    
    var searchText = ""
    var selectedSort: AssetSort = .popular
    var selectedType: AssetFilter = .all
    
    // MARK: - Filtered & Sorted
    var filteredItems: [AssetItem] {
        var result = items   // ❗️ items’ı ASLA direkt değiştirme
        // 1. Search
        if !searchText.isEmpty {
            result = result.filter {
                $0.title.localizedCaseInsensitiveContains(searchText) ||
                ($0.subtitle?.localizedCaseInsensitiveContains(searchText) ?? false)
            }
        }
        // 2. Type filter
        if selectedType != .all {
            result = result.filter { $0.assetType == selectedType.assetType }
        }
        // 3. Sorting
        switch selectedSort {
        case .popular:
            result = result.sorted { abs($0.priceChangePercent) > abs($1.priceChangePercent) }
        case .priceHigh:
            result = result.sorted { $0.currentValue > $1.currentValue }
        case .priceLow:
            result = result.sorted { $0.currentValue < $1.currentValue }
        case .newest:
            result = result.sorted { $0.title.localizedCompare($1.title) == .orderedAscending }
        case .yieldHigh:
            result = result.sorted { $0.annualYieldPercent > $1.annualYieldPercent  }
        }
        return result
    }
    
    // MARK: - Actions
    
    func isInWatchlist(itemId: String, itemType: String) -> Bool {
        items.contains { $0.id == itemId && $0.assetType.rawValue == itemType }
    }
    
    func loadWatchlist() async {
        guard let userId = await authService.currentUserId else { return }
        
        isLoading = true
        error = nil
        
        do {
            items = try await repository.getWatchlistItems(for: userId)
        } catch {
            self.error = error.localizedDescription
        }
        
        isLoading = false
    }
    
    func toggle(itemId: String, itemType: String) async {
        guard let userId = await authService.currentUserId else { return }
        
        do {
            let added = try await repository.toggleWatchlist(
                userId: userId,
                assetId: itemId,
                assetType: itemType
            )
            
            if !added {
                items.removeAll { $0.id == itemId }
            } else {
                await loadWatchlist()
            }
        } catch {
            self.error = error.localizedDescription
        }
    }
    
    
    func move(from source: IndexSet, to destination: Int) {
        items.move(fromOffsets: source, toOffset: destination)
        
        // 🔥 BURASI ÖNEMLİ (backend'e persist edilecek)
        // örnek:
        // saveOrderToBackend()
    }
}
