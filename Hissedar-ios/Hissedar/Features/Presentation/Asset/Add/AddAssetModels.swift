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
        switch self {
        case .generalInfo: return "Genel Bilgiler"
        case .assetType: return "Varlık Türü"
        case .typeDetails: return "Detay Bilgiler"
        case .preview: return "Önizleme"
        }
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
        switch self {
        case .property: return "Gayrimenkul"
        case .art: return "Sanat Eseri"
        case .nft: return "NFT"
        }
    }
    
    var subtitle: String {
        switch self {
        case .property: return "Konut, ticari, otel ve arsa yatırımları"
        case .art: return "Tablo, heykel ve değerli sanat eserleri"
        case .nft: return "Dijital varlıklar ve koleksiyonlar"
        }
    }
    
    var icon: String {
        switch self {
        case .property: return "building.2.fill"
        case .art: return "paintpalette.fill"
        case .nft: return "cube.transparent.fill"
        }
    }
    
    var color: String {
        switch self {
        case .property: return "blue"
        case .art: return "purple"
        case .nft: return "orange"
        }
    }
}

// MARK: - Property Category

enum PropertyCategory: String, CaseIterable, Identifiable {
    case konut
    case ticari
    case otel
    case arsa
    
    var id: String { rawValue }
    
    var title: String {
        switch self {
        case .konut: return "Konut"
        case .ticari: return "Ticari"
        case .otel: return "Otel"
        case .arsa: return "Arsa"
        }
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
    case yagliBoya = "yağlı boya"
    case akrilik
    case suluboya = "suluboya"
    case heykel
    case karma
    case dijitalBaski = "dijital baskı"
    case seramik
    case diger = "diğer"
    
    var id: String { rawValue }
    
    var title: String {
        switch self {
        case .yagliBoya: return "Yağlı Boya"
        case .akrilik: return "Akrilik"
        case .suluboya: return "Suluboya"
        case .heykel: return "Heykel"
        case .karma: return "Karma"
        case .dijitalBaski: return "Dijital Baskı"
        case .seramik: return "Seramik"
        case .diger: return "Diğer"
        }
    }
}

// MARK: - NFT Blockchain

enum NFTBlockchain: String, CaseIterable, Identifiable {
    case polygon
    case ethereum
    case solana
    case avalanche
    
    var id: String { rawValue }
    
    var title: String {
        switch self {
        case .polygon: return "Polygon"
        case .ethereum: return "Ethereum"
        case .solana: return "Solana"
        case .avalanche: return "Avalanche"
        }
    }
}

// MARK: - City List (Turkey)

struct TurkishCities {
    static let all: [String] = [
        "İstanbul", "Ankara", "İzmir", "Bursa", "Antalya",
        "Adana", "Konya", "Gaziantep", "Mersin", "Kayseri",
        "Eskişehir", "Trabzon", "Samsun", "Denizli", "Muğla",
        "Sakarya", "Tekirdağ", "Manisa", "Diyarbakır", "Hatay",
        "Balıkesir", "Kocaeli", "Aydın", "Malatya", "Erzurum",
        "Elazığ", "Van", "Mardin", "Şanlıurfa", "Kahramanmaraş"
    ]
}

// MARK: - Add Asset Request (for Supabase)

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
