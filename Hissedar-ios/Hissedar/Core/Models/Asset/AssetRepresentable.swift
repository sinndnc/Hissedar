//
//  AssetRepresentable.swift
//  Hissedar
//
//  Created by Sinan Dinç on 4/8/26.
//

import Foundation

protocol AssetRepresentable: Identifiable, Codable {
    var id: String { get }
    var title: String { get }
    var assetType: AssetType { get }
    var category: String { get }
    var currentValue: Decimal { get }
    var priceChangePercent: Double { get }
    var imageUrl: String? { get }
    var badge: String? { get }
    var formattedPrice: String { get }
    
    func toDisplayItem() -> AssetItem
}

extension AssetRepresentable {
    var isPositive: Bool { priceChangePercent >= 0 }
    var sparklineData: [Double] { [] }
    var formattedChange: String {
        let sign = isPositive ? "+" : ""
        return "\(sign)\(String(format: "%.1f", priceChangePercent))%"
    }
}
