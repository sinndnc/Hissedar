//
//  NFT.swift
//  Hissedar
//

import Foundation

struct NFT: AssetRepresentable {

    let id: String
    let title: String
    let category: String
    let currentValue: Decimal
    let priceChangePercent: Double
    let imageUrl: String?
    let badge: String?
    let status: AssetStatus
    let createdAt: String?
    let updatedAt: String?
    let blockchainTokenId: Int?
    
    // NFT-specific
    let collectionName: String
    let tokenId: Int
    let description: String?
    let totalTokens: Int
    let soldTokens: Int
    let remainingTokens: Int?
    let annualYield: Decimal?
    let blockchain: String
    let contractAddress: String?
    let metadataUrl: String?

    // MARK: - AssetRepresentable

    var assetType: AssetType { .nft }

    var formattedPrice: String {
        CurrencyFormatter.format(currentValue, currency: .ETH)
    }

    // MARK: - NFT Computed

    var fundingPercent: Double {
        guard totalTokens > 0 else { return 0 }
        return Double(soldTokens) / Double(totalTokens) * 100
    }

    var formattedAnnualYield: String {
        guard let yield = annualYield else { return "-" }
        return CurrencyFormatter.formatPercent(NSDecimalNumber(decimal: yield).doubleValue)
    }

    // MARK: - CodingKeys

    enum CodingKeys: String, CodingKey {
        case id, title, category, badge, status, description, blockchain
        case currentValue       = "current_value"
        case priceChangePercent = "price_change_percent"
        case imageUrl           = "image_url"
        case createdAt          = "created_at"
        case updatedAt          = "updated_at"
        case collectionName     = "collection_name"
        case tokenId            = "token_id"
        case totalTokens        = "total_tokens"
        case soldTokens         = "sold_tokens"
        case remainingTokens    = "remaining_tokens"
        case annualYield        = "annual_yield"
        case contractAddress    = "contract_address"
        case metadataUrl        = "metadata_url"
        case blockchainTokenId = "blockchain_token_id"
    }

    // MARK: - toDisplayItem

    func toDisplayItem() -> AssetItem {
        AssetItem(
            id: id,
            assetType: .nft,
            title: title,
            subtitle: collectionName,
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

extension NFT {
    var trendingSubtitle: String {
        "\(collectionName) • #\(tokenId)"
    }
    var listMeta: [String] {
        [collectionName, category]
    }
}
