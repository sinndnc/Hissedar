//
//  PurchaseSheet.swift
//  Hissedar
//
//  Created by Sinan Dinç on 4/8/26.
//

import SwiftUI
import Factory
import Foundation

struct PurchaseView: View {
    
    @Injected(\.portfolioViewModel) private var portfolioVm
    @Environment(ThemeManager.self) private var themeManager
    @Environment(\.dismiss) private var dismiss
    
    @State var asset: AssetItem
    @State private var purchaseVm: PurchaseViewModel
    
    init(asset: AssetItem) {
        self.asset = asset
        self.purchaseVm = PurchaseViewModel(asset: asset)
    }
    
    var canAfford: Bool {
        portfolioVm.cashBalance >= purchaseVm.purchaseTotal
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Ana content
                mainContent
                
                // Success overlay
                if purchaseVm.purchaseSuccess {
                    PurchaseSuccessOverlay(
                        asset: asset,
                        purchaseAmount: purchaseVm.purchaseAmount,
                        formattedTotal: purchaseVm.formattedPurchaseTotal,
                        blockchainStatus: purchaseVm.blockchainStatus,
                        walletAddress: purchaseVm.walletAddress
                    )
                    .transition(.opacity)
                }
            }
            .animation(.easeInOut, value: purchaseVm.purchaseSuccess)
            .task { await portfolioVm.load() }
            .onChange(of: purchaseVm.purchaseSuccess) { _, success in
                if success {
                    Task {
                        try? await Task.sleep(for: .seconds(1.5))
                        await portfolioVm.load()
                        dismiss()
                    }
                }
            }
        }
    }
    
    private var mainContent: some View {
        ScrollView(showsIndicators: false){
            VStack(spacing: 20) {
                HStack(spacing: 14) {
                    ZStack {
                        if let url = asset.imageUrl, let imageURL = URL(string: url) {
                            AsyncImage(url: imageURL) { phase in
                                switch phase {
                                case .success(let img): img.resizable().scaledToFill()
                                default: assetPlaceholder(asset)
                                }
                            }
                        } else {
                            assetPlaceholder(asset)
                        }
                    }
                    .frame(width: 56, height: 56)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(asset.title)
                            .font(.system(size: 18, weight: .bold))
                            .foregroundStyle(themeManager.theme.textPrimary)
                        HStack(spacing: 6) {
                            Image(systemName: asset.icon)
                                .font(.system(size: 11))
                            Text(asset.typeLabel)
                            Text("•")
                            Text(asset.formattedHSRPrice + String.localized("purchase.per_token"))
                        }
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(themeManager.theme.textSecondary)
                    }
                    Spacer()
                }
                
                Divider().background(themeManager.theme.border)
                
                PriceChartView()
                
                // Amount stepper
                VStack(spacing: 12) {
                    Text(String.localized("purchase.question.how_many"))
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(themeManager.theme.textSecondary)
                    
                    HStack(spacing: 24) {
                        Button {
                            if purchaseVm.purchaseAmount > 1 { purchaseVm.purchaseAmount -= 1 }
                        } label: {
                            Image(systemName: "minus.circle.fill")
                                .font(.system(size: 36))
                                .foregroundStyle(themeManager.theme.accent)
                        }
                        
                        Text("\(purchaseVm.purchaseAmount)")
                            .font(.system(size: 42, weight: .bold, design: .monospaced))
                            .foregroundStyle(themeManager.theme.textPrimary)
                            .frame(minWidth: 70)
                        
                        Button {
                            if purchaseVm.purchaseAmount < asset.remainingTokens {
                                purchaseVm.purchaseAmount += 1
                            }
                        } label: {
                            Image(systemName: "plus.circle.fill")
                                .font(.system(size: 36))
                                .foregroundStyle(themeManager.theme.accent)
                        }
                    }
                    
                    // Quick amounts
                    HStack(spacing: 8) {
                        ForEach([1, 5, 10, 25], id: \.self) { amount in
                            Button {
                                purchaseVm.purchaseAmount = min(
                                    amount,
                                    asset.remainingTokens
                                )
                            } label: {
                                Text("\(amount)")
                                    .font(.system(size: 13, weight: .bold))
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 8)
                                    .foregroundStyle(
                                        purchaseVm.purchaseAmount == amount ?
                                        themeManager.theme.background : themeManager.theme.textSecondary
                                    )
                                    .background(
                                        purchaseVm.purchaseAmount == amount
                                        ? themeManager.theme.accent : themeManager.theme.backgroundTertiary
                                    )
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                            }
                        }
                    }
                    
                    Text(String(format: String.localized("purchase.remaining_tokens"), asset.remainingTokens))
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(themeManager.theme.textTertiary)
                }
                
                Divider().background(themeManager.theme.border)
                
                // Summary
                VStack(spacing: 10) {
                    summaryRow(String.localized("purchase.summary.token_price"), asset.formattedHSRPrice)
                    summaryRow(String.localized("purchase.summary.amount"), "\(purchaseVm.purchaseAmount) token")
                    Divider().background(themeManager.theme.border)
                    HStack {
                        Text(String.localized("purchase.summary.total"))
                            .font(.system(size: 16, weight: .bold))
                            .foregroundStyle(themeManager.theme.textPrimary)
                        Spacer()
                        Text(purchaseVm.purchaseTotal.tokenFormatted)
                            .font(.system(size: 22, weight: .bold, design: .monospaced))
                            .foregroundStyle(themeManager.theme.textPrimary)
                    }
                    
                    HStack {
                        Text(String.localized("purchase.summary.balance"))
                            .font(.system(size: 13, weight: .medium))
                            .foregroundStyle(themeManager.theme.textSecondary)
                        Spacer()
                        Text(portfolioVm.tokenBalance.tokenFormatted)
                            .font(.system(size: 13, weight: .bold))
                            .foregroundStyle(canAfford ?
                                             themeManager.theme.success :
                                                themeManager.theme.error
                            )
                    }
                }
                
                Spacer()
                
                // Purchase button
                Button { Task { await purchaseVm.purchase() } } label: {
                    HStack(spacing: 8) {
                        if purchaseVm.isLoading {
                            ProgressView()
                                .tint(themeManager.theme.textPrimary)
                        } else {
                            Image(systemName: "cart.fill")
                            Text("\(String.localized("purchase.button.buy")) — \(purchaseVm.purchaseTotal.tokenFormatted)")
                        }
                    }
                    .font(.system(size: 16, weight: .bold))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .foregroundStyle(.white)
                    .background(
                        canAfford
                        ? LinearGradient(
                            colors: [
                                themeManager.theme.purple600,
                                themeManager.theme.purple700
                            ],
                            startPoint: .topLeading,endPoint: .bottomTrailing
                        )
                        : LinearGradient(colors: [Color.gray, Color.gray],
                                         startPoint: .leading, endPoint: .trailing)
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .shadow(color: canAfford ? themeManager.theme.purple600.opacity(0.3) : .clear,
                            radius: 12, y: 4)
                }
                .disabled(!canAfford || purchaseVm.isLoading)
                
                if !canAfford {
                    Text(String.localized("purchase.error.insufficient_balance"))
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(themeManager.theme.error)
                }
            }
            .padding(20)
        }
    }
    
    private func assetPlaceholder(_ asset: AssetItem) -> some View {
        Rectangle()
            .fill(
                LinearGradient(
                    colors: [
                        themeManager.theme.purple900.opacity(0.3),
                        themeManager.theme.backgroundSecondary
                    ],
                    startPoint: .topLeading, endPoint: .bottomTrailing
                )
            )
            .overlay {
                Image(systemName: asset.icon)
                    .font(.system(size: 28))
                    .foregroundStyle(themeManager.theme.purple400.opacity(0.5))
            }
    }
    
    private func summaryRow(_ label: String, _ value: String) -> some View {
        HStack {
            Text(label)
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(themeManager.theme.textSecondary)
            Spacer()
            Text(value)
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(themeManager.theme.textPrimary)
        }
    }
}
