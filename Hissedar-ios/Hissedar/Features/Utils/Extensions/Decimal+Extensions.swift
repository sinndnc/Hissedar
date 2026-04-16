//
//  Decimal+Extensions.swift
//  Hissedar
//
//  Created by Sinan Dinç on 3/22/26.
//

import Foundation

extension Decimal {
    var tlFormatted: String {
        let f = NumberFormatter()
        f.numberStyle            = .currency
        f.currencySymbol         = "₺"
        f.currencyCode           = "TRY"
        f.locale                 = Locale(identifier: "tr_TR")
        f.maximumFractionDigits  = 2
        return f.string(from: self as NSDecimalNumber) ?? "₺0"
    }

    var compactTLFormatted: String {
        let v = Double(truncating: self as NSDecimalNumber)
        switch v {
        case 1_000_000...: return String(format: "₺%.1fM",  v / 1_000_000)
        case 1_000...:     return String(format: "₺%.0fB",  v / 1_000)
        default:           return String(format: "₺%.0f",   v)
        }
    }

    var percentFormatted: String {
        String(format: "%%%0.1f", Double(truncating: self as NSDecimalNumber))
    }
    
    var tokenFormatted: String {
        "\(CurrencyFormatter.formatValue(self, currency: .TRY)) HSR"
    }
}

extension Double {
    var percentFormatted: String     { String(format: "%.1f%%", self) }
    var signedPercentFormatted: String {
        let p = self >= 0 ? "+" : ""
        return "\(p)\(String(format: "%.1f", self))%"
    }
}
