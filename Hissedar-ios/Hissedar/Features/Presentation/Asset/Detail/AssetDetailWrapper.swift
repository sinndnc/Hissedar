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
    let loadAction: () async -> Void
    let toDisplayItem: (() -> AssetItem)?
    @ViewBuilder let content: () -> Content

    @Injected(\.watchlistViewModel) private var watchlistVM

    @State private var showBuySheet = false
    @State private var showSellSheet = false

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
        .background(Color.hsBackground)
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
                    onShare: { shareAsset() }
                )
            }
        }
    }

    // MARK: - Loading

    private var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView()
                .tint(Color.hsPurple400)
                .scaleEffect(1.3)
            Text("Yükleniyor...")
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(Color.hsTextSecondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // MARK: - Empty

    private var emptyView: some View {
        VStack(spacing: 12) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 36, weight: .light))
                .foregroundStyle(Color.hsTextSecondary.opacity(0.4))
            Text(emptyMessage)
                .font(.system(size: 15, weight: .medium))
                .foregroundStyle(Color.hsTextSecondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // MARK: - Bottom Bar
    private var bottomBar: some View {
        VStack(spacing: 0){
            Divider()
            HStack(spacing: 12) {
                // 1. Üç Nokta (More) Butonu
                Button {
                    // More actions
                } label: {
                    Image(systemName: "ellipsis")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(Color.hsTextPrimary)
                        .frame(width: 40, height: 40) // Kare form
                        .background(Color.hsBackgroundSecondary)
                        .clipShape(Circle()) // Tasarımdaki gibi tam yuvarlak
                        .overlay(
                            Circle()
                                .strokeBorder(Color.hsBorder, lineWidth: 0.5)
                        )
                }
                
                // 2. Sat (Sell) Butonu
                Button {
                    showSellSheet = true
                } label: {
                    Text("Sell")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(Color.hsTextPrimary)
                        .frame(maxWidth: .infinity) // Buy ile eşit dağılır
                        .frame(height: 40)
                        .background(Color.hsBackgroundSecondary)
                        .clipShape(Capsule()) // Daha oval bir görünüm
                        .overlay(
                            Capsule()
                                .strokeBorder(Color.hsBorder, lineWidth: 0.5)
                        )
                }
                
                // 3. Al (Buy) Butonu
                Button {
                    showBuySheet = true
                } label: {
                    Text("Buy")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 40)
                        .background(
                            LinearGradient(
                                colors: [Color.hsPurple700, Color.hsPurple600],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .clipShape(Capsule()) // Tasarımdaki modern oval yapı
                }
                .buttonStyle(PressableButtonStyle())
            }
            .padding(.vertical,10)
            .padding(.horizontal)
            .background(Color.hsBackground)
        }
    }
    
    
    private func shareAsset() {
        // Share sheet — implement with UIActivityViewController
    }
}

// MARK: - PressableButtonStyle

struct PressableButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .opacity(configuration.isPressed ? 0.9 : 1.0)
            .animation(.easeInOut(duration: 0.12), value: configuration.isPressed)
    }
}

// MARK: - AssetDetailToolbar (yeniden tasarım)

struct AssetDetailToolbar: View {
    let isInWatchlist: Bool
    let onToggleWatchlist: () -> Void
    let onShare: () -> Void

    var body: some View {
        HStack(spacing: 4) {
            toolbarButton(
                icon: isInWatchlist ? "heart.fill" : "heart",
                tint: isInWatchlist ? Color.hsError : Color.hsTextSecondary,
                action: onToggleWatchlist
            )
            toolbarButton(
                icon: "square.and.arrow.up",
                tint: Color.hsTextSecondary,
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
                .background(Color.hsBackgroundSecondary)
                .clipShape(Circle())
                .overlay(
                    Circle().strokeBorder(Color.hsBorder, lineWidth: 0.5)
                )
        }
        .buttonStyle(.plain)
        .animation(.spring(response: 0.3), value: isInWatchlist)
    }
}
