//
//  MainTabView.swift
//  Hissedar
//
//  Created by Sinan Dinç on 3/22/26.
//

import SwiftUI
import Factory

struct MainTabView: View {
    
    @Binding var selectedTab: AppTab
    
    var body: some View {
        VStack(spacing: 0) {
            TabContent(selectedTab: selectedTab)
                .frame(maxHeight: .infinity)
            CustomTabBar(selectedTab: $selectedTab)
        }
        .ignoresSafeArea()
    }
    
}

struct TabContent: View {
    var selectedTab: AppTab
    @State private var deepLinkPropertyId: String?
    
    var body: some View {
        Group {
            switch selectedTab {
            case .discover:
                DiscoverView()
            case .watchlist:
                WatchlistView()
            case .search:
                SearchView()
            case .portfolio:
                PortfolioView()
            case .profile:
                ProfileView()
            }
        }
    }
    
    // MARK: - Deep Link
    mutating func handleDeepLink(_ link: DeepLink) {
        switch link {
        case .profile: selectedTab = .profile
        case .assetDetail(let id,_):
            selectedTab = .profile
            deepLinkPropertyId = id
        case .portfolio: selectedTab = .portfolio
        case .watchlist: selectedTab = .watchlist
        case .market: selectedTab = .discover
        case .discover:
            selectedTab = .discover
        case .security:
            selectedTab = .discover
        }
    }
}

struct CustomTabBar: View {
    @Binding var selectedTab: AppTab
    
    var body: some View {
        VStack(spacing: 0) {
            Divider()
            HStack(spacing: 0) {
                ForEach(AppTab.allCases, id: \.self) { tab in
                    TabBarItem(
                        icon: tab.icon,
                        title: tab.label,
                        isSelected: selectedTab == tab
                    ) {
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
                            selectedTab = tab
                        }
                    }
                }
            }
            .padding(.top,10)
            .padding(.horizontal)
            .padding(.bottom,30)
        }
    }
}
 
struct TabBarItem: View {
    let icon: String
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    @Environment(ThemeManager.self) private var themeManager
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName:icon)
                    .fontWeight(.medium)
                    .font(.system(size: 20))
                Text(title)
                    .fontWeight(.semibold)
                    .font(.system(size: 10, weight: .medium))
            }
            .foregroundColor(
                isSelected
                ? themeManager.theme.accent :
                  themeManager.theme.textSecondary
                    .opacity(0.5)
            )
            .frame(maxWidth: .infinity)
        }
    }
}

#Preview {
    MainTabView(selectedTab: .constant(.discover))
        .environment(AppState())
}
