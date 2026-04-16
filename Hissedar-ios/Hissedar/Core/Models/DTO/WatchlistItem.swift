//
//  WatchlistEntry.swift
//  Hissedar
//
//  Created by Sinan Dinç on 4/8/26.
//

import Foundation

struct WatchlistItem: Codable, Identifiable {
    let id: String
    let userId: String
    let assetId: String
    let assetType: AssetType
    let sortOrder: Int?
    let createdAt: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case userId    = "user_id"
        case assetId   = "asset_id"
        case assetType = "asset_type"
        case sortOrder = "sort_order"
        case createdAt = "created_at"
    }
}
