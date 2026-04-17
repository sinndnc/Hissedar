//
//  CurrencyFormatter.swift
//  Hissedar
//
//  Merkezi para birimi formatlaması.
//

import Foundation

// MARK: - Currency Type

enum CurrencyType: String, Codable, CaseIterable {
    case TRY
    case USD
    case EUR
    case ETH
    case USDT
    case HSR

    var symbol: String {
        switch self {
        case .TRY:  return "₺"
        case .USD:  return "$"
        case .EUR:  return "€"
        case .ETH:  return "Ξ"
        case .USDT: return "$"
        case .HSR:  return "HSR "
        }
    }

    var code: String { rawValue }

    var locale: Locale {
        switch self {
        case .TRY:  return Locale(identifier: "tr_TR")
        case .USD:  return Locale(identifier: "en_US")
        case .EUR:  return Locale(identifier: "de_DE")
        case .ETH:  return Locale(identifier: "en_US")
        case .USDT: return Locale(identifier: "en_US")
        case .HSR:  return Locale(identifier: "tr_TR")
        }
    }

    var defaultFractionDigits: Int {
        switch self {
        case .TRY:  return 0
        case .USD:  return 2
        case .EUR:  return 2
        case .ETH:  return 4
        case .USDT: return 2
        case .HSR:  return 0
        }
    }
}

// MARK: - Currency Formatter

enum CurrencyFormatter {

    private static let formattersQueue = DispatchQueue(label: "com.hissedar.currencyFormatter")
    private static var cache: [String: NumberFormatter] = [:]

    private static func formatter(
        for currency: CurrencyType,
        fractionDigits: Int
    ) -> NumberFormatter {
        let key = "\(currency.rawValue)-\(fractionDigits)"

        return formattersQueue.sync {
            if let cached = cache[key] { return cached }

            let fmt = NumberFormatter()
            fmt.numberStyle = .decimal
            fmt.locale = currency.locale
            fmt.minimumFractionDigits = fractionDigits
            fmt.maximumFractionDigits = fractionDigits
            fmt.groupingSeparator = currency.locale.groupingSeparator
            fmt.decimalSeparator = currency.locale.decimalSeparator
            cache[key] = fmt
            return fmt
        }
    }

    static func format(
        _ value: Decimal,
        currency: CurrencyType,
        fractionDigits: Int? = nil
    ) -> String {
        let digits = fractionDigits ?? currency.defaultFractionDigits
        let fmt = formatter(for: currency, fractionDigits: digits)
        let number = NSDecimalNumber(decimal: value)
        let formatted = fmt.string(from: number) ?? "\(value)"
        return "\(currency.symbol)\(formatted)"
    }

    static func formatValue(
        _ value: Decimal,
        currency: CurrencyType,
        fractionDigits: Int? = nil
    ) -> String {
        let digits = fractionDigits ?? currency.defaultFractionDigits
        let fmt = formatter(for: currency, fractionDigits: digits)
        let number = NSDecimalNumber(decimal: value)
        return fmt.string(from: number) ?? "\(value)"
    }

    static func formatSigned(
        _ value: Decimal,
        currency: CurrencyType,
        fractionDigits: Int? = nil
    ) -> String {
        let sign = value > 0 ? "+" : (value < 0 ? "-" : "")
        let formatted = format(abs(value), currency: currency, fractionDigits: fractionDigits)
        return "\(sign)\(formatted)"
    }

    static func formatCompact(
        _ value: Decimal,
        currency: CurrencyType
    ) -> String {
        let doubleValue = NSDecimalNumber(decimal: abs(value)).doubleValue
        let sign = value < 0 ? "-" : ""

        switch doubleValue {
        case 1_000_000_000...:
            return "\(sign)\(currency.symbol)\(String(format: "%.1f", doubleValue / 1_000_000_000))B"
        case 1_000_000...:
            return "\(sign)\(currency.symbol)\(String(format: "%.1f", doubleValue / 1_000_000))M"
        case 1_000...:
            return "\(sign)\(currency.symbol)\(String(format: "%.0f", doubleValue / 1_000))K"
        default:
            return "\(sign)\(format(abs(value), currency: currency))"
        }
    }

    static func formatPercent(_ value: Double) -> String {
        let sign = value >= 0 ? "+" : ""
        return "\(sign)\(String(format: "%.1f", value))%"
    }
}
