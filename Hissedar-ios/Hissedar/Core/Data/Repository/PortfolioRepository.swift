//
//  PortfolioRepository.swift
//  Hissedar
//
//  Created by Sinan Dinç on 3/27/26.
//

import Factory
import Foundation

// ✅ Sorunsuz — portfolio_view yeni şemada mevcut ve uyumlu
protocol PortfolioRepositoryProtocol {
    func getPortfolio(for userId: String) async throws -> [AssetItem]
    func getPortfolioSummary(for userId: String) async throws -> PortfolioSummary
    func getItem(userId: String, assetId: String) async throws -> AssetItem?
    func getWallet(userId: String) async throws -> Wallet?
}

final class PortfolioRepository: PortfolioRepositoryProtocol {
    
    @Injected(\.portfolioService) private var service
    
    func getPortfolio(for userId: String) async throws -> [AssetItem] {
        let items = try await service.fetchPortfolio(for: userId)
        return items.map { $0.toDisplayItem() }
    }
    
    func getPortfolioSummary(for userId: String) async throws -> PortfolioSummary {
        // Wallet ve holdings'i paralel çek
        async let walletTask = service.fetchWallet(userId: userId)
        async let itemsTask = service.fetchPortfolio(for: userId)
        
        let wallet = try await walletTask
        let items = try await itemsTask
        
        let totalHoldingsValue = items.reduce(Decimal.zero) { $0 + $1.currentValue }
        let totalGain = items.reduce(Decimal.zero) { $0 + $1.unrealizedPnl }
        let totalRentEarned = items.reduce(Decimal.zero) { $0 + $1.totalRentEarned }
        
        return PortfolioSummary(
            totalValue: (wallet?.balance ?? 0) + totalHoldingsValue,
            totalGain: totalGain,
            totalRentEarned: totalRentEarned,
            //TODO: (burası(totalPendingRent) daha implement edilmedi)
            totalPendingRent: totalRentEarned,
            assetCount: items.count,
            cashBalance: wallet?.balance ?? 0,
            lockedBalance: wallet?.lockedBalance ?? 0
        )
    }
    
    func getItem(userId: String, assetId: String) async throws -> AssetItem? {
        guard let item = try await service.fetchPortfolioItem(userId: userId, assetId: assetId) else {
            return nil
        }
        return item.toDisplayItem()
    }
    
    func getWallet(userId: String) async throws -> Wallet? {
        try await service.fetchWallet(userId: userId)
    }
}
