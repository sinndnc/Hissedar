//
//  AssetDetailWrapper.swift
//  Hissedar
//
//  Market-grade yeniden tasarım — animasyonlu, polished bottom bar
//

import SwiftUI
import Factory

struct AssetDetailWrapper<Content: View>: View {

    let itemId: String
    let itemType: String
    let isLoading: Bool
    let hasItem: Bool
    let emptyMessage: String
    let assetDetail: AssetDetail?
    let loadAction: () async -> Void
    let toDisplayItem: (() -> AssetItem)?
    @ViewBuilder let content: () -> Content

    @Injected(\.watchlistViewModel) private var watchlistVM

    @State private var showBuySheet = false
    @State private var showSellSheet = false
    @State private var showPriceAlertSheet = false
    @Environment(ThemeManager.self) private var themeManager
    
    var body: some View {
        Group {
            if hasItem {
                content()
                    .overlay(alignment: .bottom) { bottomBar }
            } else if isLoading {
                loadingView
            } else {
                emptyView
            }
        }
        .task { await loadAction() }
        .background(themeManager.theme.background)
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showBuySheet) {
            if let toDisplayItem {
                PurchaseView(asset: toDisplayItem())
            }
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                AssetDetailToolbar(
                    isInWatchlist: watchlistVM.isInWatchlist(itemId: itemId, itemType: itemType),
                    onToggleWatchlist: {
                        Task { await watchlistVM.toggle(itemId: itemId, itemType: itemType) }
                    },
                    onAddAlarm: { showPriceAlertSheet.toggle() },
                    onShare: { shareAsset() }
                )
            }
        }
        .sheet(isPresented: $showPriceAlertSheet) {
            if let detail = assetDetail {
                CreatePriceAlertSheet(asset: detail)
            }
        }
    }

    // MARK: - Loading View
    private var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView()
                .tint(themeManager.theme.accent)
                .scaleEffect(1.3)
            Text(String.localized("common.loading"))
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(themeManager.theme.textSecondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // MARK: - Empty View
    private var emptyView: some View {
        VStack(spacing: 12) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 36, weight: .light))
                .foregroundStyle(themeManager.theme.textSecondary.opacity(0.4))
            Text(emptyMessage)
                .font(.system(size: 15, weight: .medium))
                .foregroundStyle(themeManager.theme.textSecondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // MARK: - Bottom Bar
    private var bottomBar: some View {
        VStack(spacing: 0) {
            Divider().background(themeManager.theme.border)
            HStack(spacing: 12) {
                // 1. More Button
                Button {
                    // Ek aksiyonlar buraya gelebilir
                } label: {
                    Image(systemName: "ellipsis")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(themeManager.theme.textPrimary)
                        .frame(width: 40, height: 40)
                        .background(themeManager.theme.backgroundSecondary)
                        .clipShape(Circle())
                        .overlay(
                            Circle()
                                .strokeBorder(themeManager.theme.border, lineWidth: 0.5)
                        )
                }
                
                // 2. Sell Button
                Button {
                    showSellSheet = true
                } label: {
                    Text(String.localized("common.sell"))
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(themeManager.theme.textPrimary)
                        .frame(maxWidth: .infinity)
                        .frame(height: 40)
                        .background(themeManager.theme.backgroundSecondary)
                        .clipShape(Capsule())
                        .overlay(
                            Capsule()
                                .strokeBorder(themeManager.theme.border, lineWidth: 0.5)
                        )
                }
                
                // 3. Buy Button
                Button {
                    showBuySheet = true
                } label: {
                    Text(String.localized("common.buy"))
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 40)
                        .background(
                            LinearGradient(
                                colors: [
                                    themeManager.theme.purple700,
                                    themeManager.theme.purple400
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .clipShape(Capsule())
                }
                .buttonStyle(PressableButtonStyle())
            }
            .padding(.vertical, 10)
            .padding(.horizontal)
            .background(themeManager.theme.background)
        }
    }

    private func shareAsset() {
        // Paylaşım mantığı implementasyonu
    }
}

// MARK: - Subcomponents (Hatalar burada düzeltildi)

struct AssetDetailToolbar: View {
    let isInWatchlist: Bool
    let onToggleWatchlist: () -> Void
    let onAddAlarm: () -> Void
    let onShare: () -> Void
    
    @Environment(ThemeManager.self) private var themeManager
    
    var body: some View {
        HStack(spacing: 4) {
            toolbarButton(
                icon: isInWatchlist ? "heart.fill" : "heart",
                tint: isInWatchlist ? Color.hsError : themeManager.theme.textSecondary,
                action: onToggleWatchlist
            )
            toolbarButton(
                icon: "bell",
                tint: themeManager.theme.textSecondary,
                action: onAddAlarm
            )
            toolbarButton(
                icon: "square.and.arrow.up",
                tint: themeManager.theme.textSecondary,
                action: onShare
            )
        }
    }

    private func toolbarButton(icon: String, tint: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(tint)
                .frame(width: 36, height: 36)
                .background(themeManager.theme.backgroundSecondary)
                .clipShape(Circle())
                .overlay(
                    Circle().strokeBorder(themeManager.theme.border, lineWidth: 0.5)
                )
        }
        .buttonStyle(.plain)
        .animation(.spring(response: 0.3), value: isInWatchlist)
    }
}

struct PressableButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .opacity(configuration.isPressed ? 0.9 : 1.0)
            .animation(.easeInOut(duration: 0.12), value: configuration.isPressed)
    }
}
