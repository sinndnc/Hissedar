//
//  ActiveSearchView.swift
//  Hissedar
//
//  Fullscreen aktif arama ekranı.
//  SearchView'dan paylaşılan SearchViewModel'i kullanır.
//  Kendi data'sı yok — tüm state ViewModel'de.
//

import SwiftUI

struct ActiveSearchView: View {
    
    @Bindable var viewModel: SearchViewModel
    @FocusState private var isTextFieldFocused: Bool
    @Environment(\.dismiss) private var dismiss
    @Environment(ThemeManager.self) private var themeManager
    
    var body: some View {
        ZStack {
            themeManager.theme.background
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                searchBarHeader
                
                ScrollView(.vertical, showsIndicators: false) {
                    if viewModel.searchText.isEmpty {
                        idleContent
                    } else if viewModel.searchResults.isEmpty && !viewModel.isSearching {
                        emptyResultsView
                    } else {
                        suggestionsContent
                    }
                }
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                isTextFieldFocused = true
            }
        }
        .onDisappear {
            viewModel.searchText = ""
        }
        .navigationDestination(isPresented: Binding(
            get: { viewModel.selectedAsset != nil },
            set: { if !$0 { viewModel.selectedAsset = nil } }
        )) {
            if let asset = viewModel.selectedAsset {
                AssetDetailView(assetId: asset.id)
            }
        }
    }
    
    // MARK: - Search Bar Header
    
    private var searchBarHeader: some View {
        HStack(spacing: 12) {
            HStack(spacing: 10) {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(themeManager.theme.textTertiary)
                
                TextField(String.localized("search.placeholder"), text: $viewModel.searchText)
                    .font(.system(size: 15))
                    .foregroundColor(themeManager.theme.textPrimary)
                    .tint(themeManager.theme.accent)
                    .focused($isTextFieldFocused)
                    .submitLabel(.search)
                    .onSubmit {
                        viewModel.submitSearch()
                    }
                
                if !viewModel.searchText.isEmpty {
                    Button {
                        withAnimation(.easeInOut(duration: 0.15)) {
                            viewModel.searchText = ""
                        }
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 16))
                            .foregroundColor(themeManager.theme.textTertiary)
                    }
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .background(themeManager.theme.backgroundSecondary)
            .clipShape(RoundedRectangle(cornerRadius: 14))
            
            Button {
                dismiss()
            } label: {
                Text(String.localized("common.cancel"))
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(themeManager.theme.accent)
            }
        }
        .padding(.top, 12)
        .padding(.bottom, 16)
        .padding(.horizontal, 20)
        .background(themeManager.theme.background)
    }
    
    // MARK: - Idle Content
    
    private var idleContent: some View {
        VStack(spacing: 28) {
            if !viewModel.recentSearches.isEmpty {
                recentSearchesSection
            }
            popularSearchesSection
        }
        .padding(.top, 8)
        .padding(.bottom, 100)
    }
    
    // MARK: - Recent Searches
    
    private var recentSearchesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "clock.arrow.circlepath")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(themeManager.theme.accent)
                
                Text(String.localized("search.recent_title"))
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(themeManager.theme.textPrimary)
                
                Spacer()
                
                Button {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        viewModel.clearRecentSearches()
                    }
                } label: {
                    Text(String.localized("common.clear"))
                        .font(.system(size: 13))
                        .foregroundColor(themeManager.theme.accent)
                }
            }
            .padding(.horizontal)
            
            VStack(spacing: 0) {
                ForEach(Array(viewModel.recentSearches.enumerated()), id: \.offset) { index, search in
                    recentSearchRow(search, index: index)
                    
                    if index < viewModel.recentSearches.count - 1 {
                        Divider()
                            .background(themeManager.theme.border)
                            .padding(.leading, 48)
                    }
                }
            }
            .background(themeManager.theme.backgroundSecondary)
        }
    }
    
    private func recentSearchRow(_ text: String, index: Int) -> some View {
        Button {
            viewModel.searchText = text
            viewModel.addToRecentSearches(text)
        } label: {
            HStack(spacing: 12) {
                Button {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        viewModel.removeRecentSearch(at: index)
                    }
                } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(themeManager.theme.textTertiary)
                        .frame(width: 24, height: 24)
                }
                
                Text(text)
                    .font(.system(size: 14))
                    .foregroundColor(themeManager.theme.textPrimary)
                    .lineLimit(1)
                
                Spacer()
                
                Image(systemName: "arrow.up.left")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(themeManager.theme.textTertiary)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
        }
    }
    
    // MARK: - Popular Searches
    
    private var popularSearchesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: "arrow.up.right.circle.fill")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(themeManager.theme.accent)
                
                Text(String.localized("search.popular_title"))
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(themeManager.theme.textPrimary)
            }
            
            FlowLayout(spacing: 8) {
                ForEach(viewModel.popularSearches) { search in
                    Button {
                        viewModel.selectPopularSearch(search)
                    } label: {
                        Text(search.text)
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(search.color)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 8)
                            .background(search.color.opacity(0.12))
                            .clipShape(Capsule())
                    }
                }
            }
        }
        .padding(.horizontal)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    // MARK: - Suggestions Content
    
    private var suggestionsContent: some View {
        VStack(spacing: 0) {
            ForEach(Array(viewModel.searchResults.enumerated()), id: \.element.id) { index, result in
                resultRow(result)
                
                if index < viewModel.searchResults.count - 1 {
                    Divider()
                        .background(themeManager.theme.border)
                        .padding(.leading, 68)
                }
            }
        }
        .background(themeManager.theme.backgroundSecondary)
        .padding(.bottom, 100)
    }
    
    // MARK: - Result Row
    
    private func resultRow(_ result: SearchResultType) -> some View {
        Button {
            viewModel.selectResult(result)
        } label: {
            HStack(spacing: 12) {
                Image(systemName: result.icon)
                    .font(.system(size: 16))
                    .foregroundColor(result.iconColor)
                    .frame(width: 36, height: 36)
                    .background(result.iconColor.opacity(0.12))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                
                VStack(alignment: .leading, spacing: 2) {
                    highlightedText(result.displayTitle, query: viewModel.searchText)
                    
                    if let subtitle = result.displaySubtitle {
                        Text(subtitle)
                            .font(.system(size: 12))
                            .foregroundColor(themeManager.theme.textTertiary)
                            .lineLimit(1)
                    }
                }
                
                Spacer()
                
                if let price = result.priceText {
                    VStack(alignment: .trailing, spacing: 2) {
                        Text(price)
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(themeManager.theme.textPrimary)
                        
                        if let change = result.changeText {
                            Text(change)
                                .font(.system(size: 11, weight: .medium))
                                .foregroundColor(result.isPositive ? themeManager.theme.success : themeManager.theme.error)
                        }
                    }
                } else if let badge = result.badge {
                    Text(badge)
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(result.iconColor)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(result.iconColor.opacity(0.12))
                        .clipShape(Capsule())
                } else {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(themeManager.theme.textTertiary)
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
        }
    }
    
    // MARK: - Highlighted Text
    
    private func highlightedText(_ text: String, query: String) -> some View {
        let lowText = text.lowercased()
        let lowQuery = query.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        
        if let range = lowText.range(of: lowQuery) {
            let startIdx = text.distance(from: text.startIndex, to: range.lowerBound)
            let length = text.distance(from: range.lowerBound, to: range.upperBound)
            
            let before = String(text.prefix(startIdx))
            let match = String(text.dropFirst(startIdx).prefix(length))
            let after = String(text.dropFirst(startIdx + length))
            
            return Text(before)
                .font(.system(size: 14))
                .foregroundColor(themeManager.theme.textPrimary)
            + Text(match)
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(themeManager.theme.accent)
            + Text(after)
                .font(.system(size: 14))
                .foregroundColor(themeManager.theme.textPrimary)
        } else {
            return Text(text)
                .font(.system(size: 14))
                .foregroundColor(themeManager.theme.textPrimary)
            + Text("")
                .foregroundColor(.clear)
            + Text("")
                .foregroundColor(.clear)
        }
    }
    
    // MARK: - Empty Results
    
    private var emptyResultsView: some View {
        VStack(spacing: 16) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 44))
                .foregroundColor(themeManager.theme.textTertiary)
            
            Text(String.localized("search.no_results.title"))
                .font(.system(size: 17, weight: .semibold))
                .foregroundColor(themeManager.theme.textPrimary)
            
            Text(String(format: String.localized("search.no_results.subtitle"), viewModel.searchText))
                .font(.system(size: 14))
                .foregroundColor(themeManager.theme.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 80)
    }
}

// MARK: - FlowLayout

struct FlowLayout: Layout {
    var spacing: CGFloat = 8
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        arrange(proposal: proposal, subviews: subviews).size
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = arrange(proposal: proposal, subviews: subviews)
        for (i, pos) in result.positions.enumerated() {
            subviews[i].place(at: CGPoint(x: bounds.minX + pos.x, y: bounds.minY + pos.y), proposal: .unspecified)
        }
    }
    
    private func arrange(proposal: ProposedViewSize, subviews: Subviews) -> (positions: [CGPoint], size: CGSize) {
        let maxW = proposal.width ?? .infinity
        var positions: [CGPoint] = []
        var x: CGFloat = 0, y: CGFloat = 0, lineH: CGFloat = 0, maxX: CGFloat = 0
        
        for sub in subviews {
            let s = sub.sizeThatFits(.unspecified)
            if x + s.width > maxW, x > 0 { x = 0; y += lineH + spacing; lineH = 0 }
            positions.append(CGPoint(x: x, y: y))
            lineH = max(lineH, s.height)
            x += s.width + spacing
            maxX = max(maxX, x - spacing)
        }
        return (positions, CGSize(width: maxX, height: y + lineH))
    }
}
