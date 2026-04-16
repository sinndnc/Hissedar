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

    // MARK: - Body
    var body: some View {
        NavigationStack {
            ZStack {
                Color.hsBackground.ignoresSafeArea()

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
            .navigationTitle("Takip Listesi")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbarBackground(Color.hsBackground, for: .navigationBar)
            .toolbar { toolbarItems }
            .alert("Hata", isPresented: showErrorBinding) {
                Button("Tamam", role: .cancel) { vm.error = nil }
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
                        Label("Alarm kur", systemImage: "bell.badge")
                    }
                    
                    Button(role: .destructive) {
                        Task {
                            await vm.toggle(
                                itemId: item.id,
                                itemType: item.assetType.rawValue
                            )
                        }
                    } label: {
                        Label("Kaldır", systemImage: "trash")
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
        .background(Color.hsBackgroundSecondary)
    }

    // MARK: - States

    private var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView()
                .tint(Color.hsPurple400)
            Text("Yükleniyor...")
                .font(.system(size: 14))
                .foregroundColor(.hsTextSecondary)
        }
    }

    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "star.slash")
                .font(.system(size: 48, weight: .light))
                .foregroundColor(Color.hsPurple400.opacity(0.5))

            Text("Takip Listen Boş")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.hsTextPrimary)

            Text("Varlıkları takip listene ekleyerek\nfiyat değişimlerini kolayca izle.")
                .font(.system(size: 14))
                .foregroundColor(.hsTextSecondary)
                .multilineTextAlignment(.center)
        }
        .padding(.top, 80)
    }

    private var noResultsView: some View {
        VStack(spacing: 12) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 32, weight: .light))
                .foregroundColor(.hsTextSecondary)

            Text("\(vm.searchText) için sonuç bulunamadı")
                .font(.system(size: 14))
                .foregroundColor(.hsTextSecondary)
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
                Text(editMode == .active ? "Done" : "Edit")
                    .foregroundStyle(Color.hsTextPrimary)
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
