//
//  PortfolioService.swift
//  Hissedar
//
//  Created by Sinan Dinç on 3/27/26.
//

import Factory
import Supabase
import Foundation

protocol PortfolioServiceProtocol {
    func fetchPortfolio(for userId: String) async throws -> [PortfolioItem]
    func fetchPortfolioItem(userId: String, assetId: String) async throws -> PortfolioItem?
    func fetchWallet(userId: String) async throws -> Wallet?
}

final class PortfolioService: PortfolioServiceProtocol {
    
    @Injected(\.supabaseClient) private var client
    
    func fetchPortfolio(for userId: String) async throws -> [PortfolioItem] {
        try await client
            .from("portfolio_view")
            .select()
            .eq("user_id", value: userId)
            .order("current_value", ascending: false)
            .execute()
            .value
    }
    
    // FIX: Tablo adı "portfolios" → "wallets" olarak düzeltildi
    func fetchWallet(userId: String) async throws -> Wallet? {
        let wallets: [Wallet] = try await client
            .from("wallets")
            .select()
            .eq("user_id", value: userId)
            .limit(1)
            .execute()
            .value
        return wallets.first
    }

    func fetchPortfolioItem(userId: String, assetId: String) async throws -> PortfolioItem? {
        let items: [PortfolioItem] = try await client
            .from("portfolio_view")
            .select()
            .eq("user_id", value: userId)
            .eq("asset_id", value: assetId)
            .limit(1)
            .execute()
            .value
        return items.first
    }
}
