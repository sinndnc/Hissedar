//
//  BlockchainServiceProtocol.swift
//  Hissedar
//
//  Created by Sinan Dinç on 4/10/26.
//

import Foundation

protocol BlockchainServiceProtocol: Sendable {
    func getWallet(userId: String) async throws -> UserWallet?
    func getTransactions(userId: String) async throws -> [BlockchainTransaction]
    func getTransactionForAsset(userId: String, assetId: String) async throws -> BlockchainTransaction?
}

final class BlockchainService: BlockchainServiceProtocol {
    
    private let repository: BlockchainRepositoryProtocol
    
    init(repository: BlockchainRepositoryProtocol) {
        self.repository = repository
    }
    
    func getWallet(userId: String) async throws -> UserWallet? {
        try await repository.fetchWallet(userId: userId)
    }
    
    func getTransactions(userId: String) async throws -> [BlockchainTransaction] {
        try await repository.fetchTransactions(userId: userId)
    }
    
    func getTransactionForAsset(userId: String, assetId: String) async throws -> BlockchainTransaction? {
        try await repository.fetchTransactionForAsset(userId: userId, assetId: assetId)
    }
}
