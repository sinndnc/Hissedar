//
//  MarketRepository.swift
//  Hissedar
//
//  Created by Sinan Dinç on 3/27/26.
//

import Factory
import Foundation

protocol MarketRepositoryProtocol {
    func fetchAssets() async throws -> [AssetItem]
    func fetchAsset(id: String) async throws -> AssetDetail
    func fetchTransactions(userId: String) async throws -> [TransactionItem]
    func purchase(buyerId: String, asset: AssetItem, amount: Int) async throws -> PurchaseResult
}

final class MarketRepository: MarketRepositoryProtocol {
    
    @Injected(\.marketService) private var service
    
    func fetchAssets() async throws -> [AssetItem] {
        try await service.fetchAssets()
    }
    
    func fetchAsset(id: String) async throws -> AssetDetail {
        try await service.fetchAsset(id: id)
    }
    
    
    func fetchTransactions(userId: String) async throws -> [TransactionItem] {
        try await service.fetchTransactions(userId: userId)
    }
    
    func purchase(
        buyerId: String,
        asset: AssetItem,
        amount: Int
    ) async throws -> PurchaseResult {
        guard amount > 0 else { throw TradeError.invalidAmount }
        guard amount <= asset.remainingTokens else {
            throw TradeError.insufficientTokens
        }
        
        let result = try await service.purchaseAsset(
            buyerId: buyerId,
            assetId: asset.id,
            assetType: asset.assetType.rawValue,
            amount: amount
        )
        
        if !result.success {
            throw TradeError.serverError(result.error ?? "Bilinmeyen hata")
        }
        
        return result
    }
    
}
