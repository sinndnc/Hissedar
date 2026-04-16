//
//  PortfolioSummary.swift
//  Hissedar
//
//  Created by Sinan Dinç on 4/9/26.
//

import Foundation

struct PortfolioSummary {
    let totalValue: Decimal
    let totalGain: Decimal
    let totalRentEarned: Decimal
    let totalPendingRent: Decimal
    let assetCount: Int
    let cashBalance: Decimal
    let lockedBalance: Decimal

    var netWorth: Decimal { cashBalance + totalValue }
    var isPositive: Bool { totalGain >= 0 }

    var returnRate: Double {
        let cost = totalValue - totalGain
        guard cost > 0 else { return 0 }
        return Double(truncating: (totalGain / cost * 100) as NSDecimalNumber)
    }

    var formattedTotalValue: String {
        "₺\(NSDecimalNumber(decimal: totalValue).intValue.formatted())"
    }

    var formattedNetWorth: String {
        "₺\(NSDecimalNumber(decimal: netWorth).intValue.formatted())"
    }

    var formattedCashBalance: String {
        "₺\(NSDecimalNumber(decimal: cashBalance).intValue.formatted())"
    }

    var formattedTotalGain: String {
        let sign = isPositive ? "+" : ""
        return "\(sign)₺\(NSDecimalNumber(decimal: totalGain).intValue.formatted())"
    }

    var formattedReturnRate: String {
        let sign = returnRate >= 0 ? "+" : ""
        return "\(sign)\(String(format: "%.1f", returnRate))%"
    }

    var formattedRentEarned: String {
        "₺\(NSDecimalNumber(decimal: totalRentEarned).intValue.formatted())"
    }

    var formattedPendingRent: String {
        "₺\(NSDecimalNumber(decimal: totalPendingRent).intValue.formatted())"
    }
}
