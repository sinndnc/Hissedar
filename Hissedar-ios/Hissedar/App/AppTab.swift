//
//  AppTab.swift
//  Hissedar
//
//  Created by Sinan Dinç on 3/24/26.
//

import SwiftUI

enum AppTab: String, CaseIterable {
    case discover = "Discover"
    case watchlist = "Watchlist"
    case search = "Search"
    case portfolio = "Portfolio"
    case profile = "Profile"
    
    var label: String{
        return String.localized("app_tab.type.\(self.rawValue)")
    }
    
    var icon: String {
        switch self {
        case .discover: return "safari"
        case .watchlist: return "bookmark"
        case .search: return "sparkle.magnifyingglass"
        case .portfolio: return "wallet.bifold"
        case .profile: return "person"
        }
    }
}
