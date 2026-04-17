//
//  AssetType.swift
//  Hissedar
//

import Foundation

enum AssetType: String, Codable, CaseIterable, Identifiable {
    case property, art, nft
    
    var id: String { rawValue }
    
    var label: String {
        return switch self {
        case .property:
            String.localized("asset.type.property")
        case .art:
            String.localized("asset.type.art")
        case .nft:
            String.localized("asset.type.nft")
        }
    }
    
    var icon: String {
        switch self {
        case .property: return "building.2.fill"
        case .art:      return "paintpalette.fill"
        case .nft:      return "seal.fill"
        }
    }
    
    var queryValue: String? {
        switch self {
        case .property: return "property"
        case .nft:      return "nft"
        case .art:      return "art"
        }
    }
}
