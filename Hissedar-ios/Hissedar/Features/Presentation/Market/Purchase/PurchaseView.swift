//
//  PurchaseSheet.swift
//  Hissedar
//
//  Created by Sinan Dinç on 4/8/26.
//

import SwiftUI
import Factory
import Foundation

struct PurchaseView: View{
    
    @Injected(\.portfolioViewModel) private var portfolioVm
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
            .safeAreaPadding()
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
                        .foregroundStyle(Color.hsTextPrimary)
                    HStack(spacing: 6) {
                        Image(systemName: asset.icon)
                            .font(.system(size: 11))
                        Text(asset.typeLabel)
                        Text("•")
                        Text(asset.formattedHSRPrice + " / token")
                    }
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(Color.hsTextSecondary)
                }
                Spacer()
            }
            
            Divider().background(Color.hsBorder)
            
            PriceChartView()
            
            // Amount stepper
            VStack(spacing: 12) {
                Text("Kaç Token?")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(Color.hsTextSecondary)
                
                HStack(spacing: 24) {
                    Button {
                        if purchaseVm.purchaseAmount > 1 { purchaseVm.purchaseAmount -= 1 }
                    } label: {
                        Image(systemName: "minus.circle.fill")
                            .font(.system(size: 36))
                            .foregroundStyle(Color.hsPurple400)
                    }
                    
                    Text("\(purchaseVm.purchaseAmount)")
                        .font(.system(size: 42, weight: .bold, design: .monospaced))
                        .foregroundStyle(Color.hsTextPrimary)
                        .frame(minWidth: 70)
                    
                    Button {
                        if purchaseVm.purchaseAmount < asset.remainingTokens {
                            purchaseVm.purchaseAmount += 1
                        }
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 36))
                            .foregroundStyle(Color.hsPurple400)
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
                                    purchaseVm.purchaseAmount == amount
                                    ? .white : Color.hsTextSecondary
                                )
                                .background(
                                    purchaseVm.purchaseAmount == amount
                                    ? Color.hsPurple600 : Color.hsBackgroundSecondary
                                )
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                        }
                    }
                }
                
                Text("\(asset.remainingTokens) token kaldı")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(Color.hsTextTertiary)
            }
            
            Divider().background(Color.hsBorder)
            
            // Summary
            VStack(spacing: 10) {
                summaryRow("Token Fiyatı", asset.formattedHSRPrice)
                summaryRow("Miktar", "\(purchaseVm.purchaseAmount) token")
                Divider().background(Color.hsBorder)
                HStack {
                    Text("Toplam")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(Color.hsTextPrimary)
                    Spacer()
                    Text(purchaseVm.purchaseTotal.tokenFormatted)
                        .font(.system(size: 22, weight: .bold, design: .monospaced))
                        .foregroundStyle(Color.hsTextPrimary)
                }
                
                HStack {
                    Text("Bakiye")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(Color.hsTextSecondary)
                    Spacer()
                    Text(portfolioVm.tokenBalance.tokenFormatted)
                        .font(.system(size: 13, weight: .bold))
                        .foregroundStyle(canAfford ? Color.hsSuccess : Color.hsError)
                }
            }
            
            Spacer()
            
            // Purchase button
            Button { Task { await purchaseVm.purchase() } } label: {
                HStack(spacing: 8) {
                    if purchaseVm.isLoading {
                        ProgressView().tint(.white)
                    } else {
                        Image(systemName: "cart.fill")
                        Text("Satın Al — \(purchaseVm.purchaseTotal.tokenFormatted)")
                    }
                }
                .font(.system(size: 16, weight: .bold))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .foregroundStyle(.white)
                .background(
                    canAfford
                    ? LinearGradient(colors: [Color.hsPurple600, Color.hsPurple700],
                                     startPoint: .topLeading, endPoint: .bottomTrailing)
                    : LinearGradient(colors: [Color.gray, Color.gray],
                                     startPoint: .leading, endPoint: .trailing)
                )
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .shadow(color: canAfford ? Color.hsPurple600.opacity(0.3) : .clear,
                        radius: 12, y: 4)
            }
            .disabled(!canAfford || purchaseVm.isLoading)
            
            if !canAfford {
                Text("Yetersiz bakiye")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(Color.hsError)
            }
        }
    }
    
    private func assetPlaceholder(_ asset: AssetItem) -> some View {
        Rectangle()
            .fill(
                LinearGradient(
                    colors: [Color.hsPurple900.opacity(0.3), Color.hsBackgroundSecondary],
                    startPoint: .topLeading, endPoint: .bottomTrailing
                )
            )
            .overlay {
                Image(systemName: asset.icon)
                    .font(.system(size: 28))
                    .foregroundStyle(Color.hsPurple400.opacity(0.5))
            }
    }
    
    private func summaryRow(_ label: String, _ value: String) -> some View {
        HStack {
            Text(label)
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(Color.hsTextSecondary)
            Spacer()
            Text(value)
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(Color.hsTextPrimary)
        }
    }
    
    private func mockPriceData(price: Decimal, percent: Double) -> [Double] {
        let base = Double(truncating: price as NSDecimalNumber)
        return (0..<30).map { i in
            let noise = Double.random(in: -0.05...0.05)
            let trend = Double(i) / 30.0 * (percent / 100.0)
            return base * (1 + trend + noise)
        }
    }
   
    
}
