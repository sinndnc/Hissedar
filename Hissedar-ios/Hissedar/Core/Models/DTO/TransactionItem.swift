//
//  TransactionItem.swift
//  Hissedar
//

import Foundation
import SwiftUI

struct TransactionItem: Codable, Identifiable {
    let id: String
    let userId: String
    let type: TransactionType
    let amount: Double?
    let fee: Double?
    let totalPrice: Double?
    let pricePerToken: Double?
    let tokenAmount: Int
    let description: String?
    let status: TransactionStatus
    let assetType: String
    let assetId: String?
    let currency: String
    let createdAt: String
    let txHash: String?
    let idempotencyKey: String?
    
    enum CodingKeys: String, CodingKey {
        case id, status, currency, amount, description, type, fee
        case txHash = "tx_hash"
        case userId = "user_id"
        case assetId = "asset_id"
        case assetType = "asset_type"
        case createdAt = "created_at"
        case totalPrice = "total_price"
        case tokenAmount = "token_amount"
        case pricePerToken = "price_per_token"
        case idempotencyKey = "idempotency_key"
    }
    
    var createdDate: Date {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter.date(from: createdAt) ?? .now
    }
    
    var formattedAmount: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = currency
        formatter.maximumFractionDigits = 2
        return formatter.string(from: NSNumber(value: amount ?? 0)) ?? "\(currency)\(amount ?? 0)"
    }
    
    var truncatedHash: String {
        guard let hash = txHash, hash.count > 14, hash != "pending" else {
            return txHash ?? "—"
        }
        return "\(hash.prefix(6))...\(hash.suffix(4))"
    }
    
    var polygonscanURL: URL? {
        guard let hash = txHash, hash.count > 10, hash != "pending" else { return nil }
        return URL(string: "https://amoy.polygonscan.com/tx/\(hash)")
    }
    
    var hasBlockchainTx: Bool {
        guard let hash = txHash else { return false }
        return !hash.isEmpty && hash != "pending"
    }
    
    var isBlockchainPending: Bool {
        status == .pendingBlockchain
    }
    
    var relativeDate: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        return formatter.localizedString(for: createdDate, relativeTo: Date())
    }
    
    var fullDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .short
        return formatter.string(from: createdDate)
    }
}

enum TransactionType: String, Codable, CaseIterable {
    case buy, sell, deposit, withdraw, dividend
    case buyHsr = "buy_hsr"
    case sellHsr = "sell_hsr"
    
    /// Localization key: rawValue zaten "buy_hsr" / "sell_hsr" döndürür,
    /// xcstrings'deki "transactions.type.buy_hsr" keyleriyle birebir eşleşir.
    var label: String {
        String.localized("transactions.type.\(rawValue)")
    }
    
    var icon: String {
        switch self {
        case .buy:              return "arrow.down.left"
        case .sell:             return "arrow.up.right"
        case .deposit:          return "plus.circle"
        case .withdraw:         return "minus.circle"
        case .dividend:         return "sparkles"
        case .buyHsr, .sellHsr: return "arrow.left.arrow.right"
        }
    }
    
    var color: Color {
        switch self {
        case .buy:     return .hsPurple600
        case .sell:    return Color(hex: "#F472B6")
        case .deposit: return .hsSuccess
        case .withdraw: return .hsWarning
        case .dividend: return Color(hex: "#60A5FA")
        case .buyHsr:  return .hsPurple400
        case .sellHsr: return Color(hex: "#F472B6")
        }
    }
    
    var isPositive: Bool {
        switch self {
        case .sell, .deposit, .dividend, .sellHsr: return true
        case .buy, .withdraw, .buyHsr:             return false
        }
    }
}

enum TransactionStatus: String, Codable {
    case confirmed, completed, pending, failed
    case pendingBlockchain = "pending_blockchain"
    
    /// rawValue "pending_blockchain" → key "transactions.status.pending_blockchain" ✓
    var label: String {
        String.localized("transactions.status.\(rawValue)")
    }
    
    var color: Color {
        switch self {
        case .confirmed, .completed: return .hsSuccess
        case .pending:               return .hsWarning
        case .failed:                return .hsError
        case .pendingBlockchain:     return .hsPurple400
        }
    }
}
