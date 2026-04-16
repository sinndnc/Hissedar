//
//  Art.swift
//  Hissedar
//

import Foundation

struct Art: AssetRepresentable {

    let id: String
    let title: String
    let category: String
    let currentValue: Decimal
    let priceChangePercent: Double
    let totalShareholders: Int
    let imageUrl: String?
    let badge: String?
    let status: AssetStatus
    let createdAt: String?
    let updatedAt: String?
    let blockchainTokenId: Int?
    
    // Art-specific
    let artistName: String?
    let description: String?
    let totalTokens: Int
    let soldTokens: Int
    let remainingTokens: Int?
    let annualYield: Decimal?
    let medium: String?
    let dimensions: String?
    let provenance: String?
    let yearCreated: Int?

    // MARK: - AssetRepresentable

    var assetType: AssetType { .art }

    var formattedPrice: String {
        CurrencyFormatter.format(currentValue, currency: .TRY)
    }

    // MARK: - Art Computed

    var fundingPercent: Double {
        guard totalTokens > 0 else { return 0 }
        return Double(soldTokens) / Double(totalTokens) * 100
    }

    var tokenPrice: Decimal {
        guard totalTokens > 0 else { return 0 }
        return currentValue / Decimal(totalTokens)
    }

    var formattedTokenPrice: String {
        CurrencyFormatter.format(tokenPrice, currency: .TRY)
    }

    var formattedAnnualYield: String {
        guard let yield = annualYield else { return "-" }
        return CurrencyFormatter.formatPercent(NSDecimalNumber(decimal: yield).doubleValue)
    }

    // MARK: - CodingKeys

    enum CodingKeys: String, CodingKey {
        case id, title, category, badge, status, description
        case medium, dimensions, provenance
        case currentValue       = "current_value"
        case priceChangePercent = "price_change_percent"
        case totalShareholders  = "total_shareholders"
        case imageUrl           = "image_url"
        case createdAt          = "created_at"
        case updatedAt          = "updated_at"
        case artistName         = "artist_name"
        case totalTokens        = "total_tokens"
        case soldTokens         = "sold_tokens"
        case remainingTokens    = "remaining_tokens"
        case annualYield        = "annual_yield"
        case yearCreated        = "year_created"
        case blockchainTokenId = "blockchain_token_id"
    }

    // MARK: - toDisplayItem

    func toDisplayItem() -> AssetItem {
        AssetItem(
            id: id,
            assetType: .art,
            title: title,
            subtitle: artistName ?? category,
            category: category,
            currentValue: currentValue,
            priceChangePercent: priceChangePercent,
            imageUrl: imageUrl,
            badge: badge,
            status: status,
            annualYield: annualYield,
            totalTokens: totalTokens,
            soldTokens: soldTokens,
            createdAt: createdAt
        )
    }
}

extension Art {
    var trendingSubtitle: String {
        "\(category) • \(totalShareholders.formatted()) hissedar"
    }
    var listMeta: [String] {
        [category, "\(totalShareholders.formatted()) hissedar"]
    }
}
