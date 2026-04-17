//
//  PortfolioView.swift
//  Hissedar
//
//  Created by Sinan Dinç on 3/23/26.
//

import Charts
import Factory
import SwiftUI
import Foundation

enum PortfolioSort: String, CaseIterable {
    case value      = "value"
    case gain       = "gain"
    case returnRate = "return"
    case rent       = "rent"
    
    var label: String {
        return String.localized("portfolio.sort.\(self.rawValue)")
    }
    
    var icon: String {
        switch self {
        case .value:      return "banknote"
        case .gain:       return "chart.line.uptrend.xyaxis"
        case .returnRate: return "percent"
        case .rent:       return "house"
        }
    }
}

struct PortfolioView: View {
    
    @Injected(\.portfolioViewModel) private var vm
    
    @State private var showExchange = false
    @State private var isScrolled = false
    @State private var hideBalance = false
    @State private var hidingText = "*****.**"
    @State private var showAllTransactions = false
    
    @State private var selectedAsset: AssetFilter = .all
    @State private var selectedSort: AssetSort = .popular
    
    @Environment(ThemeManager.self) private var themeManager
    
    var body: some View {
        NavigationStack {
            ZStack {
                themeManager.theme.background.ignoresSafeArea()
                
                if vm.isLoading && vm.items.isEmpty {
                    loadingView
                } else if let err = vm.error {
                    errorView(err)
                } else {
                    contentView
                }
            }
            .task { await vm.load() }
            .toolbar { toolbarContent }
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(.visible, for: .navigationBar)
            .sheet(isPresented: $showExchange) {  ExchangeView() }
            .toolbarBackground(themeManager.theme.background, for: .navigationBar)
            .navigationDestination(for: String.self) { assetId in
                AssetDetailView(assetId: assetId)
            }
        }
    }
    
    // MARK: - Toolbar
    
    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .principal) {
            Text(String.localized("portfolio.nav_title"))
                .font(.system(size: 17, weight: .bold))
                .foregroundStyle(themeManager.theme.textPrimary)
        }
        
        ToolbarItem(placement: .topBarLeading) {
            if isScrolled, let summary = vm.summary {
                HStack(spacing: 4) {
                    Text(hideBalance ? hidingText : vm.netWorth.tlFormatted)
                        .font(.system(size: 15, weight: .bold))
                        .foregroundStyle(themeManager.theme.textPrimary)
                    
                    ChangeBadge(
                        change: summary.formattedReturnRate,
                        isPositive: summary.isPositive
                    )
                    .scaleEffect(0.75)
                }
                .fixedSize()
            }
        }
        .sharedBackgroundVisibility(.hidden)
        
        ToolbarItem(placement: .topBarTrailing) {
            Button {} label: {
                Image(systemName: "line.3.horizontal")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(themeManager.theme.textPrimary)
            }
        }
    }
    
    // MARK: - Content
    private var contentView: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                heroSection
                    .padding()
                portfolioInfoSection
                    .padding()
                
                filteredBar
                
                if vm.items.isEmpty {
                    emptyState
                } else {
                    holdingsSection
                    
                    holdingDistributionSection
                }
                
            }
        }
        .scrollIndicators(.hidden)
        .onScrollGeometryChange(
            for: Bool.self,
            of: { $0.contentOffset.y > 10 },
            action: { _, exceeded in
                withAnimation(.default) { isScrolled = exceeded }
            }
        )
        .refreshable { await vm.load() }
    }
    
    // MARK: - Hero
    private var heroSection: some View {
        HStack {
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 6) {
                    Text(String.localized("portfolio.hero.title"))
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(themeManager.theme.textSecondary)
                    Button {
                        withAnimation {
                            hideBalance.toggle()
                        }
                    } label: {
                        Image(systemName: hideBalance ? "eye.slash" : "eye")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(themeManager.theme.textPrimary)
                    }
                }
                
                Text(hideBalance ? hidingText : vm.netWorth.tlFormatted)
                    .foregroundStyle(themeManager.theme.textPrimary)
                    .font(.system(size: 28, weight: .bold, design: .monospaced))
                    .contentTransition(.numericText(value: Double(truncating: vm.totalValue as NSDecimalNumber)))
                
                HStack(spacing: 8) {
                    ChangeBadge(
                        change: hideBalance ? "**,**" : vm.totalGain.tlFormatted,
                        isPositive: vm.isGainPositive
                    )
                    
                    Text(vm.gainPercent.percentFormatted)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(vm.isGainPositive ? themeManager.theme.success : themeManager.theme.error)
                }
            }
            Spacer()
        }
    }
   
    // MARK: - Sort Bar
    
    private var portfolioInfoSection: some View {
        ZStack(alignment: .center) {
            Button { showExchange.toggle() } label: {
                Image(systemName: "arrow.up.arrow.down")
                    .padding(15)
                    .foregroundStyle(themeManager.theme.textPrimary)
                    .background(themeManager.theme.background)
                    .clipShape(Circle())
                    .font(.system(size: 13, weight: .semibold, design: .monospaced))
                    .overlay {
                        Circle().stroke(themeManager.theme.border.opacity(0.2), lineWidth: 1)
                    }
            }
            .zIndex(999)
            
            VStack(spacing: 5) {
                cashBalanceRow(
                    label: String.localized("portfolio.balance.cash"),
                    totalbalance: vm.cashBalance.tlFormatted,
                    availableBalance: vm.cashAvailableBalance.tlFormatted,
                    lockedBalance: vm.cashLockedBalance.tlFormatted
                )
                
                Divider()
                
                cashBalanceRow(
                    label: String.localized("portfolio.balance.token"),
                    totalbalance: vm.tokenBalance.tokenFormatted,
                    availableBalance: vm.tokenAvailableBalance.tokenFormatted,
                    lockedBalance: vm.tokenLockedBalance.tokenFormatted
                )
            }
        }
    }
    
    private var holdingDistributionSection: some View {
        VStack {
            HStack {
                Text(String.localized("portfolio.holdings.distribution"))
                    .foregroundStyle(themeManager.theme.textPrimary)
                    .font(.system(size: 16, weight: .semibold))
                Spacer()
                Text(String.localized("common.see_all"))
                    .foregroundStyle(themeManager.theme.textSecondary)
                    .font(.system(size: 12, weight: .medium))
            }
            SpiralArcView(items: vm.items)
                .frame(height: 300)
        }
        .padding()
    }
    
    private var filteredBar: some View {
        VStack {
            SegmentedBar(
                items: AssetFilter.allCases,
                icon: \.icon,
                label: \.label,
                selected: $selectedAsset
            )
            
            FilterBar(
                items: AssetSort.allCases,
                icon: \.icon,
                label: \.label,
                selected: $selectedSort
            )
            .padding()
        }
        .background(themeManager.theme.backgroundSecondary)
    }
    
    // MARK: - Holdings List
    private var holdingsSection: some View {
        VStack(spacing: 0) {
            ForEach(vm.sortedItems) { item in
                NavigationLink(value: item.id) {
                    holdingRow(item)
                }
                
                Divider()
                    .background(Color.white.opacity(0.06))
                    .padding(.leading, 82)
                    .opacity(item.id != vm.sortedItems.last?.id ? 1 : 0)
            }
        }
    }
    
    private func holdingRow(_ item: AssetItem) -> some View {
        HStack(spacing: 14) {
            // Property Image
            ZStack {
                if let url = item.imageUrl, let imageURL = URL(
                    string: url
                ) {
                    AsyncImage(url: imageURL) { phase in
                        switch phase {
                        case .success(let image):
                            image.resizable()
                                .scaledToFill()
                        default:
                            propertyPlaceholder
                        }
                    }
                } else {
                    propertyPlaceholder
                }
            }
            .frame(width: 56, height: 56)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            
            // Info
            VStack(alignment: .leading, spacing: 4) {
                Text(item.title)
                    .font(.system(size: 15, weight: .bold))
                    .foregroundStyle(themeManager.theme.textPrimary)
                    .lineLimit(1)
                
                HStack(spacing: 3) {
                    Text(item.category)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(themeManager.theme.textSecondary)
                    
                    Text("•")
                        .foregroundStyle(themeManager.theme.textTertiary)
                    
                    Text("\(item.tokenAmount ?? 1) token")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(themeManager.theme.textSecondary)
                }
            }
            
            Spacer()
            
            // Value & Change
            VStack(alignment: .trailing, spacing: 4) {
                Text(hideBalance ? hidingText : item.formattedTotalTokenPrice)
                    .foregroundStyle(themeManager.theme.textPrimary)
                    .font(.system(size: 15, weight: .bold, design: .monospaced))
                
                Text(hideBalance ? hidingText : item.formattedTotalCashPrice)
                    .foregroundStyle(themeManager.theme.textSecondary)
                    .font(.system(size: 12, weight: .bold, design: .monospaced))
                
                ChangeBadge(
                    change: vm.totalGain.tlFormatted,
                    isPositive: vm.isGainPositive
                )
            }
            
        }
        .padding(.vertical, 5)
        .padding(.horizontal, 15)
        .background(themeManager.theme.backgroundSecondary)
    }
    
    private func cashBalanceRow(
        label: String,
        totalbalance: String,
        availableBalance: String,
        lockedBalance: String
    ) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            HStack {
                Text(label)
                    .font(.system(size: 15, weight: .bold))
                    .foregroundStyle(themeManager.theme.textPrimary)
                Spacer()
                Text(hideBalance ? hidingText : totalbalance)
                    .foregroundStyle(themeManager.theme.textPrimary)
                    .font(.system(size: 15, weight: .bold, design: .monospaced))
            }
            
            HStack {
                Text(String.localized("portfolio.balance.available"))
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(themeManager.theme.textSecondary)
                Spacer()
                Text(hideBalance ? hidingText : availableBalance)
                    .foregroundStyle(themeManager.theme.textSecondary)
                    .font(.system(size: 12, weight: .bold, design: .monospaced))
            }
            
            HStack {
                Text(String.localized("portfolio.balance.locked"))
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(themeManager.theme.textTertiary)
                Spacer()
                Text(hideBalance ? hidingText : lockedBalance)
                    .foregroundStyle(themeManager.theme.textTertiary)
                    .font(.system(size: 12, weight: .bold, design: .monospaced))
            }
        }
    }
    
    // MARK: - States
    
    private var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView()
                .tint(themeManager.theme.accent)
            Text(String.localized("portfolio.loading"))
                .font(.system(size: 14))
                .foregroundStyle(themeManager.theme.textSecondary)
        }
    }
    
    private func errorView(_ message: String) -> some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 40, weight: .light))
                .foregroundStyle(themeManager.theme.error)
            
            Text(message)
                .font(.system(size: 14))
                .foregroundStyle(themeManager.theme.textSecondary)
                .multilineTextAlignment(.center)
            
            Button {
                Task { await vm.load() }
            } label: {
                Text(String.localized("common.retry"))
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 10)
                    .background(themeManager.theme.accent)
                    .clipShape(Capsule())
            }
        }
        .padding(40)
    }
    
    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "chart.pie")
                .font(.system(size: 48, weight: .light))
                .foregroundStyle(themeManager.theme.accent.opacity(0.5))
            
            Text(String.localized("portfolio.empty.title"))
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(themeManager.theme.textPrimary)
            
            Text(String.localized("portfolio.empty.desc"))
                .font(.system(size: 14))
                .foregroundStyle(themeManager.theme.textSecondary)
                .multilineTextAlignment(.center)
        }
        .padding(.top, 80)
    }
    
    // MARK: - Helpers
    
    private func sectionTitle(_ text: String, icon: String) -> some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(themeManager.theme.accent)
            Text(text)
                .font(.system(size: 17, weight: .bold))
                .foregroundStyle(themeManager.theme.textPrimary)
        }
    }
    
    private var propertyPlaceholder: some View {
        Rectangle()
            .fill(themeManager.theme.backgroundSecondary)
            .overlay {
                Image(systemName: "building.2.fill")
                    .font(.system(size: 20))
                    .foregroundStyle(themeManager.theme.accent.opacity(0.5))
            }
    }
}
