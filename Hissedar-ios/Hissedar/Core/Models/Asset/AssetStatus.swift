//
//  AssetStatus.swift
//  Hissedar
//
//  Created by Sinan Dinç on 4/8/26.
//

import Foundation

enum AssetStatus: String, Codable {
    case draft // Properties default
    case active
    case funded // sold_tokens >= total_tokens olunca
    case upcoming
    case soldOut = "sold_out"
    case paused
}
