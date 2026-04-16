//
//  AssetSort.swift
//  Hissedar
//
//  Created by Sinan Dinç on 3/27/26.
//


import Foundation

enum AssetSort: String, CaseIterable, Hashable {
    case popular   = "popular"
    case priceLow  = "price_low"
    case priceHigh = "price_high"
    case newest    = "newest"
    case yieldHigh = "yield_high"

    var label: String {
        switch self {
        case .popular:   return "Popular"
        case .priceLow:  return "Price Low"
        case .priceHigh: return "Price High"
        case .newest:    return "Newest"
        case .yieldHigh: return "Yield High"
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
