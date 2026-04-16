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
        switch self {
        case .value:      return "Değer"
        case .gain:       return "Kâr/Zarar"
        case .returnRate: return "Getiri"
        case .rent:       return "Kira"
        }
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
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.hsBackground.ignoresSafeArea()
                
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
            .toolbarBackground(Color.hsBackground, for: .navigationBar)
            .navigationDestination(for: String.self) { assetId in
                AssetDetailView(assetId: assetId)
            }
        }
    }
    
    // MARK: - Toolbar
    
    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .principal) {
            Text("Portföy")
                .font(.system(size: 17, weight: .bold))
                .foregroundStyle(Color.hsTextPrimary)
        }
        
        ToolbarItem(placement: .topBarLeading) {
            if isScrolled, let summary = vm.summary {
                HStack(spacing: 4) {
                    Text(summary.formattedNetWorth)
                        .font(.system(size: 15, weight: .bold))
                        .foregroundStyle(Color.hsTextPrimary)
                    
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
                    .foregroundStyle(Color.hsTextPrimary)
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
                }else{
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
                    Text("Portföy Değerim")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(Color.hsTextSecondary)
                    Button{
                        withAnimation{
                            hideBalance.toggle()
                        }
                    }label: {
                        Image(systemName: hideBalance ? "eye.slash" : "eye")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(Color.hsTextPrimary)
                    }
                }
                
                Text(hideBalance ? hidingText : vm.netWorth.tlFormatted)
                    .foregroundStyle(Color.hsTextPrimary)
                    .font(.system(size: 28, weight: .bold, design: .monospaced))
                    .contentTransition(.numericText(value: Double(truncating: vm.totalValue as NSDecimalNumber)))
                
                HStack(spacing: 8) {
                    ChangeBadge(
                        change: hideBalance ? "**,**" : vm.totalGain.tlFormatted,
                        isPositive: vm.isGainPositive
                    )
                    
                    Text(vm.gainPercent.percentFormatted)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(vm.isGainPositive ? Color.hsSuccess : Color.hsError)
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
                    .foregroundStyle(Color.hsTextPrimary)
                    .background(Color.hsBackground)
                    .clipShape(Circle())
                    .font(.system(size: 13,weight: .semibold,design: .monospaced))
                    .overlay {
                        Circle()
                            .stroke(.gray.opacity(0.2), lineWidth: 1)
                    }
            }
            .zIndex(999)
            
            VStack(spacing: 5){
                cashBalanceRow(
                    label: "Cash",
                    totalbalance: vm.cashBalance.tlFormatted,
                    availableBalance: vm.cashAvailableBalance.tlFormatted,
                    lockedBalance: vm.cashLockedBalance.tlFormatted
                )
                
                Divider()
                    .foregroundStyle(.gray)
                
                cashBalanceRow(
                    label: "Token",
                    totalbalance: vm.tokenBalance.tokenFormatted,
                    availableBalance: vm.tokenAvailableBalance.tokenFormatted,
                    lockedBalance: vm.tokenLockedBalance.tokenFormatted
                )
            }
        }
    }
    
    private var holdingDistributionSection: some View{
        VStack{
            HStack{
                Text("Holding distribution")
                    .foregroundStyle(Color.hsTextPrimary)
                    .font(.system(size: 16,weight: .semibold))
                Spacer()
                Text("See All")
                    .foregroundStyle(Color.hsTextSecondary)
                    .font(.system(size: 12,weight: .medium))
            }
            SpiralArcView(items: vm.items)
                .frame(height: 300)
        }
        .padding()
    }
    
    private var filteredBar: some View {
        VStack{
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
        .background(Color.hsBackgroundSecondary)
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
                    .foregroundStyle(Color.hsTextPrimary)
                    .lineLimit(1)
                
                HStack(spacing: 3) {
                    Text(item.category)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(Color.hsTextSecondary)
                    
                    Text("•")
                        .foregroundStyle(Color.hsTextTertiary)
                    
                    Text("\(item.tokenAmount ?? 1) token")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(Color.hsTextSecondary)
                }
            }
            
            Spacer()
            
            // Value & Change
            VStack(alignment: .trailing, spacing: 4) {
                Text(hideBalance ? hidingText : item.formattedTotalTokenPrice)
                    .foregroundStyle(Color.hsTextPrimary)
                    .font(.system(size: 15, weight: .bold, design: .monospaced))
                
                Text(hideBalance ? hidingText : item.formattedTotalCashPrice)
                    .foregroundStyle(Color.hsTextSecondary)
                    .font(.system(size: 12, weight: .bold, design: .monospaced))
                
                ChangeBadge(
                    change: vm.totalGain.tlFormatted,
                    isPositive: vm.isGainPositive
                )
            }
        }
        .padding(.vertical, 5)
        .padding(.horizontal, 15)
        .background(Color.hsBackgroundSecondary)
    }
    
    private func cashBalanceRow(
        label: String,
        totalbalance: String,
        availableBalance: String,
        lockedBalance: String
    ) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            HStack{
                Text(label)
                    .font(.system(size: 15, weight: .bold))
                    .foregroundStyle(Color.hsTextPrimary)
                Spacer()
                Text(hideBalance ? hidingText : totalbalance)
                    .foregroundStyle(Color.hsTextPrimary)
                    .font(.system(size: 15, weight: .bold, design: .monospaced))
            }
            
            HStack {
                Text("Available")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(Color.hsTextSecondary)
                Spacer()
                Text(hideBalance ? hidingText : availableBalance)
                    .foregroundStyle(Color.hsTextSecondary)
                    .font(.system(size: 12, weight: .bold, design: .monospaced))
            }
            
            HStack {
                Text("Locked")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(Color.hsTextTertiary)
                Spacer()
                Text(hideBalance ? hidingText : lockedBalance)
                    .foregroundStyle(Color.hsTextTertiary)
                    .font(.system(size: 12, weight: .bold, design: .monospaced))
            }
        }
    }
    
    // MARK: - States
    
    private var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView()
                .tint(Color.hsPurple400)
            Text("Portföy yükleniyor...")
                .font(.system(size: 14))
                .foregroundStyle(Color.hsTextSecondary)
        }
    }
    
    private func errorView(_ message: String) -> some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 40, weight: .light))
                .foregroundStyle(Color.hsError)
            
            Text(message)
                .font(.system(size: 14))
                .foregroundStyle(Color.hsTextSecondary)
                .multilineTextAlignment(.center)
            
            Button {
                Task { await vm.load() }
            } label: {
                Text("Tekrar Dene")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 10)
                    .background(Color.hsPurple600)
                    .clipShape(Capsule())
            }
        }
        .padding(40)
    }
    
    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "chart.pie")
                .font(.system(size: 48, weight: .light))
                .foregroundStyle(Color.hsPurple400.opacity(0.5))
            
            Text("Henüz Yatırımın Yok")
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(Color.hsTextPrimary)
            
            Text("Keşfet sekmesinden ilk token'ını\nsatın alarak portföyünü oluştur.")
                .font(.system(size: 14))
                .foregroundStyle(Color.hsTextSecondary)
                .multilineTextAlignment(.center)
        }
        .padding(.top, 80)
    }
    
    // MARK: - Helpers
    
    private func sectionTitle(_ text: String, icon: String) -> some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(Color.hsPurple400)
            Text(text)
                .font(.system(size: 17, weight: .bold))
                .foregroundStyle(Color.hsTextPrimary)
        }
    }
    
    private var propertyPlaceholder: some View {
        Rectangle()
            .fill(Color.hsBackgroundSecondary)
            .overlay {
                Image(systemName: "building.2.fill")
                    .font(.system(size: 20))
                    .foregroundStyle(Color.hsPurple400.opacity(0.5))
            }
    }
}
