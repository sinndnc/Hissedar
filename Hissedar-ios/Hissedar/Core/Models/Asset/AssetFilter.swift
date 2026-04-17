//
//  AssetFilter.swift
//  Hissedar
//

import Foundation

enum AssetFilter: CaseIterable, Hashable, Identifiable {
    case all
    case type(AssetType)
    
    static var allCases: [AssetFilter] {
        [.all] + AssetType.allCases.map { .type($0) }
    }
    
    var id: String {
        switch self {
        case .all:            return "all"
        case .type(let t):    return t.id
        }
    }
    
    var label: String {
        switch self {
        case .all:
            return String.localized("asset.filter.all")
        case .type(let t):
            return t.label
        }
    }
    
    var icon: String {
        switch self {
        case .all:            return "square.grid.2x2.fill"
        case .type(let t):    return t.icon
        }
    }
    
    var assetType: AssetType? {
        guard case .type(let t) = self else { return nil }
        return t
    }
}
