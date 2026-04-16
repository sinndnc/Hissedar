//
//  PriceAlert.swift
//  Hissedar
//
//  Fiyat alarm sistemi için model ve enum'lar.
//  Backend: price_alerts tablosu ile uyumludur.
//

import Foundation

// MARK: - Koşul Tipi

enum PriceAlertCondition: String, Codable, CaseIterable, Identifiable {
    case below          // Fiyat hedefin altına düşerse
    case above          // Fiyat hedefin üstüne çıkarsa
    case percentChange = "percent_change"  // Baz fiyattan yüzde X değişirse

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .below:         return "Fiyat altına düşerse"
        case .above:         return "Fiyat üstüne çıkarsa"
        case .percentChange: return "Yüzde değişim"
        }
    }

    var shortLabel: String {
        switch self {
        case .below:         return "Altına düşerse"
        case .above:         return "Üstüne çıkarsa"
        case .percentChange: return "% değişim"
        }
    }

    var systemIcon: String {
        switch self {
        case .below:         return "arrow.down.circle.fill"
        case .above:         return "arrow.up.circle.fill"
        case .percentChange: return "percent"
        }
    }
}

// MARK: - Davranış Tipi

enum PriceAlertBehavior: String, Codable, CaseIterable, Identifiable {
    case oneShot = "one_shot"     // Bir kez tetiklendikten sonra kapanır
    case recurring                 // Her koşul sağlandığında tetiklenir

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .oneShot:   return "Tek seferlik"
        case .recurring: return "Sürekli"
        }
    }

    var description: String {
        switch self {
        case .oneShot:   return "Bir kez tetiklendikten sonra otomatik kapanır"
        case .recurring: return "Koşul her sağlandığında bildirim gönderilir"
        }
    }
}

// MARK: - PriceAlert Model

struct PriceAlert: Identifiable, Codable, Equatable {
    let id: String
    let userId: String
    let propertyId: String

    let conditionType: PriceAlertCondition
    let targetPrice: Decimal?
    let percentDelta: Decimal?
    let basePrice: Decimal?

    let behavior: PriceAlertBehavior
    let isActive: Bool
    let lastTriggeredAt: Date?
    let triggerCount: Int

    let createdAt: Date
    let updatedAt: Date

    enum CodingKeys: String, CodingKey {
        case id
        case userId          = "user_id"
        case propertyId      = "property_id"
        case conditionType   = "condition_type"
        case targetPrice     = "target_price"
        case percentDelta    = "percent_delta"
        case basePrice       = "base_price"
        case behavior
        case isActive        = "is_active"
        case lastTriggeredAt = "last_triggered_at"
        case triggerCount    = "trigger_count"
        case createdAt       = "created_at"
        case updatedAt       = "updated_at"
    }
}

// MARK: - Insert Request

/// Yeni alarm oluşturmak için kullanılan payload.
/// Server-side alanlar (id, created_at, trigger_count) dışarıda tutulur.
struct CreatePriceAlertRequest: Encodable {
    let userId: String
    let propertyId: String
    let conditionType: PriceAlertCondition
    let targetPrice: Decimal?
    let percentDelta: Decimal?
    let basePrice: Decimal?
    let behavior: PriceAlertBehavior
    let isActive: Bool

    enum CodingKeys: String, CodingKey {
        case userId        = "user_id"
        case propertyId    = "property_id"
        case conditionType = "condition_type"
        case targetPrice   = "target_price"
        case percentDelta  = "percent_delta"
        case basePrice     = "base_price"
        case behavior
        case isActive      = "is_active"
    }

    // MARK: - Factory

    /// "Altına düşerse" alarm oluştur
    static func below(
        userId: String,
        propertyId: String,
        targetPrice: Decimal,
        behavior: PriceAlertBehavior = .oneShot
    ) -> CreatePriceAlertRequest {
        CreatePriceAlertRequest(
            userId: userId,
            propertyId: propertyId,
            conditionType: .below,
            targetPrice: targetPrice,
            percentDelta: nil,
            basePrice: nil,
            behavior: behavior,
            isActive: true
        )
    }

    /// "Üstüne çıkarsa" alarm oluştur
    static func above(
        userId: String,
        propertyId: String,
        targetPrice: Decimal,
        behavior: PriceAlertBehavior = .oneShot
    ) -> CreatePriceAlertRequest {
        CreatePriceAlertRequest(
            userId: userId,
            propertyId: propertyId,
            conditionType: .above,
            targetPrice: targetPrice,
            percentDelta: nil,
            basePrice: nil,
            behavior: behavior,
            isActive: true
        )
    }

    /// "Yüzde değişim" alarm oluştur
    /// - Parameter percentDelta: Pozitif = artış, negatif = düşüş (ör. 5.0 = %5 artış, -3.0 = %3 düşüş)
    /// - Parameter basePrice: Alarm kurulurken referans alınan güncel fiyat
    static func percentChange(
        userId: String,
        propertyId: String,
        percentDelta: Decimal,
        basePrice: Decimal,
        behavior: PriceAlertBehavior = .oneShot
    ) -> CreatePriceAlertRequest {
        CreatePriceAlertRequest(
            userId: userId,
            propertyId: propertyId,
            conditionType: .percentChange,
            targetPrice: nil,
            percentDelta: percentDelta,
            basePrice: basePrice,
            behavior: behavior,
            isActive: true
        )
    }
}

// MARK: - Kullanıcı Dostu Açıklama

extension PriceAlert {
    /// Alarm kartında gösterilecek kullanıcı dostu koşul açıklaması
    var conditionDescription: String {
        switch conditionType {
        case .below:
            let price = targetPrice?.tlFormatted ?? "-"
            return "Fiyat \(price) altına düşerse"
        case .above:
            let price = targetPrice?.tlFormatted ?? "-"
            return "Fiyat \(price) üstüne çıkarsa"
        case .percentChange:
            guard let delta = percentDelta else { return "Yüzde değişim" }
            let sign = delta >= 0 ? "+" : ""
            return "%\(sign)\(delta) değişirse"
        }
    }

    /// "Aktif" / "Pasif" / "Tetiklendi" gibi durum etiketi
    var statusLabel: String {
        if !isActive { return "Pasif" }
        if triggerCount > 0 && behavior == .recurring {
            return "Aktif (son tetik: \(lastTriggeredAt?.shortRelative ?? "-"))"
        }
        return "Aktif"
    }
}

// MARK: - Yardımcı Formatter
// NOT: Decimal.tlFormatted projede zaten var, tekrar tanımlamıyoruz.
// shortRelative için bu extension'ı koruyoruz.

private extension Date {
    var shortRelative: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.locale = Locale(identifier: "tr_TR")
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: self, relativeTo: Date())
    }
}