//
//  AssetItem.swift
//  Hissedar
//
//  WatchlistView ve PortfolioView'da ortak kullanılan
//  tek UI modeli. Domain model'ler (Property, Art, NFT)
//  toDisplayItem() ile bu struct'a dönüşür.
//

import Foundation

struct AssetItem: Codable, Identifiable, Hashable {

    // ── Core ───────────────────────────────────────────
    let id: String
    let assetType: AssetType
    let title: String
    let subtitle: String?
    let category: String
    let currentValue: Decimal         // HSR cinsinden fiyat (1 HSR = 1 TRY)
    let priceChangePercent: Double
    let imageUrl: String?
    let badge: String?

    // ── Trade-specific (opsiyonel) ─────────────────────
    var status: AssetStatus?
    var annualYield: Decimal?
    var totalTokens: Int?
    var soldTokens: Int?
    // ── Timestamps ─────────────────────────────────────
    let createdAt: String?

    // ── Portfolio-specific (opsiyonel) ─────────────────
    var tokenAmount: Int?
    var avgPurchasePrice: Decimal?
    var unrealizedPnl: Decimal?
    var totalRentEarned: Decimal?
    var pendingRent: Decimal?
    
    var totalValue: Decimal?
    var blockchainTokenId: Int?
    var contractAddress: String?

    // Property
    var propertyAddress: String?
    var propertyCity: String?
    var propertyTokenPrice: Decimal?
    var propertyMonthlyRent: Decimal?
    var propertyLatitude: Double?
    var propertyLongitude: Double?
    var propertySpvName: String?
    var propertySpvTaxNumber: String?
    var propertySpvDescription: String? // propertyDescription -> propertySpvDescription (tutarlılık için)

    // Art
    var artArtistName: String?
    var artProvenance: String?
    var artYearCreated: Int?
    var artMedium: String?
    var artDimensions: String?

    // NFT
    var nftCollectionName: String?
    var nftTokenId: Int?
    var nftBlockchain: String?
    var nftContractAddress: String?
    var nftMetadataUrl: String?

    enum CodingKeys: String, CodingKey {
        case id, title, subtitle, category, status, badge
        
        case assetType          = "asset_type"
        case currentValue       = "current_value"
        case priceChangePercent = "price_change_percent"
        case imageUrl           = "image_url"
        case annualYield        = "annual_yield"
        case totalTokens        = "total_tokens"
        case soldTokens         = "sold_tokens"
        case createdAt          = "created_at"
        case tokenAmount        = "token_amount"
        case avgPurchasePrice   = "avg_purchase_price"
        case unrealizedPnl      = "unrealized_pnl"
        case totalRentEarned    = "total_rent_earned"
        case pendingRent        = "pending_rent"

        // ── Detail fields ──
        case totalValue         = "total_value"
        case blockchainTokenId  = "blockchain_token_id"
        case contractAddress    = "contract_address"

        // Property
        case propertyAddress    = "property_address"
        case propertyCity       = "property_city"
        case propertyTokenPrice = "property_token_price"
        case propertyMonthlyRent = "property_monthly_rent"
        case propertyLatitude   = "property_latitude"
        case propertyLongitude  = "property_longitude"
        case propertySpvName    = "property_spv_name"
        case propertySpvTaxNumber = "property_spv_tax_number"
        case propertySpvDescription = "property_description"

        // Art
        case artArtistName      = "art_artist_name"
        case artProvenance      = "art_provenance"
        case artYearCreated     = "art_year_created"
        case artMedium          = "art_medium"
        case artDimensions      = "art_dimensions"

        // NFT
        case nftCollectionName  = "nft_collection_name"
        case nftTokenId         = "nft_token_id"
        case nftBlockchain      = "nft_blockchain"
        case nftContractAddress = "nft_contract_address"
        case nftMetadataUrl     = "nft_metadata_url"
    }
}

// MARK: - Currency Helper

extension AssetItem {

    /// Tüm varlıklar HSR ile fiyatlandırılıyor (1 HSR = 1 TRY)
    var currency: CurrencyType { .HSR }

    /// TRY karşılığı göstermek için
    var displayCurrency: CurrencyType { .TRY }
}

// MARK: - Ortak Computed

extension AssetItem {

    var isPositive: Bool { priceChangePercent >= 0 }
    var sparklineData: [Double] { [] }
    var icon: String { assetType.icon }
    var typeLabel: String { assetType.label }

    /// HSR fiyatı (= TRY karşılığı)
    var formattedPrice: String {
        CurrencyFormatter.format(currentValue, currency: .TRY)
    }

    /// HSR olarak gösterim
    var formattedHSRPrice: String {
        "\(CurrencyFormatter.formatValue(currentValue, currency: .TRY)) HSR"
    }

    var formattedChange: String {
        CurrencyFormatter.formatPercent(priceChangePercent)
    }

    var formattedTotalCashPrice: String {
        let total = currentValue * Decimal(tokenAmount ?? 1)
        return CurrencyFormatter.format(total, currency: .TRY)
    }
    
    var formattedTotalTokenPrice: String {
        let total = currentValue * Decimal(tokenAmount ?? 1)
        return CurrencyFormatter.format(total, currency: .HSR)
    }
    
    // Backward compatibility
    var unrealizedGain: Decimal? { unrealizedPnl }
    
    var trendingSubtitle: String {
        category
    }
 
    var listMeta: [String] {
        var meta: [String] = [category]
        if let yield = annualYield, yield > 0 {
            let yieldVal = CurrencyFormatter.formatValue(yield, currency: .TRY)
            meta.append(String(format: String.localized("asset.meta.yield"), yieldVal))
        }
        return meta
    }
    
    var holdingPercent: Double {
        guard let owned = tokenAmount,
              let total = totalTokens,
              total > 0 else { return 0 }
        return Double(owned) / Double(total)
    }
}

// MARK: - Trade Computed

extension AssetItem {

    var fundingPercent: Double {
        guard let total = totalTokens, let sold = soldTokens, total > 0 else { return 0 }
        return Double(sold) / Double(total) * 100
    }

    var remainingTokens: Int {
        guard let total = totalTokens, let sold = soldTokens else { return 0 }
        return total - sold
    }

    var isSoldOut: Bool { remainingTokens <= 0 }

    var annualYieldPercent: Double {
        guard let yield = annualYield else { return 0 }
        return NSDecimalNumber(decimal: yield).doubleValue
    }
}

// MARK: - Portfolio Computed

extension AssetItem {

    var isGainPositive: Bool { (unrealizedPnl ?? 0) >= 0 }

    var returnRate: Double {
        guard let avg = avgPurchasePrice,
              let amount = tokenAmount else { return 0 }
        let cost = avg * Decimal(amount)
        guard cost > 0, let gain = unrealizedPnl else { return 0 }
        return Double(truncating: (gain / cost * 100) as NSDecimalNumber)
    }

    var hasPendingRent: Bool { (pendingRent ?? 0) > 0 }

    var formattedGain: String {
        CurrencyFormatter.formatSigned(unrealizedPnl ?? 0, currency: .TRY)
    }

    var formattedReturnRate: String {
        CurrencyFormatter.formatPercent(returnRate)
    }

    var formattedRentEarned: String {
        CurrencyFormatter.format(totalRentEarned ?? 0, currency: .TRY)
    }

    var formattedPendingRent: String {
        CurrencyFormatter.format(pendingRent ?? 0, currency: .TRY)
    }

    var formattedTokenPrice: String {
        CurrencyFormatter.format(currentValue, currency: .TRY)
    }
}

// MARK: - Portfolio Enrichment

extension AssetItem {

    func withPortfolio(
        tokenAmount: Int,
        avgPurchasePrice: Decimal,
        unrealizedPnl: Decimal,
        totalRentEarned: Decimal,
        pendingRent: Decimal
    ) -> AssetItem {
        var copy = self
        copy.tokenAmount = tokenAmount
        copy.avgPurchasePrice = avgPurchasePrice
        copy.unrealizedPnl = unrealizedPnl
        copy.totalRentEarned = totalRentEarned
        copy.pendingRent = pendingRent
        return copy
    }
}

// MARK: - Convenience Array Extensions

extension Array where Element: AssetRepresentable {

    func toDisplayItems() -> [AssetItem] {
        map { $0.toDisplayItem() }
    }
}
