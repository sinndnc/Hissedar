//
//  MarketTabView.swift
//  Hissedar
//
//  Created by Sinan Dinç on 4/8/26.
//

import SwiftUI

struct MarketTabView: View {
    
    let trendingItems: [AssetItem]
    let filteredItems: [AssetItem]
    let trendingTitle: String
    let listTitle: String
    let sort: Binding<AssetSort>
    let subtitle: (AssetItem) -> String
    let meta: (AssetItem) -> [String]
    let destination: (AssetItem) -> AnyView
    
    var body: some View {
        VStack(spacing: 5) {
            
            // MARK: Trending
            SectionHeaderView(trendingTitle, actionTitle: "Tümünü Gör →")
            
            GeometryReader { screen in
                let cardWidth = screen.size.width * 0.6
                let cardHeight = cardWidth * 3 / 4
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(trendingItems) { item in
                            NavigationLink {
                                destination(item)
                            } label: {
                                TrendingCard(
                                    accentColor: Color.hsBackgroundTertiary,
                                    badge: item.badge,
                                    title: item.title,
                                    subtitle: subtitle(item),
                                    sparklineData: item.sparklineData,
                                    isPositive: item.isPositive,
                                    price: item.formattedHSRPrice,
                                    change: item.formattedChange,
                                    imageUrl: item.imageUrl ?? ""
                                )
                                .padding(.vertical, 5)
                                .frame(width: cardWidth, height: cardHeight)
                            }
                        }
                    }
                    .padding(.horizontal)
                }
            }
            .frame(height: UIScreen.main.bounds.width * 0.6 * 3 / 4)
            
            // MARK: List
            SectionHeaderView(listTitle, actionTitle: "Sırala ↓")
            
            FilterBar(
                items: AssetSort.allCases,
                icon: \.icon,
                label: \.label,
                selected: sort
            )
            .padding(.horizontal)
            .padding(.vertical,10)
            
            LazyVStack(spacing: 0) {
                ForEach(Array(filteredItems.enumerated()), id: \.element.id) { index, item in
                    NavigationLink {
                        destination(item)
                    } label: {
                        MarketListRow(
                            rank: index + 1,
                            title: item.title,
                            meta: meta(item),
                            sparklineData: item.sparklineData,
                            isPositive: item.isPositive,
                            price: item.formattedHSRPrice,
                            change: item.formattedChange
                        ) {
                            defaultIcon(for: item)
                        }
                    }
                    if index < filteredItems.count - 1 {
                        Divider().padding(.leading, 74)
                    }
                }
            }
        }
    }
    
    @ViewBuilder
    private func defaultIcon(for item: AssetItem) -> some View {
        if let url = item.imageUrl, let parsed = URL(string: url) {
            AsyncImage(url: parsed).scaledToFit()
        } else {
            Text(item.title.prefix(1)).font(.title2)
        }
    }
}
