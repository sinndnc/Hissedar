//
//  TransactionsViewModel.swift
//  Hissedar
//
//  Created by Sinan Dinç on 4/8/26.
//

import Foundation
import Factory

@MainActor
@Observable
final class TransactionsViewModel {
    
    private var authService = Container.shared.authService()
    private var marketRepository =  Container.shared.marketRepository()
    
    var transactions: [TransactionItem] = []
    var activeFilter: TransactionFilter = .all
    var searchText: String = ""
    var selectedTransaction: TransactionItem?
    
    var filteredTransactions: [TransactionItem] {
        var result = transactions
        
        if let type = activeFilter.transactionType {
            result = result.filter { $0.type == type }
        }
        
        if !searchText.isEmpty {
            let query = searchText.lowercased()
            result = result.filter {
                $0.description?.lowercased().contains(query) != nil ||
                (($0.txHash?.lowercased().contains(query)) != nil)
            }
        }
        
        return result.sorted { $0.createdDate > $1.createdDate }
    }
    
    var totalIncoming: Double {
        filteredTransactions
            .filter { $0.status == .confirmed && $0.type.isPositive }
            .reduce(0) { $0 + ($1.amount ?? 0) }
    }
    
    var totalOutgoing: Double {
        filteredTransactions
            .filter { $0.status == .confirmed && !$0.type.isPositive }
            .reduce(0) { $0 + ($1.amount ?? 0) }
    }
    
    func loadTransactions() async {
        guard let userId = await authService.currentUserId?.lowercased() else { return }
        do {
            transactions = try await marketRepository.fetchTransactions(userId: userId)
        } catch {
            print("❌ Transactions error: \(error)")
        }
    }
}
