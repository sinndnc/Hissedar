//
//  PortfolioViewModel.swift
//  Hissedar
//

import SwiftUI
import Factory

@MainActor
@Observable
final class PortfolioViewModel {
    
    private let repository = Container.shared.portfolioRepository()
    private let authService = Container.shared.authService()
    
    var items: [AssetItem] = []
    var summary: PortfolioSummary?
    var wallet: Wallet?
    var isLoading = false
    var error: String?
    var selectedSort: PortfolioSort = .value
    
    // MARK: - Computed
    
    var sortedItems: [AssetItem] {
        switch selectedSort {
        case .value:
            items.sorted { $0.currentValue > $1.currentValue }
        case .gain:
            items.sorted { ($0.unrealizedGain ?? 0) > ($1.unrealizedGain ?? 0) }
        case .returnRate:
            items.sorted { $0.returnRate > $1.returnRate }
        case .rent:
            items.sorted { ($0.totalRentEarned ?? 0) > ($1.totalRentEarned ?? 0) }
        }
    }
    
    var cashBalance: Decimal {
        wallet?.balance ?? 0
    }
    
    var tokenBalance: Decimal {
        wallet?.hsrBalance ?? 0
    }
    
    var cashLockedBalance: Decimal {
        wallet?.lockedBalance ?? 0
    }
    
    var tokenLockedBalance: Decimal {
        wallet?.hsrLocked ?? 0
    }
    
    var tokenAvailableBalance: Decimal {
        wallet?.availableHSR ?? 0
    }
    
    var cashAvailableBalance: Decimal {
        wallet?.availableTRY ?? 0
    }
    
    var netWorth: Decimal {
        cashBalance + tokenBalance + items
            .reduce(Decimal.zero) { $0 +  $1.currentValue * Decimal($1.tokenAmount ?? 1)}
    }
    
    var totalValue: Decimal {
        summary?.totalValue ?? 0
    }
    
    var totalGain: Decimal {
        summary?.totalGain ?? 0
    }
    
    var isGainPositive: Bool {
        summary?.isPositive ?? true
    }
    
    var gainPercent: Double {
        summary?.returnRate ?? 0
    }
    
    func allocationPercent(for item: AssetItem) -> Double {
        guard totalValue > 0 else { return 0 }
        return Double(truncating: (item.currentValue / totalValue * 100) as NSDecimalNumber)
    }
    
    // MARK: - Actions
    
    func load() async {
        guard let userId = await authService.currentUserId else {
            print("❌ userId nil")
            return
        }
        isLoading = true
        error = nil
        defer { isLoading = false }
        
        do {
            async let walletTask = repository.getWallet(userId: userId)
            async let itemsTask = repository.getPortfolio(for: userId)
            async let summaryTask = repository.getPortfolioSummary(for: userId)
            
            wallet = try await walletTask
            items = try await itemsTask
            summary = try await summaryTask
            
        } catch {
            self.error = error.localizedDescription
            print("❌ Portfolio error: \(error)")
        }
    }
}
