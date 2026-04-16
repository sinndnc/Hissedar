//
//  RentViewModel.swift
//  Hissedar
//
//  Created by Sinan Dinç on 4/13/26.
//

import Factory
import Foundation
import Observation

// MARK: - Filter

enum RentHistoryFilter: String, CaseIterable, Identifiable {
    case all       = "Tümü"
    case apartment = "Konut"
    case office    = "Ofis"
    case shop      = "Dükkan"
    case land      = "Arsa"

    var id: String { rawValue }

    var assetTypeKey: String? {
        switch self {
        case .all:       return nil
        case .apartment: return "apartment"
        case .office:    return "office"
        case .shop:      return "shop"
        case .land:      return "land"
        }
    }
}

@MainActor
@Observable
final class RentHistoryViewModel {
    
    // MARK: Published State
    private(set) var items: [RentHistory] = []
    private(set) var totalEarned: Decimal = .zero
    private(set) var isLoading = false
    private(set) var error: String? = nil
    
    var searchQuery: String = ""
    var selectedFilter: RentHistoryFilter = .all
    
    // MARK: Dependencies
    private var authService = Container.shared.authService()
    private var rentService = Container.shared.rentService()
    // MARK: Private
    
    // MARK: - Computed: Filtered + Searched Items
    var filteredItems: [RentHistory] {
        var result = items
        
        if let typeKey = selectedFilter.assetTypeKey {
            result = result.filter { $0.assetType.lowercased() == typeKey }
        }
        
        let query = searchQuery.trimmingCharacters(in: .whitespaces).lowercased()
        if !query.isEmpty {
            result = result.filter {
                ($0.assetTitle?.lowercased().contains(query) ?? false) ||
                ($0.propertyCity?.lowercased().contains(query) ?? false) ||
                $0.periodLabel.lowercased().contains(query)
            }
        }
        
        return result
    }
    
    /// Gösterilen kayıtların toplam kira tutarı (filtre/arama sonucuna göre)
    var filteredTotal: Decimal {
        filteredItems.reduce(.zero) { $0 + $1.rentAmount }
    }
    
    var hasResults: Bool { !filteredItems.isEmpty }
    
    // MARK: - Intent: Load
    
    @MainActor
    func load() async {
        guard !isLoading else { return }
        isLoading = true
        error = nil
        
        do {
            if let userId = await authService.currentUserId{
                async let historyTask  = rentService.fetchRentHistory(userId: userId)
                async let totalTask    = rentService.fetchTotalRentEarned(userId: userId)
                
                let (history, total) = try await (historyTask, totalTask)
                
                items = history
                totalEarned  = total
            }
        } catch {
            self.error = error.localizedDescription
        }
        
        isLoading = false
    }
    
    // MARK: - Intent: Refresh
    
    @MainActor
    func refresh() async {
        await load()
    }
    
    // MARK: - Intent: Filter by Asset
    
    /// Belirli bir varlığa ait geçmişi assetId ile filtrele (detail ekranı için)
    func items(for assetId: String) -> [RentHistory] {
        items.filter { $0.assetId == assetId }
    }
    
    // MARK: - Intent: Clear Error
    
    func clearError() {
        error = nil
    }
}
