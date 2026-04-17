//
//  AssetSort.swift
//  Hissedar
//

import Foundation

enum AssetSort: String, CaseIterable, Hashable {
    case popular   = "popular"
    case priceLow  = "price_low"
    case priceHigh = "price_high"
    case newest    = "newest"
    case yieldHigh = "yield_high"
    
    var label: String {
        return switch self {
        case .popular:
            String.localized("asset.sort.popular")
        case .priceLow:
            String.localized("asset.sort.price_low")
        case .priceHigh:
            String.localized("asset.sort.price_high")
        case .newest:
            String.localized("asset.sort.newest")
        case .yieldHigh:
            String.localized("asset.sort.yield_high")
        }
    }
    
    var icon: String {
        switch self {
        case .popular:   return "flame"
        case .priceLow:  return "arrow.down"
        case .priceHigh: return "arrow.up"
        case .newest:    return "clock"
        case .yieldHigh: return "percent"
        }
    }
}
