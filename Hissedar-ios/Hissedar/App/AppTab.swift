//
//  AppTab.swift
//  Hissedar
//
//  Created by Sinan Dinç on 3/24/26.
//

import SwiftUI

enum AppTab: String, CaseIterable {
    case discover = "discover"
    case watchlist = "watchlist"
    case search = "search"
    case portfolio = "portfolio"
    case profile = "profile"
    
    var label: String {
        String.localized("app_tab.type.\(rawValue)")
    }
    
    var icon: String {
        switch self {
        case .discover:  return "safari"
        case .watchlist: return "bookmark"
        case .search:    return "sparkle.magnifyingglass"
        case .portfolio: return "wallet.bifold"
        case .profile:   return "person"
        }
    }
}
