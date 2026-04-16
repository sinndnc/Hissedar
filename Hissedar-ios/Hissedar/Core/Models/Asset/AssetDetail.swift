//
//  TradeableAssetDetail.swift
//  Hissedar
//
//  Created by Sinan Dinç on 4/9/26.
//

import Foundation

struct AssetDetail: Codable, Identifiable {

    // ── Core ───────────────────────────────────────────
    let id: String
    let assetType: AssetType
    let title: String
    let subtitle: String?
    let category: String
    let currentValue: Decimal
    let totalTokens: Int?
    let soldTokens: Int?
    let remainingTokens: Int?
    let totalValue: Decimal?
    let annualYield: Double?
    let priceChangePercent: Double
    let imageUrl: String?
    let badge: String?
    let status: AssetStatus?
    let createdAt: String?
    let blockchainTokenId: Int?
    let contractAddress: String?  // property'den geliyor

    // ── Property ───────────────────────────────────────
    let propertyAddress: String?
    let propertyCity: String?
    let propertyTokenPrice: Decimal?
    let propertyMonthlyRent: Decimal?
    let propertyLatitude: Double?
    let propertyLongitude: Double?
    let propertySpvName: String?
    let propertySpvTaxNumber: String?
    let propertyDescription: String?

    // ── Art ────────────────────────────────────────────
    let artArtistName: String?
    let artProvenance: String?
    let artYearCreated: Int?
    let artMedium: String?
    let artDimensions: String?

    // ── NFT ────────────────────────────────────────────
    let nftCollectionName: String?
    let nftTokenId: Int?
    let nftBlockchain: String?
    let nftContractAddress: String?
    let nftMetadataUrl: String?

    enum CodingKeys: String, CodingKey {
        case id, title, subtitle, category, badge, status
        case blockchainTokenId = "blockchain_token_id"
        case contractAddress = "contract_address"
        case assetType          = "asset_type"
        case currentValue       = "current_value"
        case totalTokens        = "total_tokens"
        case soldTokens         = "sold_tokens"
        case remainingTokens    = "remaining_tokens"
        case totalValue         = "total_value"
        case annualYield        = "annual_yield"
        case priceChangePercent = "price_change_percent"
        case imageUrl           = "image_url"
        case createdAt          = "created_at"
        case propertyAddress    = "property_address"
        case propertyCity       = "property_city"
        case propertyTokenPrice = "property_token_price"
        case propertyMonthlyRent    = "property_monthly_rent"
        case propertyLatitude       = "property_latitude"
        case propertyLongitude      = "property_longitude"
        case propertySpvName        = "property_spv_name"
        case propertySpvTaxNumber   = "property_spv_tax_number"
        case propertyDescription    = "property_description"
        case artArtistName      = "art_artist_name"
        case artProvenance      = "art_provenance"
        case artYearCreated     = "art_year_created"
        case artMedium          = "art_medium"
        case artDimensions      = "art_dimensions"
        case nftCollectionName  = "nft_collection_name"
        case nftTokenId         = "nft_token_id"
        case nftBlockchain      = "nft_blockchain"
        case nftContractAddress = "nft_contract_address"
        case nftMetadataUrl     = "nft_metadata_url"
    }
}

// MARK: - Computed

extension AssetDetail {

    var isPositive: Bool { priceChangePercent >= 0 }

    var fundingPercent: Double {
        guard let total = totalTokens, let sold = soldTokens, total > 0 else { return 0 }
        return Double(sold) / Double(total) * 100
    }

    var isSoldOut: Bool { (remainingTokens ?? 0) <= 0 }

    var toDisplayItem: AssetItem {
        AssetItem(
            id: id,
            assetType: assetType,
            title: title,
            subtitle: subtitle,
            category: category,
            currentValue: currentValue,
            priceChangePercent: priceChangePercent,
            imageUrl: imageUrl,
            badge: badge,
            status: status,
            annualYield: annualYield.map { Decimal($0) },
            totalTokens: totalTokens,
            soldTokens: soldTokens,
            createdAt: createdAt
        )
    }
}
