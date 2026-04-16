//
//  PurchaseSuccessView.swift
//  Hissedar
//
//  Created by Sinan Dinç on 4/10/26.
//
//  PurchaseView içindeki successView'ı bu dosyayla değiştir
//  veya PurchaseView.swift'teki successView fonksiyonunu bu kodla güncelle
//

import SwiftUI

/// PurchaseView içinde kullanılacak success overlay
struct PurchaseSuccessOverlay: View {
    
    let asset: AssetItem
    let purchaseAmount: Int
    let formattedTotal: String
    let blockchainStatus: String
    let walletAddress: String
    
    var body: some View {
        VStack(spacing: 24) {
            // Success icon
            ZStack {
                Circle()
                    .fill(Color.hsSuccess.opacity(0.15))
                    .frame(width: 96, height: 96)
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 56))
                    .foregroundStyle(Color.hsSuccess)
            }
            
            Text("Satın Alma Başarılı!")
                .font(.system(size: 24, weight: .bold))
                .foregroundStyle(Color.hsTextPrimary)
            
            VStack(spacing: 8) {
                Text("\(purchaseAmount) adet \(asset.title) token'ı")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(Color.hsTextSecondary)
                Text(formattedTotal)
                    .font(.system(size: 28, weight: .bold, design: .monospaced))
                    .foregroundStyle(Color.hsTextPrimary)
            }
            
            // Blockchain status
            VStack(spacing: 10) {
                Divider().background(Color.hsBorder)
                
                HStack(spacing: 8) {
                    Image(systemName: "link")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(Color.hsPurple400)
                    Text("Blockchain")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(Color.hsTextPrimary)
                    
                    Spacer()
                    
                    HStack(spacing: 4) {
                        if blockchainStatus == "pending" {
                            ProgressView()
                                .scaleEffect(0.7)
                                .tint(Color.hsWarning)
                        }
                        Text(blockchainStatus == "pending" ? "İşleniyor..." : "Onaylandı")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(
                                blockchainStatus == "pending"
                                ? Color.hsWarning
                                : Color.hsSuccess
                            )
                    }
                }
                
                if !walletAddress.isEmpty {
                    HStack {
                        Text("Cüzdan")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundStyle(Color.hsTextSecondary)
                        Spacer()
                        Text(shortAddress(walletAddress))
                            .font(.system(size: 12, weight: .medium, design: .monospaced))
                            .foregroundStyle(Color.hsTextSecondary)
                    }
                }
            }
            .padding(.horizontal, 4)
            
            Text("Token'larınız blockchain'e kaydediliyor")
                .font(.system(size: 13))
                .foregroundStyle(Color.hsTextTertiary)
        }
        .padding(24)
        .background(Color.hsBackgroundSecondary)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .strokeBorder(Color.hsBorder, lineWidth: 1)
        )
        .padding(.horizontal, 20)
    }
    
    private func shortAddress(_ address: String) -> String {
        guard address.count > 10 else { return address }
        return "\(address.prefix(6))...\(address.suffix(4))"
    }
}
