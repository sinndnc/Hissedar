//
//  PortfolioItem.swift
//  Hissedar
//
//  Supabase portfolio_view'dan gelen kullanıcı pozisyonu.
//  UI'da AssetDisplayItem'a dönüştürülerek kullanılır.
//

import Foundation

struct PortfolioItem: Codable, Identifiable {

    // ── Identifiers ────────────────────────────────────
    let id: String
    let userId: String
    let assetId: String
    let assetType: AssetType
    let cashBalance: Decimal?
    let lockedBalance: Decimal?
    
    // ── Asset snapshot (view/join) ─────────────────────
    let assetTitle: String
    let assetCategory: String
    let assetImageUrl: String?
    let assetStatus: AssetStatus
    let city: String?
    let annualYield: Double?
    let currentTokenPrice: Decimal

    // ── User position ──────────────────────────────────
    let tokenAmount: Int
    let avgPurchasePrice: Decimal
    let currentValue: Decimal
    let unrealizedPnl: Decimal
    let totalRentEarned: Decimal
    let pendingRent: Decimal?

    // ── Timestamps ─────────────────────────────────────
    let createdAt: String
    let updatedAt: String

    // ── CodingKeys ─────────────────────────────────────
    enum CodingKeys: String, CodingKey {
        case id, city
        case cashBalance       = "cash_balance"
        case lockedBalance     = "locked_balance"
        case userId            = "user_id"
        case assetId           = "asset_id"
        case assetType         = "asset_type"
        case assetTitle        = "asset_title"
        case assetCategory     = "asset_category"
        case assetImageUrl     = "asset_image_url"
        case assetStatus       = "asset_status"
        case annualYield       = "annual_yield"
        case currentTokenPrice = "current_token_price"
        case tokenAmount       = "token_amount"
        case avgPurchasePrice  = "avg_purchase_price"
        case currentValue      = "current_value"
        case unrealizedPnl     = "unrealized_pnl"
        case totalRentEarned   = "total_rent_earned"
        case pendingRent       = "pending_rent"
        case createdAt         = "created_at"
        case updatedAt         = "updated_at"
    }
}

// MARK: - Bridge → AssetDisplayItem

extension PortfolioItem {

    func toDisplayItem() -> AssetItem {
        AssetItem(
            id: assetId,
            assetType: assetType,
            title: assetTitle,
            subtitle: city,
            category: assetCategory,
            currentValue: currentTokenPrice,
            priceChangePercent: returnRate,
            imageUrl: assetImageUrl,
            badge: nil,
            // Portfolio-specific
            createdAt: createdAt,
            tokenAmount: tokenAmount,
            avgPurchasePrice: avgPurchasePrice,
            unrealizedPnl: unrealizedPnl,
            totalRentEarned: totalRentEarned,
            pendingRent: pendingRent
        )
    }
}

// MARK: - Computed (internal kullanım)

extension PortfolioItem {
    
    var isPositive: Bool { unrealizedPnl >= 0 }
    
    var returnRate: Double {
        let cost = avgPurchasePrice * Decimal(tokenAmount)
        guard cost > 0 else { return 0 }
        return Double(truncating: (unrealizedPnl / cost * 100) as NSDecimalNumber)
    }
    
    var hasPendingRent: Bool { pendingRent ?? 0 > 0 }
}
