//
//  Wallet.swift
//  Hissedar
//

import Foundation

struct Wallet: Codable, Identifiable, Hashable {

    let id: String
    let userId: String
    let balance: Decimal          // TRY bakiye
    let lockedBalance: Decimal    // TRY kilitli
    let hsrBalance: Decimal       // HSR token bakiye
    let hsrLocked: Decimal        // HSR kilitli
    let createdAt: String
    let updatedAt: String

    enum CodingKeys: String, CodingKey {
        case id, balance
        case userId         = "user_id"
        case lockedBalance  = "locked_balance"
        case hsrBalance     = "hsr_balance"
        case hsrLocked      = "hsr_locked"
        case createdAt      = "created_at"
        case updatedAt      = "updated_at"
    }

    // MARK: - TRY Computed

    var availableTRY: Decimal {
        balance - lockedBalance
    }

    var formattedTRYBalance: String {
        CurrencyFormatter.format(balance, currency: .TRY)
    }

    var formattedAvailableTRY: String {
        CurrencyFormatter.format(availableTRY, currency: .TRY)
    }

    // MARK: - HSR Computed

    var availableHSR: Decimal {
        hsrBalance - hsrLocked
    }

    var formattedHSRBalance: String {
        "\(CurrencyFormatter.formatValue(hsrBalance, currency: .TRY)) HSR"
    }

    var formattedAvailableHSR: String {
        "\(CurrencyFormatter.formatValue(availableHSR, currency: .TRY)) HSR"
    }

    // MARK: - Total (TRY cinsinden, 1 HSR = 1 TRY)

    var totalBalanceInTRY: Decimal {
        balance + hsrBalance
    }

    var formattedTotalBalance: String {
        CurrencyFormatter.format(totalBalanceInTRY, currency: .TRY)
    }
}
