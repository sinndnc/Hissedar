//
//  AssetType.swift
//  Hissedar
//
//  Created by Sinan Dinç on 4/8/26.
//

import Foundation

enum AssetType: String, Codable, CaseIterable, Identifiable {
    case property, art, nft
    
    var id: String { rawValue }
    
    var label: String {
        switch self {
        case .property: "Property"
        case .art:      "Art"
        case .nft:      "NFT"
        }
    }
    
    var icon: String {
        switch self {
        case .property: "building.2.fill"
        case .art:      "paintpalette.fill"
        case .nft:      "seal.fill"
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
