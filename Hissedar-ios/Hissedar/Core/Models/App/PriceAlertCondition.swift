//
//  AssetPriceAlert.swift
//  Hissedar
//
//  Generic fiyat alarmı — property/art/nft için çalışır.
//

import Foundation

// MARK: - Koşul Tipi

enum PriceAlertCondition: String, Codable, CaseIterable, Identifiable {
    case below
    case above
    case percentChange = "percent_change"

    var id: String { rawValue }

    var displayName: String {
        return String.localized("alert.condition.\(self.rawValue).display")
    }

    var shortLabel: String {
        return String.localized("alert.condition.\(self.rawValue).short")
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
    case oneShot = "one_shot"
    case recurring

    var id: String { rawValue }

    var displayName: String {
        return String.localized("alert.behavior.\(self.rawValue).display")
    }

    var description: String {
        return String.localized("alert.behavior.\(self.rawValue).desc")
    }
}

// MARK: - AssetPriceAlert Model

struct AssetPriceAlert: Identifiable, Codable, Equatable {
    let id: String
    let userId: String

    let assetId: String
    let assetType: AssetType

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
        case assetId         = "asset_id"
        case assetType       = "asset_type"
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

struct CreateAssetPriceAlertRequest: Encodable {
    let userId: String
    let assetId: String
    let assetType: AssetType
    let conditionType: PriceAlertCondition
    let targetPrice: Decimal?
    let percentDelta: Decimal?
    let basePrice: Decimal?
    let behavior: PriceAlertBehavior
    let isActive: Bool

    enum CodingKeys: String, CodingKey {
        case userId        = "user_id"
        case assetId       = "asset_id"
        case assetType     = "asset_type"
        case conditionType = "condition_type"
        case targetPrice   = "target_price"
        case percentDelta  = "percent_delta"
        case basePrice     = "base_price"
        case behavior
        case isActive      = "is_active"
    }

    static func below(
        userId: String,
        assetId: String,
        assetType: AssetType,
        targetPrice: Decimal,
        behavior: PriceAlertBehavior = .oneShot
    ) -> Self {
        .init(userId: userId, assetId: assetId, assetType: assetType, conditionType: .below, targetPrice: targetPrice, percentDelta: nil, basePrice: nil, behavior: behavior, isActive: true)
    }

    static func above(
        userId: String,
        assetId: String,
        assetType: AssetType,
        targetPrice: Decimal,
        behavior: PriceAlertBehavior = .oneShot
    ) -> Self {
        .init(userId: userId, assetId: assetId, assetType: assetType, conditionType: .above, targetPrice: targetPrice, percentDelta: nil, basePrice: nil, behavior: behavior, isActive: true)
    }

    static func percentChange(
        userId: String,
        assetId: String,
        assetType: AssetType,
        percentDelta: Decimal,
        basePrice: Decimal,
        behavior: PriceAlertBehavior = .oneShot
    ) -> Self {
        .init(userId: userId, assetId: assetId, assetType: assetType, conditionType: .percentChange, targetPrice: nil, percentDelta: percentDelta, basePrice: basePrice, behavior: behavior, isActive: true)
    }
}

// MARK: - Kullanıcı Dostu Açıklama

extension AssetPriceAlert {
    var conditionDescription: String {
        switch conditionType {
        case .below:
            let price = CurrencyFormatter.format(targetPrice ?? 0, currency: .TRY)
            return String(format: String.localized("alert.desc.below"), price)
        case .above:
            let price = CurrencyFormatter.format(targetPrice ?? 0, currency: .TRY)
            return String(format: String.localized("alert.desc.above"), price)
        case .percentChange:
            let delta = percentDelta ?? 0
            let sign = delta >= 0 ? "+" : ""
            return String(format: String.localized("alert.desc.percent"), "\(sign)\(delta)")
        }
    }

    var statusLabel: String {
        return isActive ? String.localized("common.active") : String.localized("common.passive")
    }
}
