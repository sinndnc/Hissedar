//
//  DiscoverTabView.swift
//  Hissedar
//
//  Created by Sinan Dinç on 4/8/26.
//

import SwiftUI

struct DiscoverTabView: View {
    
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
            SectionHeaderView(trendingTitle, actionTitle: String.localized("common.see_all_arrow"))
            
            GeometryReader { screen in
                let cardWidth = screen.size.width * 0.6
                let cardHeight = cardWidth * 3 / 4
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(trendingItems) { item in
                            NavigationLink {
                                destination(item)
                            } label: {
                                TrendingCard(item: item)
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
            SectionHeaderView(listTitle, actionTitle: String.localized("common.sort_arrow"))
            
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
                        DiscoverListRow(
                            rank: index + 1,
                            item: item
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
            AsyncImage(url: parsed) { phase in
                switch phase {
                case .success(let image):
                    image.resizable().scaledToFill()
                default:
                    placeholderIcon(for: item)
                }
            }
        } else {
            placeholderIcon(for: item)
        }
    }

    private func placeholderIcon(for item: AssetItem) -> some View {
        Text(item.title.prefix(1)).font(.title2)
    }
}
