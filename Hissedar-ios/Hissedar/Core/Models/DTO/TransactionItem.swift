//
//  TransactionItem.swift
//  Hissedar
//
//  Created by Sinan Dinç on 4/8/26.
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
        ISO8601DateFormatter().date(from: createdAt) ?? .now
    }
    
    var formattedAmount: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "TRY"
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: amount ?? 0)) ?? "₺\(amount ?? 0)"
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
        let interval = Date().timeIntervalSince(createdDate)
        if interval < 3600 { return "Az önce" }
        if interval < 86400 { return "\(Int(interval / 3600)) saat önce" }
        if interval < 172800 { return "Dün" }
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "tr_TR")
        formatter.dateFormat = "d MMM"
        return formatter.string(from: createdDate)
    }
    
    var fullDate: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "tr_TR")
        formatter.dateFormat = "d MMMM yyyy, HH:mm"
        return formatter.string(from: createdDate)
    }
}


enum TransactionType: String, Codable, CaseIterable {
    case buy, sell, deposit, withdraw, dividend
    case buyHsr = "buy_hsr"
    case sellHsr = "sell_hsr"
    
    var label: String {
        switch self {
        case .buy: "Alım"
        case .sell: "Satım"
        case .deposit: "Yatırma"
        case .withdraw: "Çekme"
        case .dividend: "Kâr Payı"
        case .buyHsr: "HSR Alım"
        case .sellHsr: "HSR Satım"
        }
    }
    
    var icon: String {
        switch self {
        case .buy: "arrow.down.left"
        case .sell: "arrow.up.right"
        case .deposit: "plus.circle"
        case .withdraw: "minus.circle"
        case .dividend: "sparkles"
        case .buyHsr: "arrow.left.arrow.right"
        case .sellHsr: "arrow.left.arrow.right"
        }
    }
    
    var color: Color {
        switch self {
        case .buy: .hsPurple600
        case .sell: Color(hex: "#F472B6")
        case .deposit: .hsSuccess
        case .withdraw: .hsWarning
        case .dividend: Color(hex: "#60A5FA")
        case .buyHsr: .hsPurple400
        case .sellHsr: Color(hex: "#F472B6")
        }
    }
    
    var isPositive: Bool {
        switch self {
        case .sell, .deposit, .dividend, .sellHsr: true
        case .buy, .withdraw, .buyHsr: false
        }
    }
}

enum TransactionStatus: String, Codable {
    case confirmed
    case completed
    case pending
    case failed
    case pendingBlockchain = "pending_blockchain"
    
//    case unknown

    var label: String {
        switch self {
        case .confirmed: "Tamamlandı"
        case .completed: "Tamamlandı"
        case .pending: "Beklemede"
        case .failed: "Başarısız"
        case .pendingBlockchain: "Blockchain Bekleniyor"
        }
    }
    
    var color: Color {
        switch self {
        case .confirmed: .hsSuccess
        case .completed: .hsSuccess
        case .pending: .hsWarning
        case .failed: .hsError
        case .pendingBlockchain: .hsPurple400
        }
    }
}
