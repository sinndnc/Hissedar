//
//  PropertyMapCardView.swift
//  Hissedar
//

import SwiftUI

struct PropertyMapCardView: View {
    let item: AssetItem
    let onClose: () -> Void
    
    @State private var offset: CGFloat = UIScreen.main.bounds.height
    @State private var lastOffset: CGFloat = 0
    @State private var isFullyClosed: Bool = false
    
    private let screenHeight = UIScreen.main.bounds.height
    private let expandedOffset: CGFloat = 60
    private let collapsedOffset: CGFloat = UIScreen.main.bounds.height * 0.6
    private let dismissThreshold: CGFloat = UIScreen.main.bounds.height * 0.8
    @Environment(ThemeManager.self) private var themeManager
    
    var body: some View {
        ZStack(alignment: .top) {
            if !isFullyClosed {
                VStack(spacing: 0) {
                    // MARK: - Drag Handle
                    VStack {
                        Capsule()
                            .fill(themeManager.theme.textSecondary.opacity(0.3))
                            .frame(width: 36, height: 5)
                            .padding(.top, 12)
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 35)
                    .background(themeManager.theme.background)
                    .gesture(dragGesture)
                    
                    // MARK: - Content
                    ScrollView {
                        VStack(alignment: .leading, spacing: 20) {
                            headerSection
                            statsSection
                            fundingSection
                            
                            Text(String.localized("map.property.details_title"))
                                .font(.headline)
                                .foregroundStyle(themeManager.theme.textPrimary)
                            
                            Text(String.localized("map.property.details_placeholder"))
                                .font(.system(size: 14))
                                .foregroundStyle(themeManager.theme.textSecondary)
                                .lineSpacing(4)
                            
                            Spacer(minLength: 150)
                        }
                        .padding(20)
                    }
                    .scrollDisabled(offset > expandedOffset + 10)
                }
                .frame(height: screenHeight - expandedOffset)
                .background(themeManager.theme.background)
                .cornerRadius(24, corners: [.topLeft, .topRight])
                .shadow(color: .black.opacity(0.15), radius: 20, y: -5)
                .offset(y: offset)
                .gesture(dragGesture)
            }
        }
        .ignoresSafeArea(edges: .bottom)
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                offset = collapsedOffset
                lastOffset = collapsedOffset
            }
        }
    }
    
    // MARK: - Gesture Logic
    private var dragGesture: some Gesture {
        DragGesture(minimumDistance: 5)
            .onChanged { value in
                let newOffset = lastOffset + value.translation.height
                if newOffset < expandedOffset {
                    offset = expandedOffset + (value.translation.height / 3)
                } else {
                    offset = newOffset
                }
            }
            .onEnded { value in
                let velocity = value.predictedEndTranslation.height
                
                withAnimation(.spring(response: 0.4, dampingFraction: 0.82)) {
                    if velocity > 300 || offset > dismissThreshold {
                        offset = screenHeight
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                            isFullyClosed = true
                            onClose()
                        }
                    } else if offset < (collapsedOffset + expandedOffset) / 2 || velocity < -200 {
                        offset = expandedOffset
                    } else {
                        offset = collapsedOffset
                    }
                    lastOffset = offset
                }
            }
    }
    
    // MARK: - Subviews
    private var headerSection: some View {
        HStack(spacing: 16) {
            AsyncImage(url: URL(string: item.imageUrl ?? "")) { phase in
                if let image = phase.image {
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } else {
                    themeManager.theme.backgroundSecondary.overlay {
                        Image(systemName: item.icon)
                            .foregroundStyle(themeManager.theme.accent.opacity(0.5))
                    }
                }
            }
            .frame(width: 80, height: 80)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            
            VStack(alignment: .leading, spacing: 4) {
                Text(item.title)
                    .font(.headline)
                    .foregroundStyle(themeManager.theme.textPrimary)
                
                Label(item.propertyCity ?? "", systemImage: "mappin")
                    .font(.subheadline)
                    .foregroundStyle(themeManager.theme.textSecondary)
            }
        }
    }
    
    private var statsSection: some View {
        HStack(spacing: 30) {
            VStack(alignment: .leading, spacing: 4) {
                Text(String.localized("map.property.token_price"))
                    .font(.caption)
                    .foregroundStyle(themeManager.theme.textSecondary)
                Text(item.formattedPrice)
                    .font(.headline)
                    .foregroundStyle(themeManager.theme.textPrimary)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(String.localized("map.property.annual_yield"))
                    .font(.caption)
                    .foregroundStyle(themeManager.theme.textSecondary)
                Text(String(format: "%%%.1f", item.annualYieldPercent))
                    .font(.headline)
                    .foregroundStyle(themeManager.theme.accent)
            }
        }
    }

    private var fundingSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            ProgressView(value: min(item.fundingPercent / 100, 1.0))
                .tint(themeManager.theme.accent)
            
            Text(String(format: String.localized("map.property.funded_percent"), Int(item.fundingPercent)))
                .font(.caption)
                .foregroundStyle(themeManager.theme.textSecondary)
        }
    }
}
