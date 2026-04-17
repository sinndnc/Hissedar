//
//  WatchlistView.swift
//  Hissedar
//
//  Alarm kurma entegrasyonu eklendi.
//

import SwiftUI
import Factory

struct WatchlistView: View {
    
    @Injected(\.watchlistViewModel) private var vm
    @State var editMode: EditMode = .inactive
    
    // Alarm kurma sheet state'i
    @State private var alertSource: AssetItem?
    @Environment(ThemeManager.self) private var themeManager
    
    // MARK: - Body
    var body: some View {
        NavigationStack {
            ZStack {
                themeManager.theme.background.ignoresSafeArea()
                
                Group {
                    if vm.isLoading && vm.items.isEmpty {
                        loadingView
                    } else if vm.items.isEmpty {
                        emptyStateView
                    } else {
                        contentView
                    }
                }
            }
            .task { await vm.loadWatchlist() }
            .navigationTitle(String.localized("watchlist.nav_title"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(themeManager.theme.background, for: .navigationBar)
            .toolbar { toolbarItems }
            .alert(String.localized("common.error"), isPresented: showErrorBinding) {
                Button(String.localized("common.ok"), role: .cancel) { vm.error = nil }
            } message: {
                Text(vm.error ?? "")
            }
            .navigationDestination(for: String.self) { assetId in
                AssetDetailView(assetId: assetId)
            }
            .sheet(item: $alertSource) { item in
                CreatePriceAlertSheet(asset: item)
            }
        }
    }
    
    // MARK: - Content
    
    private var contentView: some View {
        ScrollView {
            @Bindable var vm = vm
            LazyVStack(spacing: 0, pinnedViews: [.sectionHeaders]) {
                SearchBar(searchText: $vm.searchText)
                    .padding()
                
                filteredBar
                
                if vm.filteredItems.isEmpty {
                    noResultsView
                } else {
                    ForEach(vm.filteredItems) { item in
                        watchlistRow(item: item)
                        
                        if vm.filteredItems.last?.id != item.id {
                            Divider()
                        }
                    }
                }
            }
        }
        .scrollIndicators(.hidden)
        .refreshable { await vm.loadWatchlist() }
    }
    
    // MARK: - Row
    
    private func watchlistRow(item: AssetItem) -> some View {
        NavigationLink(value: item.id) {
            WatchlistRow(item: item)
                .contextMenu {
                    Button {
                        alertSource = item
                    } label: {
                        Label(String.localized("watchlist.action.set_alert"), systemImage: "bell.badge")
                    }
                    
                    Button(role: .destructive) {
                        Task {
                            await vm.toggle(
                                itemId: item.id,
                                itemType: item.assetType.rawValue
                            )
                        }
                    } label: {
                        Label(String.localized("common.remove"), systemImage: "trash")
                    }
                }
        }
    }
    
    // MARK: - Filtered Bar
    private var filteredBar: some View {
        VStack {
            @Bindable var vm = vm
            SegmentedBar(
                items: AssetFilter.allCases,
                icon: \.icon,
                label: \.label,
                selected: $vm.selectedType
            )
            
            FilterBar(
                items: AssetSort.allCases,
                icon: \.icon,
                label: \.label,
                selected: $vm.selectedSort
            )
            .padding(.bottom)
            .padding(.horizontal)
        }
        .background(themeManager.theme.backgroundSecondary)
    }
    
    // MARK: - States
    
    private var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView()
                .tint(themeManager.theme.accent)
            Text(String.localized("common.loading"))
                .font(.system(size: 14))
                .foregroundColor(themeManager.theme.textSecondary)
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "star.slash")
                .font(.system(size: 48, weight: .light))
                .foregroundColor(themeManager.theme.accent.opacity(0.5))
            
            Text(String.localized("watchlist.empty.title"))
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(themeManager.theme.textPrimary)
            
            Text(String.localized("watchlist.empty.desc"))
                .font(.system(size: 14))
                .foregroundColor(themeManager.theme.textSecondary)
                .multilineTextAlignment(.center)
        }
        .padding(.top, 80)
    }
    
    private var noResultsView: some View {
        VStack(spacing: 12) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 32, weight: .light))
                .foregroundColor(themeManager.theme.textSecondary)
            
            Text(String(format: String.localized("common.search.no_results"), vm.searchText))
                .font(.system(size: 14))
                .foregroundColor(themeManager.theme.textSecondary)
        }
        .padding(.top, 60)
    }
    
    // MARK: - Toolbar
    
    @ToolbarContentBuilder
    private var toolbarItems: some ToolbarContent {
        ToolbarItem(placement: .topBarLeading) {
            Button {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                    editMode = editMode == .active ? .inactive : .active
                }
            } label: {
                Text(editMode == .active ? String.localized("common.done") : String.localized("common.edit"))
                    .foregroundStyle(themeManager.theme.textPrimary)
                    .font(.system(size: 15, weight: .semibold))
            }
        }
    }
    
    // MARK: - Helpers
    
    private var showErrorBinding: Binding<Bool> {
        Binding(
            get: { vm.error != nil },
            set: { if !$0 { vm.error = nil } }
        )
    }
}
