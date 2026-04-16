//
//  WatchlistService.swift
//  Hissedar
//

import Foundation
import Supabase
import Factory

protocol WatchlistServiceProtocol {
    func fetchEntries(for userId: String) async throws -> [WatchlistItem]
    func addEntry(userId: String, itemId: String, itemType: String) async throws
    func removeEntry(userId: String, itemId: String, itemType: String) async throws
    func isInWatchlist(userId: String, itemId: String, itemType: String) async throws -> Bool
}

final class WatchlistService: WatchlistServiceProtocol {
    
    @Injected(\.supabaseClient) private var client
    
    func fetchEntries(for userId: String) async throws -> [WatchlistItem] {
        try await client
            .from("watchlist")
            .select()
            .eq("user_id", value: userId)
            .order("created_at", ascending: false)
            .execute()
            .value
    }

    func addEntry(userId: String, itemId: String, itemType: String) async throws {
        try await client
            .from("watchlist")
            .upsert([
                "user_id": userId,
                "asset_id": itemId,
                "asset_type": itemType
            ], onConflict: "user_id,asset_id,asset_type")
            .execute()
    }

    func removeEntry(userId: String, itemId: String, itemType: String) async throws {
        try await client
            .from("watchlist")
            .delete()
            .eq("user_id", value: userId)
            .eq("asset_id", value: itemId)
            .eq("asset_type", value: itemType)
            .execute()
    }

    func isInWatchlist(userId: String, itemId: String, itemType: String) async throws -> Bool {
        let result: [WatchlistItem] = try await client
            .from("watchlist")
            .select()
            .eq("user_id", value: userId)
            .eq("asset_id", value: itemId)
            .eq("asset_type", value: itemType)
            .limit(1)
            .execute()
            .value
        return !result.isEmpty
    }
}
