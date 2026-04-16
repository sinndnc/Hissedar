//
//  TokenExchange.swift
//  Hissedar
//
//  Created by Sinan Dinç on 4/9/26.
//

import Foundation

struct TokenExchange: Codable, Identifiable, Hashable {

    let id: String
    let userId: String
    let direction: ExchangeDirection
    let tryAmount: Decimal
    let hsrAmount: Decimal
    let exchangeRate: Decimal
    let fee: Decimal
    let status: String
    let createdAt: String

    enum CodingKeys: String, CodingKey {
        case id, direction, fee, status
        case userId         = "user_id"
        case tryAmount      = "try_amount"
        case hsrAmount      = "hsr_amount"
        case exchangeRate   = "exchange_rate"
        case createdAt      = "created_at"
    }

    // MARK: - Computed

    var isBuy: Bool { direction == .buyHSR }

    var formattedTRY: String {
        CurrencyFormatter.format(tryAmount, currency: .TRY)
    }

    var formattedHSR: String {
        "\(CurrencyFormatter.formatValue(hsrAmount, currency: .TRY)) HSR"
    }

    var formattedFee: String {
        CurrencyFormatter.format(fee, currency: .TRY)
    }

    var summary: String {
        isBuy
            ? "\(formattedTRY) → \(formattedHSR)"
            : "\(formattedHSR) → \(formattedTRY)"
    }
}

// MARK: - Exchange Direction

enum ExchangeDirection: String, Codable {
    case buyHSR  = "buy_hsr"
    case sellHSR = "sell_hsr"

    var label: String {
        switch self {
        case .buyHSR:  "HSR Satın Al"
        case .sellHSR: "HSR Sat"
        }
    }

    var icon: String {
        switch self {
        case .buyHSR:  "arrow.down.circle.fill"
        case .sellHSR: "arrow.up.circle.fill"
        }
    }
}
