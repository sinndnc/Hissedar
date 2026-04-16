//
//  BlockchainRepositoryProtocol.swift
//  Hissedar
//
//  Created by Sinan Dinç on 4/10/26.
//

import Foundation
import Supabase

protocol BlockchainRepositoryProtocol: Sendable {
    func fetchWallet(userId: String) async throws -> UserWallet?
    func fetchTransactions(userId: String) async throws -> [BlockchainTransaction]
    func fetchTransactionForAsset(userId: String, assetId: String) async throws -> BlockchainTransaction?
}

final class BlockchainRepository: BlockchainRepositoryProtocol {
    
    private let client: SupabaseClient
    
    init(client: SupabaseClient) {
        self.client = client
    }
    
    func fetchWallet(userId: String) async throws -> UserWallet? {
        let response: [UserWallet] = try await client
            .from("user_wallets")
            .select()
            .eq("user_id", value: userId)
            .limit(1)
            .execute()
            .value
        return response.first
    }
    
    func fetchTransactions(userId: String) async throws -> [BlockchainTransaction] {
        let response: [BlockchainTransaction] = try await client
            .from("blockchain_transactions")
            .select()
            .eq("user_id", value: userId)
            .order("created_at", ascending: false)
            .limit(50)
            .execute()
            .value
        return response
    }
    
    func fetchTransactionForAsset(userId: String, assetId: String) async throws -> BlockchainTransaction? {
        let response: [BlockchainTransaction] = try await client
            .from("blockchain_transactions")
            .select()
            .eq("user_id", value: userId)
            .eq("asset_id", value: assetId)
            .order("created_at", ascending: false)
            .limit(1)
            .execute()
            .value
        return response.first
    }
}
