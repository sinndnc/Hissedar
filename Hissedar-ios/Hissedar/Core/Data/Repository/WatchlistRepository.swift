//
//  WatchlistRepository.swift
//  Hissedar
//
//  Created by Sinan Dinç on 3/27/26.
//

import Factory
import Foundation

// ✅ Sorunsuz — tablo adı, kolonlar ve unique constraint yeni şemayla uyumlu
protocol WatchlistRepositoryProtocol {
    func getWatchlistItems(for userId: String) async throws -> [AssetItem]
    func toggleWatchlist(userId: String, assetId: String, assetType: String) async throws -> Bool
}

final class WatchlistRepository: WatchlistRepositoryProtocol {
    
    @Injected(\.watchlistService) private var service
    @Injected(\.marketRepository)     private var marketRepository
    
    func getWatchlistItems(for userId: String) async throws -> [AssetItem] {
        let entries = try await service.fetchEntries(for: userId)
        guard !entries.isEmpty else { return [] }
        
        let ids = entries.map(\.assetId)
        
        return try await withThrowingTaskGroup(of: AssetItem?.self) { group in
            for id in ids {
                group.addTask {
                    try? await self.marketRepository.fetchAsset(id: id).toDisplayItem
                }
            }
            var items: [AssetItem] = []
            for try await item in group {
                if let item { items.append(item) }
            }
            return items
        }
    }
    
    func toggleWatchlist(userId: String, assetId: String, assetType: String) async throws -> Bool {
        let exists = try await service.isInWatchlist(
            userId: userId, itemId: assetId, itemType: assetType
        )
        if exists {
            try await service.removeEntry(userId: userId, itemId: assetId, itemType: assetType)
            return false
        } else {
            try await service.addEntry(userId: userId, itemId: assetId, itemType: assetType)
            return true
        }
    }
}
