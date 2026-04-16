//
//  MarketRepository.swift
//  Hissedar
//

import Factory
import Supabase
import Foundation

protocol MarketServiceProtocol {
    func fetchAssets() async throws -> [AssetItem]
    func fetchAsset(id: String) async throws -> AssetDetail
    func purchaseAsset(buyerId: String, assetId: String, assetType: String, amount: Int) async throws -> PurchaseResult
    func fetchTransactions(userId: String) async throws -> [TransactionItem]
}

final class MarketService: MarketServiceProtocol {

    @Injected(\.supabaseClient) private var client

    func fetchAssets() async throws -> [AssetItem] {
        try await client
            .from("tradeable_assets_view")
            .select()
            .eq("status", value: "active")
            .order("created_at", ascending: false)
            .execute()
            .value
    }

    func fetchAsset(id: String) async throws -> AssetDetail {
        try await client
            .from("tradeable_assets_view")
            .select()
            .eq("id", value: id)
            .single()
            .execute()
            .value
    }

    func purchaseAsset(
        buyerId: String,
        assetId: String,
        assetType: String,
        amount: Int
    ) async throws -> PurchaseResult {

        let response = try await client
              .rpc("purchase_asset", params: [
                  "p_buyer_id":   AnyJSON.string(buyerId),
                  "p_asset_type": AnyJSON.string(assetType),
                  "p_asset_id":   AnyJSON.string(assetId),
                  "p_amount":     AnyJSON.integer(amount)
              ])
              .execute()
        
        let data = response.data
        
        if let result = try? JSONDecoder().decode(PurchaseResult.self, from: data) {
            return result
        }
        if let array = try? JSONDecoder().decode([PurchaseResult].self, from: data),
           let first = array.first {
            return first
        }
        if let stringWrapped = try? JSONDecoder().decode(String.self, from: data),
           let innerData = stringWrapped.data(using: .utf8) {
            return try JSONDecoder().decode(PurchaseResult.self, from: innerData)
        }

        let raw = String(data: data, encoding: .utf8) ?? "nil"
        throw TradeError.serverError("Yanıt parse edilemedi: \(raw)")
    }

    func fetchTransactions(userId: String) async throws -> [TransactionItem] {
        try await client
            .from("transactions")
            .select()
            .eq("user_id", value: userId)
            .order("created_at", ascending: false)
            .execute()
            .value
    }
}
