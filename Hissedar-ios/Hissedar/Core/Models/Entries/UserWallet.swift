//
//  UserWallet.swift
//  Hissedar
//
//  Created by Sinan Dinç on 4/10/26.
//

import Foundation

struct UserWallet: Codable, Sendable {
    let id: String
    let userId: String
    let walletAddress: String
    let isWhitelisted: Bool
    let createdAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case walletAddress = "wallet_address"
        case isWhitelisted = "is_whitelisted"
        case createdAt = "created_at"
    }
    
    var shortAddress: String {
        guard walletAddress.count > 10 else { return walletAddress }
        let prefix = walletAddress.prefix(6)
        let suffix = walletAddress.suffix(4)
        return "\(prefix)...\(suffix)"
    }
    
    var polygonscanURL: URL? {
        URL(string: "https://amoy.polygonscan.com/address/\(walletAddress)")
    }
}

struct BlockchainTransaction: Codable, Identifiable, Sendable {
    let id: String
    let userId: String
    let assetType: String
    let assetId: String
    let txType: String
    let txHash: String
    let blockchainTokenId: Int
    let tokenAmount: Int
    let walletAddress: String
    let status: String
    let blockNumber: Int?
    let gasUsed: Int?
    let errorMessage: String?
    let createdAt: Date
    let confirmedAt: Date?
    
    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case assetType = "asset_type"
        case assetId = "asset_id"
        case txType = "tx_type"
        case txHash = "tx_hash"
        case blockchainTokenId = "blockchain_token_id"
        case tokenAmount = "token_amount"
        case walletAddress = "wallet_address"
        case status
        case blockNumber = "block_number"
        case gasUsed = "gas_used"
        case errorMessage = "error_message"
        case createdAt = "created_at"
        case confirmedAt = "confirmed_at"
    }
    
    var isConfirmed: Bool { status == "confirmed" }
    var isPending: Bool { status == "pending" }
    var isFailed: Bool { status == "failed" }
    
    var shortTxHash: String {
        guard txHash.count > 14, txHash != "pending" else { return txHash }
        return "\(txHash.prefix(10))...\(txHash.suffix(4))"
    }
    
    var polygonscanURL: URL? {
        guard txHash != "pending" else { return nil }
        return URL(string: "https://amoy.polygonscan.com/tx/\(txHash)")
    }
    
    var statusIcon: String {
        switch status {
        case "confirmed": return "checkmark.circle.fill"
        case "pending": return "clock.fill"
        case "failed": return "xmark.circle.fill"
        default: return "questionmark.circle"
        }
    }
    
    var statusLabel: String {
        switch status {
        case "confirmed": return "Onaylandı"
        case "pending": return "İşleniyor"
        case "failed": return "Başarısız"
        default: return status
        }
    }
}
