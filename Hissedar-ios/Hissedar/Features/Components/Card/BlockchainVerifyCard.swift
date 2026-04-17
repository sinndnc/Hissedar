//
//  BlockchainVerifyCard.swift
//  Hissedar
//
//  Created by Sinan Dinç on 4/10/26.
//  AssetDetailView'ın specificSection'ından sonra ekle
//

import SwiftUI

// MARK: - BlockchainVerifyCard
struct BlockchainVerifyCard: View {
    let detail: AssetDetail
    let networkName: String
    let polygonscanBaseUrl: String
    @Environment(ThemeManager.self) private var themeManager
    
    init(detail: AssetDetail, networkName: String = "Polygon Amoy", polygonscanBaseUrl: String = "https://amoy.polygonscan.com") {
        self.detail = detail
        self.networkName = networkName
        self.polygonscanBaseUrl = polygonscanBaseUrl
    }
    
    var body: some View {
        if detail.blockchainTokenId != nil || detail.contractAddress != nil {
            VStack(alignment: .leading, spacing: 10) {
                HStack(spacing: 5) {
                    Image(systemName: "checkmark.shield.fill")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(themeManager.theme.accent)
                    Text(String.localized("asset.detail.blockchain_verify"))
                        .font(.system(size: 15, weight: .bold))
                        .foregroundStyle(themeManager.theme.textPrimary)
                }
                
                VStack(spacing: 12) {
                    InfoRow(icon: "globe", label: String.localized("asset.detail.network"), value: networkName)
                    InfoRow(icon: "doc.text", label: String.localized("asset.detail.standard"), value: "ERC-1155")
                    if let tokenId = detail.blockchainTokenId {
                        InfoRow(icon: "number", label: "Token ID", value: "#\(tokenId)")
                    }
                    if let address = detail.contractAddress {
                        contractRow(address)
                    }
                    if let address = detail.contractAddress, let url = URL(string: "\(polygonscanBaseUrl)/address/\(address)") {
                        Link(destination: url) {
                            HStack(spacing: 6) {
                                Image(systemName: "arrow.up.right.square")
                                    .font(.system(size: 13, weight: .semibold))
                                Text(String.localized("asset.detail.verify_polygonscan"))
                                    .font(.system(size: 13, weight: .bold))
                            }
                            .frame(maxWidth: .infinity).padding(.vertical, 12)
                            .foregroundStyle(themeManager.theme.accent)
                            .background(themeManager.theme.accent.opacity(0.12))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                    }
                }
            }
            .padding().background(themeManager.theme.backgroundSecondary)
        }
    }
    
    private func contractRow(_ address: String) -> some View {
        HStack {
            HStack(spacing: 6) {
                Image(systemName: "doc.text.fill").font(.system(size: 12)).foregroundStyle(themeManager.theme.accent)
                Text(String.localized("asset.detail.nft.contract")).font(.system(size: 13)).foregroundStyle(themeManager.theme.textSecondary)
            }
            Spacer()
            Text(shortAddress(address)).font(.system(size: 13, design: .monospaced)).foregroundStyle(themeManager.theme.textPrimary)
            Button { UIPasteboard.general.string = address } label: {
                Image(systemName: "doc.on.doc").font(.system(size: 11)).foregroundStyle(themeManager.theme.accent)
            }
        }
    }
    private func shortAddress(_ a: String) -> String { a.count > 10 ? "\(a.prefix(6))...\(a.suffix(4))" : a }
}
