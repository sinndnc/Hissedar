//
//  AddAssetModels.swift
//  Hissedar
//
//  Created by Sinan Dinç on 4/15/26.
//

import Foundation

// MARK: - Wizard Step

enum AddAssetStep: Int, CaseIterable {
    case generalInfo = 0
    case assetType = 1
    case typeDetails = 2
    case preview = 3
    
    var title: String {
        return String.localized("wizard.step.\(self.rawValue).title")
    }
    
    var stepNumber: Int { rawValue + 1 }
    static var totalSteps: Int { allCases.count }
}

// MARK: - Asset Type Selection

enum AssetTypeOption: String, CaseIterable, Identifiable {
    case property
    case art
    case nft
    
    var id: String { rawValue }
    
    var title: String {
        return String.localized("asset.type.\(self.rawValue).title")
    }
    
    var subtitle: String {
        return String.localized("asset.type.\(self.rawValue).subtitle")
    }
    
    var icon: String {
        switch self {
        case .property: return "building.2.fill"
        case .art: return "paintpalette.fill"
        case .nft: return "cube.transparent.fill"
        }
    }
}

// MARK: - Property Category

enum PropertyCategory: String, CaseIterable, Identifiable {
    case konut, ticari, otel, arsa
    
    var id: String { rawValue }
    
    var title: String {
        return String.localized("property.category.\(self.rawValue)")
    }
    
    var icon: String {
        switch self {
        case .konut: return "house.fill"
        case .ticari: return "briefcase.fill"
        case .otel: return "bed.double.fill"
        case .arsa: return "map.fill"
        }
    }
}

// MARK: - Art Technique

enum ArtTechnique: String, CaseIterable, Identifiable {
    case yagliBoya = "yagli_boya"
    case akrilik, suluboya, heykel, karma
    case dijitalBaski = "dijital_baski"
    case seramik, diger
    
    var id: String { rawValue }
    
    var title: String {
        return String.localized("art.technique.\(self.rawValue)")
    }
}

// MARK: - NFT Blockchain

enum NFTBlockchain: String, CaseIterable, Identifiable {
    case polygon, ethereum, solana, avalanche
    
    var id: String { rawValue }
    
    var title: String {
        return rawValue.capitalized
    }
}

// MARK: - Add Asset Request Models (Supabase)

struct AddPropertyRequest: Encodable {
    let title: String
    let description: String
    let totalValue: Decimal
    let tokenPrice: Decimal
    let totalTokens: Int
    let annualYield: Double
    let monthlyRent: Decimal
    let city: String
    let address: String
    let category: String
    let imageUrl: String?
    let badge: String?
    let spvName: String?
    let spvTaxNumber: String?
    let latitude: Double?
    let longitude: Double?
    
    enum CodingKeys: String, CodingKey {
        case title, description, city, address, category, badge, latitude, longitude
        case totalValue = "total_value"
        case tokenPrice = "token_price"
        case totalTokens = "total_tokens"
        case annualYield = "annual_yield"
        case monthlyRent = "monthly_rent"
        case imageUrl = "image_url"
        case spvName = "spv_name"
        case spvTaxNumber = "spv_tax_number"
    }
}

struct AddArtRequest: Encodable {
    let title: String
    let description: String
    let currentValue: Decimal
    let totalTokens: Int
    let annualYield: Double
    let artistName: String
    let technique: String
    let dimensions: String
    let year: Int?
    let imageUrl: String?
    let badge: String?
    
    enum CodingKeys: String, CodingKey {
        case title, description, technique, dimensions, year, badge
        case currentValue = "current_value"
        case totalTokens = "total_tokens"
        case annualYield = "annual_yield"
        case artistName = "artist_name"
        case imageUrl = "image_url"
    }
}

struct AddNFTRequest: Encodable {
    let title: String
    let description: String
    let currentValue: Decimal
    let totalTokens: Int
    let collectionName: String
    let blockchain: String
    let contractAddress: String?
    let imageUrl: String?
    let badge: String?
    
    enum CodingKeys: String, CodingKey {
        case title, description, blockchain, badge
        case currentValue = "current_value"
        case totalTokens = "total_tokens"
        case collectionName = "collection_name"
        case contractAddress = "contract_address"
        case imageUrl = "image_url"
    }
}
