//
//  WalletViewModel.swift
//  Hissedar
//
//  Created by Sinan Dinç on 4/10/26.
//

import Foundation
import Factory

@MainActor
@Observable
final class WalletViewModel {
    
    private let service = Container.shared.blockchainService()
    private let authService = Container.shared.authService()
    
    var wallet: UserWallet?
    var transactions: [BlockchainTransaction] = []
    var isLoading = false
    var error: String?
    
    var confirmedCount: Int {
        transactions.filter(\.isConfirmed).count
    }
    
    var pendingCount: Int {
        transactions.filter(\.isPending).count
    }
    
    var totalMinted: Int {
        transactions.filter { $0.isConfirmed && $0.txType == "mint" }
            .reduce(0) { $0 + $1.tokenAmount }
    }
    
    func load() async {
        guard let userId = await authService.currentUserId else { return }
        isLoading = true
        error = nil
        defer { isLoading = false }
        
        do {
            async let walletTask = service.getWallet(userId: userId)
            async let txTask = service.getTransactions(userId: userId)
            
            wallet = try await walletTask
            transactions = try await txTask
        } catch {
            self.error = error.localizedDescription
        }
    }
}
