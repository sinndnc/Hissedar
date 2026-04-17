//
//  PurchaseSuccessView.swift
//  Hissedar
//
//  Created by Sinan Dinç on 4/10/26.
//

import SwiftUI

struct PurchaseSuccessOverlay: View {
    
    let asset: AssetItem
    let purchaseAmount: Int
    let formattedTotal: String
    let blockchainStatus: String
    let walletAddress: String
    
    @Environment(ThemeManager.self) private var themeManager
    
    var body: some View {
        VStack(spacing: 24) {
            // Success icon
            ZStack {
                Circle()
                    .fill(themeManager.theme.success.opacity(0.15))
                    .frame(width: 96, height: 96)
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 56))
                    .foregroundStyle(themeManager.theme.success)
            }
            
            Text(String.localized("purchase.success.title"))
                .font(.system(size: 24, weight: .bold))
                .foregroundStyle(themeManager.theme.textPrimary)
            
            VStack(spacing: 8) {
                Text(String(format: String.localized("purchase.success.desc"), purchaseAmount, asset.title))
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(themeManager.theme.textSecondary)
                    .multilineTextAlignment(.center)
                Text(formattedTotal)
                    .font(.system(size: 28, weight: .bold, design: .monospaced))
                    .foregroundStyle(themeManager.theme.textPrimary)
            }
            
            // Blockchain status
            VStack(spacing: 10) {
                Divider().background(themeManager.theme.border)
                
                HStack(spacing: 8) {
                    Image(systemName: "link")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(themeManager.theme.accent)
                    Text(String.localized("common.blockchain"))
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(themeManager.theme.textPrimary)
                    
                    Spacer()
                    
                    HStack(spacing: 4) {
                        if blockchainStatus == "pending" {
                            ProgressView()
                                .scaleEffect(0.7)
                                .tint(themeManager.theme.warning)
                        }
                        Text(blockchainStatus == "pending" ? String.localized("common.processing") : String.localized("common.confirmed"))
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(
                                blockchainStatus == "pending"
                                ? themeManager.theme.warning
                                : themeManager.theme.success
                            )
                    }
                }
                
                if !walletAddress.isEmpty {
                    HStack {
                        Text(String.localized("common.wallet"))
                            .font(.system(size: 12, weight: .medium))
                            .foregroundStyle(themeManager.theme.textSecondary)
                        Spacer()
                        Text(shortAddress(walletAddress))
                            .font(.system(size: 12, weight: .medium, design: .monospaced))
                            .foregroundStyle(themeManager.theme.textSecondary)
                    }
                }
            }
            .padding(.horizontal, 4)
            
            Text(String.localized("purchase.success.footer"))
                .font(.system(size: 13))
                .foregroundStyle(themeManager.theme.textTertiary)
                .multilineTextAlignment(.center)
        }
        .padding(24)
        .background(themeManager.theme.backgroundSecondary)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .strokeBorder(themeManager.theme.border, lineWidth: 1)
        )
        .padding(.horizontal, 20)
    }
    
    private func shortAddress(_ address: String) -> String {
        guard address.count > 10 else { return address }
        return "\(address.prefix(6))...\(address.suffix(4))"
    }
}
