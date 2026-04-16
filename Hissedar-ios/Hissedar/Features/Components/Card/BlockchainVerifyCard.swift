//
//  BlockchainVerifyCard.swift
//  Hissedar
//
//  Created by Sinan Dinç on 4/10/26.
//  AssetDetailView'ın specificSection'ından sonra ekle
//

import SwiftUI

struct BlockchainVerifyCard: View {
    
    let detail: AssetDetail
    let networkName: String
    let polygonscanBaseUrl: String
    
    init(
        detail: AssetDetail,
        networkName: String = "Polygon Amoy",
        polygonscanBaseUrl: String = "https://amoy.polygonscan.com"
    ) {
        self.detail = detail
        self.networkName = networkName
        self.polygonscanBaseUrl = polygonscanBaseUrl
    }
    
    private var polygonscanContractURL: URL? {
        guard let address = detail.contractAddress else { return nil }
        return URL(string: "\(polygonscanBaseUrl)/address/\(address)")
    }
    
    private var hasBlockchainData: Bool {
        detail.blockchainTokenId != nil || detail.contractAddress != nil
    }
    
    var body: some View {
        if hasBlockchainData {
            cardContent
        }
    }
    
    private var cardContent: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 5) {
                Image(systemName: "checkmark.shield.fill")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(Color.hsPurple400)
                Text("Blockchain Doğrulama")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundStyle(Color.hsTextPrimary)
            }
            
            VStack(spacing: 12) {
                InfoRow(icon: "globe", label: "Ağ", value: networkName)
                InfoRow(icon: "doc.text", label: "Standart", value: "ERC-1155")
                if let tokenId = detail.blockchainTokenId {
                    InfoRow(icon: "number",label: "Token ID",value: "#\(tokenId)")
                }
                
                if let address = detail.contractAddress {
                    contractRow(address)
                }
                
                if let url = polygonscanContractURL {
                    Link(destination: url) {
                        HStack(spacing: 6) {
                            Image(systemName: "arrow.up.right.square")
                                .font(.system(size: 13, weight: .semibold))
                            Text("Polygonscan'de Doğrula")
                                .font(.system(size: 13, weight: .bold))
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .foregroundStyle(Color.hsPurple400)
                        .background(Color.hsPurple600.opacity(0.12))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                }
            }
        }
        .padding()
        .background(Color.hsBackgroundSecondary)
    }
    
    private func contractRow(_ address: String) -> some View {
        HStack {
            HStack(spacing: 6) {
                Image(systemName: "doc.text.fill")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(Color.hsPurple400)
                    .frame(width: 28, height: 28)
                    .background(Color.hsPurple400.opacity(0.08))
                    .clipShape(RoundedRectangle(cornerRadius: 7))
                
                Text("Kontrat")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(Color.hsTextSecondary)
            }
            
            Spacer()
            
            Text(shortAddress(address))
                .font(.system(size: 13, weight: .medium, design: .monospaced))
                .foregroundStyle(Color.hsTextPrimary)
            
            Button {
                UIPasteboard.general.string = address
            } label: {
                Image(systemName: "doc.on.doc")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(Color.hsPurple400)
            }
        }
    }
    private func shortAddress(_ address: String) -> String {
        guard address.count > 10 else { return address }
        return "\(address.prefix(6))...\(address.suffix(4))"
    }
}
