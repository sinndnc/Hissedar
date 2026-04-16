//
//  Property.swift
//  Hissedar
//

import Foundation

struct Property: AssetRepresentable, Hashable {

    let id: String
    let title: String
    let category: String
    let priceChangePercent: Double
    let imageUrl: String?
    let badge: String?

    // Property-specific
    let description: String?
    let address: String
    let city: String
    let totalValue: Decimal
    let totalTokens: Int
    let tokenPrice: Decimal
    let soldTokens: Int
    let remainingTokens: Int?
    let annualYield: Decimal?
    let monthlyRent: Decimal?
    let contractAddress: String?
    let status: AssetStatus
    let images: [String]?
    let totalShareholders: Int
    let spvName: String?
    let spvTaxNumber: String?
    let latitude: Double?
    let longitude: Double?
    let createdAt: String
    let updatedAt: String
    let blockchainTokenId: Int?

    // MARK: - AssetRepresentable

    var assetType: AssetType { .property }
    var currentValue: Decimal { tokenPrice }

    var formattedPrice: String {
        CurrencyFormatter.format(tokenPrice, currency: .TRY)
    }

    // MARK: - Property Computed

    var fundingPercent: Double {
        guard totalTokens > 0 else { return 0 }
        return Double(soldTokens) / Double(totalTokens) * 100
    }

    var isSoldOut: Bool { (remainingTokens ?? (totalTokens - soldTokens)) <= 0 }
    var hasLocation: Bool { latitude != nil && longitude != nil }

    var formattedTotalValue: String {
        CurrencyFormatter.format(totalValue, currency: .TRY)
    }

    var formattedTokenPrice: String {
        CurrencyFormatter.format(tokenPrice, currency: .TRY)
    }

    var formattedMonthlyRent: String {
        CurrencyFormatter.format(monthlyRent ?? 0, currency: .TRY)
    }

    var formattedAnnualYield: String {
        guard let yield = annualYield else { return "-" }
        return CurrencyFormatter.formatPercent(NSDecimalNumber(decimal: yield).doubleValue)
    }

    // MARK: - CodingKeys

    enum CodingKeys: String, CodingKey {
        case id, title, category, description, address, city
        case status, images, latitude, longitude, badge

        case priceChangePercent = "price_change_percent"
        case imageUrl           = "image_url"
        case totalValue         = "total_value"
        case totalTokens        = "total_tokens"
        case tokenPrice         = "token_price"
        case soldTokens         = "sold_tokens"
        case remainingTokens    = "remaining_tokens"
        case annualYield        = "annual_yield"
        case monthlyRent        = "monthly_rent"
        case contractAddress    = "contract_address"
        case totalShareholders  = "total_shareholders"
        case spvName            = "spv_name"
        case spvTaxNumber       = "spv_tax_number"
        case createdAt          = "created_at"
        case updatedAt          = "updated_at"
        case blockchainTokenId = "blockchain_token_id"
    }

    // MARK: - toDisplayItem

    func toDisplayItem() -> AssetItem {
        AssetItem(
            id: id,
            assetType: .property,
            title: title,
            subtitle: "\(city) • \(category)",
            category: category,
            currentValue: tokenPrice,
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

extension Property {
    var trendingSubtitle: String {
        "\(city) • \(totalShareholders.formatted()) hissedar"
    }
    var listMeta: [String] {
        [city, category]
    }
}
