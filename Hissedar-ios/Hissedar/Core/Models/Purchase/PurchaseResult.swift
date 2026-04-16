//
//  PurchaseResult.swift
//  Hissedar
//
//  Created by Sinan Dinç on 3/27/26.
//

import Foundation

struct PurchaseResult: Codable {
    let success: Bool
    let transactionId: String?
    let holdingId: String?
    let totalCost: Decimal?
    let tokenPrice: Decimal?
    let amount: Int?
    let currency: String?
    let newHsrBalance: Decimal?
    let blockchainStatus: String?
    let walletAddress: String?
    let blockchainTokenId: Int?
    
    // Backward compat
    let error: String?

    enum CodingKeys: String, CodingKey {
        case success, error, currency, amount
        case transactionId     = "transaction_id"
        case holdingId         = "holding_id"
        case totalCost         = "total_cost"
        case tokenPrice        = "token_price"
        case newHsrBalance     = "new_hsr_balance"
        case blockchainStatus  = "blockchain_status"
        case walletAddress     = "wallet_address"
        case blockchainTokenId = "blockchain_token_id"
    }
}
