//
//  RentHistory.swift
//  Hissedar
//
//  Created by Sinan Dinç on 4/13/26.
//
//  user_rent_history view'dan gelen kira geçmişi modeli.
//

import Foundation

struct RentHistory: Codable, Identifiable {
    
    let transactionId: String
    let userId: String
    let assetId: String
    let assetType: String
    let rentAmount: Decimal
    let description: String?
    let paidAt: Date?
    let periodYear: Int?
    let periodMonth: Int?
    let propertyTotalRent: Decimal?
    let assetTitle: String?
    let assetImageUrl: String?
    let propertyCity: String?
    
    var id: String { transactionId }
    
    enum CodingKeys: String, CodingKey {
        case transactionId    = "transaction_id"
        case userId           = "user_id"
        case assetId          = "asset_id"
        case assetType        = "asset_type"
        case rentAmount       = "rent_amount"
        case description
        case paidAt           = "paid_at"
        case periodYear       = "period_year"
        case periodMonth      = "period_month"
        case propertyTotalRent = "property_total_rent"
        case assetTitle       = "asset_title"
        case assetImageUrl    = "asset_image_url"
        case propertyCity     = "property_city"
    }
    
    // MARK: - Computed
    
    var formattedAmount: String {
        CurrencyFormatter.format(rentAmount, currency: .TRY)
    }
    
    var periodLabel: String {
        guard let year = periodYear, let month = periodMonth else {
            return "—"
        }
        let monthNames = [
            "Ocak", "Şubat", "Mart", "Nisan", "Mayıs", "Haziran",
            "Temmuz", "Ağustos", "Eylül", "Ekim", "Kasım", "Aralık"
        ]
        let monthName = month >= 1 && month <= 12 ? monthNames[month - 1] : "\(month)"
        return "\(monthName) \(year)"
    }
    
    /// Kullanıcının bu mülkün toplam kirasından aldığı pay yüzdesi
    var sharePercent: Double? {
        guard let total = propertyTotalRent, total > 0 else { return nil }
        return Double(truncating: (rentAmount / total * 100) as NSDecimalNumber)
    }
    
    var formattedSharePercent: String? {
        guard let pct = sharePercent else { return nil }
        return String(format: "%%%.1f", pct)
    }
}
