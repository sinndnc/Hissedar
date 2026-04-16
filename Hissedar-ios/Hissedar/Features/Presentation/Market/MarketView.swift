//
//  MarketView.swift
//  Hissedar
//
//  Created by Sinan Dinç on 3/23/26.
//

import SwiftUI
import MapKit

protocol MarketLoadable: Observable {
    func load() async
    func refresh() async
}

private enum ViewType {
    case list, map
}

struct MarketView: View {
  
    @State private var vm = MarketViewModel()
    @State private var notificationManager = NotificationManager.shared
    @State private var selectedTab: ViewType = .list
    
    // Map state
    @State private var selectedMapItem: AssetItem?
    @State private var mapPosition: MapCameraPosition = .automatic
    
    private var trendingAssets: [AssetItem] {
        vm.filteredAssets
            .sorted { ($0.soldTokens ?? 0) > ($1.soldTokens ?? 0) }
            .prefix(5)
            .map { $0 }
    }
    
    /// Sadece koordinatı olan property'ler haritada gösterilir
    private var mappableAssets: [AssetItem] {
        vm.filteredAssets.filter { item in
            item.assetType == .property
            && item.propertyLatitude != nil
            && item.propertyLongitude != nil
        }
    }
    
    var body: some View {
        @Bindable var vm = vm
        NavigationStack {
            ZStack(alignment: .top) {
                Color.hsBackground.ignoresSafeArea()
                
                switch selectedTab {
                case .list:
                    listContent
                case .map:
                    mapContent
                }
            }
            .task{ await vm.load() }
            .scrollIndicators(.hidden)
            .refreshable{ await vm.refresh() }
            .navigationBarTitleDisplayMode(.inline)
            .toolbarVisibility(.visible, for: .navigationBar)
            .toolbarBackground(Color.hsBackground, for: .navigationBar)
            .toolbar { leadingToolBar; centerToolBar; trailingToolBar }
        }
    }
    
    // MARK: - Toolbar
    
    @ToolbarContentBuilder
    private var centerToolBar: some ToolbarContent {
        ToolbarItem(placement: .title) {
            Picker("", selection: $selectedTab) {
                Text("List")
                    .tag(ViewType.list)
                Text("Map")
                    .tag(ViewType.map)
            }
            .pickerStyle(.segmented)
            .frame(width: 200)
        }
    }
    
    @ToolbarContentBuilder
    private var trailingToolBar: some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            headerButton(icon: "line.3.horizontal.decrease")
        }
    }
    
    @ToolbarContentBuilder
    private var leadingToolBar: some ToolbarContent {
        ToolbarItem(placement: .topBarLeading) {
            NavigationLink { NotificationsView() } label: {
                headerButton(icon: "bell")
                    .overlay(alignment: .topLeading) {
                        if notificationManager.unreadCount > 0 {
                            Text("\(notificationManager.unreadCount)")
                                .padding(5)
                                .background(.red)
                                .clipShape(Circle())
                                .offset(x: -5, y: -5)
                                .foregroundStyle(Color.hsTextPrimary)
                                .font(.system(size: 10, weight: .medium))
                        }
                    }
            }
        }
    }
    
    // MARK: - List Content
    
    @ViewBuilder
    private var listContent: some View {
        ScrollView {
            LazyVStack(spacing: 0, pinnedViews: [.sectionHeaders]) {
                Section {
                    tabContent
                        .id(vm.selectedFilter)
                        .transition(.opacity.combined(with: .move(edge: .trailing)))
                        .animation(.easeInOut(duration: 0.25), value: vm.selectedFilter)
                } header: {
                    MarketSegmentedControl(selected: $vm.selectedFilter)
                        .padding()
                        .background(Color.hsBackground)
                }
            }
        }
    }
    
    // MARK: - Map Content
    
    @ViewBuilder
    private var mapContent: some View {
        ZStack(alignment: .bottom) {
            Map(position: $mapPosition, selection: $selectedMapItem) {
                ForEach(mappableAssets) { item in
                    if let lat = item.propertyLatitude,
                       let lng = item.propertyLongitude {
                        Annotation(item.title, coordinate: CLLocationCoordinate2D(latitude: lat, longitude: lng)) {
                            PropertyMapAnnotationView(
                                item: item,
                                isSelected: selectedMapItem?.id == item.id
                            )
                            .onTapGesture {
                                withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                                    selectedMapItem = (selectedMapItem?.id == item.id) ? nil : item
                                }
                            }
                        }
                        .tag(item)
                    }
                }
            }
            .mapStyle(.standard(pointsOfInterest: .excludingAll))
            .ignoresSafeArea(edges: .bottom)
            
            // Asset count badge
            VStack {
                HStack {
                    Spacer()
                    Text("\(mappableAssets.count) mülk")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(Color.hsTextPrimary)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(.ultraThinMaterial)
                        .clipShape(Capsule())
                        .padding(.trailing, 16)
                        .padding(.top, 8)
                }
                Spacer()
            }
            
            // Bottom card
            if let selected = selectedMapItem {
                PropertyMapCardView(item: selected) {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                        selectedMapItem = nil
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 8)
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .onChange(of: selectedMapItem) { _, newValue in
            guard let item = newValue,
                  let lat = item.propertyLatitude,
                  let lng = item.propertyLongitude else { return }
            
            withAnimation(.easeInOut(duration: 0.4)) {
                mapPosition = .region(
                    MKCoordinateRegion(
                        center: CLLocationCoordinate2D(latitude: lat, longitude: lng),
                        span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
                    )
                )
            }
        }
    }
    
    // MARK: - Tab Content
    
    @ViewBuilder
    private var tabContent: some View {
        let config = tabConfig(for: vm.selectedFilter)
        MarketTabView(
            trendingItems: trendingAssets,
            filteredItems: vm.filteredAssets,
            trendingTitle: config.trendingTitle,
            listTitle: config.listTitle,
            sort: Bindable(vm).selectedSort,
            subtitle: { $0.trendingSubtitle },
            meta: { $0.listMeta }
        ) { item in
            AnyView(detailView(for: item))
        }
    }
    
    // MARK: - Tab Config
    
    private struct TabConfig {
        let trendingTitle: String
        let listTitle: String
    }
    
    private func tabConfig(for filter: AssetFilter) -> TabConfig {
        switch filter {
        case .all:             TabConfig(trendingTitle: "Trendler",              listTitle: "Tüm Varlıklar")
        case .type(.property): TabConfig(trendingTitle: "Trend Mülkler",         listTitle: "Mülkler")
        case .type(.art):      TabConfig(trendingTitle: "Öne Çıkan Eserler",     listTitle: "Sanat Piyasası")
        case .type(.nft):      TabConfig(trendingTitle: "Popüler Koleksiyonlar", listTitle: "NFT Koleksiyonları")
        }
    }
    
    // MARK: - Detail Router
    
    @ViewBuilder
    private func detailView(for item: AssetItem) -> some View {
        AssetDetailView(assetId: item.id)
    }
    
    // MARK: - Header Button
    
    private func headerButton(icon: String) -> some View {
        Image(systemName: icon)
            .frame(width: 40, height: 40)
            .foregroundStyle(Color.hsTextPrimary)
            .font(.system(size: 16, weight: .medium))
    }
}
