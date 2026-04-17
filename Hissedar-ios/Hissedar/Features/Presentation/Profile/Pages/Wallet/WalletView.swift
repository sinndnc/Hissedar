//
//  WalletRootView.swift
//  Hissedar
//
//  Created by Sinan Dinç on 3/30/26.
//

import SwiftUI
import Factory

struct WalletView: View {
    
    @State private var vm = WalletViewModel()
    @State private var copiedAddress = false
    @Environment(ThemeManager.self) private var themeManager
    
    var body: some View {
        ZStack {
            themeManager.theme.background.ignoresSafeArea()
            
            if vm.isLoading && vm.wallet == nil {
                loadingView
            } else {
                contentView
            }
        }
        .task { await vm.load() }
        .refreshable { await vm.load() }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text(String.localized("wallet.nav_title"))
                    .font(.system(size: 17, weight: .bold))
                    .foregroundStyle(themeManager.theme.textPrimary)
            }
        }
    }
    
    // MARK: - Content
    
    private var contentView: some View {
        ScrollView {
            LazyVStack(spacing: 20) {
                if let wallet = vm.wallet {
                    walletCard(wallet)
                    statsSection
                    transactionsSection
                } else {
                    noWalletView
                }
            }
            .padding(.top, 12)
         }
        .scrollIndicators(.hidden)
    }
    
    // MARK: - Wallet Card
    
    private func walletCard(_ wallet: UserWallet) -> some View {
        VStack(spacing: 16) {
            // Header
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(themeManager.theme.accent.gradient)
                        .frame(width: 48, height: 48)
                    
                    Image(systemName: "wallet.bifold.fill")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundStyle(.white)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(String.localized("wallet.card_name"))
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(themeManager.theme.textPrimary)
                    
                    HStack(spacing: 4) {
                        Circle()
                            .fill(wallet.isWhitelisted ?
                                  themeManager.theme.success :
                                    themeManager.theme.warning)
                            .frame(width: 8, height: 8)
                        Text(wallet.isWhitelisted ? String.localized("wallet.status.kyc_on") : String.localized("wallet.status.kyc_pending"))
                            .font(.system(size: 12, weight: .medium))
                            .foregroundStyle(themeManager.theme.textSecondary)
                    }
                }
                
                Spacer()
                
                // Polygon Logo placeholder - varlık varsa gösterilir
                Image("polygon-logo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 24, height: 24)
                    .grayscale(1.0)
                    .opacity(0.3)
            }
            
            // Address
            HStack {
                Text(wallet.walletAddress)
                    .font(.system(size: 13, weight: .medium, design: .monospaced))
                    .foregroundStyle(themeManager.theme.textSecondary)
                    .lineLimit(1)
                    .truncationMode(.middle)
                
                Spacer()
                
                Button {
                    UIPasteboard.general.string = wallet.walletAddress
                    withAnimation(.spring(response: 0.3)) { copiedAddress = true }
                    Task {
                        try? await Task.sleep(for: .seconds(2))
                        withAnimation { copiedAddress = false }
                    }
                } label: {
                    Image(systemName: copiedAddress ? "checkmark.circle.fill" : "doc.on.doc")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(
                            copiedAddress ?
                            themeManager.theme.success :
                                themeManager.theme.accent
                        )
                }
            }
            .padding(12)
            .background(themeManager.theme.background)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            
            // Actions
            HStack(spacing: 12) {
                if let url = wallet.polygonscanURL {
                    Link(destination: url) {
                        HStack(spacing: 6) {
                            Image(systemName: "arrow.up.right.square")
                                .font(.system(size: 13, weight: .semibold))
                            Text(String.localized("wallet.action.view_explorer"))
                                .font(.system(size: 13, weight: .bold))
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .foregroundStyle(themeManager.theme.accent)
                        .background(themeManager.theme.accent.opacity(0.12))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                }
            }
        }
        .padding(16)
        .background(themeManager.theme.backgroundSecondary)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .strokeBorder(themeManager.theme.border, lineWidth: 1)
        )
        .padding(.horizontal)
    }
    
    // MARK: - Stats
    
    private var statsSection: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
            statItem(
                icon: "checkmark.seal.fill",
                value: "\(vm.confirmedCount)",
                label: String.localized("wallet.stats.confirmed"),
                color: themeManager.theme.success
            )
            statItem(
                icon: "clock.fill",
                value: "\(vm.pendingCount)",
                label: String.localized("wallet.stats.pending"),
                color: themeManager.theme.warning
            )
            statItem(
                icon: "bitcoinsign.circle.fill",
                value: "\(vm.totalMinted)",
                label: String.localized("wallet.stats.tokens"),
                color: themeManager.theme.accent
            )
        }
        .padding(.horizontal)
    }
    
    private func statItem(icon: String, value: String, label: String, color: Color) -> some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundStyle(color)
            Text(value)
                .font(.system(size: 20, weight: .bold, design: .monospaced))
                .foregroundStyle(themeManager.theme.textPrimary)
            Text(label)
                .font(.system(size: 11, weight: .medium))
                .foregroundStyle(themeManager.theme.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(themeManager.theme.backgroundSecondary)
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .strokeBorder(themeManager.theme.border, lineWidth: 1)
        )
    }
    
    // MARK: - Transactions
    
    private var transactionsSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 8) {
                Image(systemName: "list.bullet.rectangle.fill")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(themeManager.theme.accent)
                Text(String.localized("wallet.tx.section_title"))
                    .font(.system(size: 17, weight: .bold))
                    .foregroundStyle(themeManager.theme.textPrimary)
            }
            .padding(.bottom)
            .padding(.horizontal)
            
            if vm.transactions.isEmpty {
                Text(String.localized("wallet.tx.empty_state"))
                    .font(.system(size: 14))
                    .foregroundStyle(themeManager.theme.textTertiary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 32)
            } else {
                VStack(spacing: 0) {
                    ForEach(vm.transactions) { tx in
                        transactionRow(tx)
                        
                        if (vm.transactions.last?.id != tx.id){
                            Divider()
                                .padding(.leading, 64)
                        }
                    }
                }
                .background(themeManager.theme.backgroundSecondary)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .strokeBorder(themeManager.theme.border, lineWidth: 1)
                )
                .padding(.horizontal)
            }
        }
    }
    
    private func transactionRow(_ tx: BlockchainTransaction) -> some View {
        HStack(spacing: 12) {
            // Status icon
            ZStack {
                Circle()
                    .fill(statusColor(tx).opacity(0.15))
                    .frame(width: 40, height: 40)
                Image(systemName: tx.statusIcon)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(statusColor(tx))
            }
            
            // Info
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 6) {
                    Text(tx.txType == "mint" ? String.localized("wallet.tx.type_mint") : tx.txType.capitalized)
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(themeManager.theme.textPrimary)
                    
                    Text("× \(tx.tokenAmount)")
                        .font(.system(size: 12, weight: .bold, design: .monospaced))
                        .foregroundStyle(themeManager.theme.accent)
                }
                
                if tx.isConfirmed, let url = tx.polygonscanURL {
                    Link(destination: url) {
                        HStack(spacing: 4) {
                            Text(tx.shortTxHash)
                                .font(.system(size: 11, weight: .medium, design: .monospaced))
                            Image(systemName: "arrow.up.right")
                                .font(.system(size: 9, weight: .bold))
                        }
                        .foregroundStyle(themeManager.theme.accent)
                    }
                } else {
                    Text(tx.statusLabel)
                        .font(.system(size: 11, weight: .medium))
                        .foregroundStyle(themeManager.theme.textTertiary)
                }
            }
            
            Spacer()
            
            // Time
            VStack(alignment: .trailing, spacing: 4) {
                Text(tx.createdAt.formatted(.dateTime.hour().minute()))
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(themeManager.theme.textSecondary)
                Text(tx.createdAt.formatted(.dateTime.month(.abbreviated).day()))
                    .font(.system(size: 11))
                    .foregroundStyle(themeManager.theme.textTertiary)
            }
        }
        .padding(14)
    }
    
    private func statusColor(_ tx: BlockchainTransaction) -> Color {
        switch tx.status {
        case "confirmed": return themeManager.theme.success
        case "pending": return themeManager.theme.warning
        case "failed": return themeManager.theme.error
        default: return themeManager.theme.textTertiary
        }
    }
    
    // MARK: - Empty / Loading
    
    private var noWalletView: some View {
        VStack(spacing: 16) {
            Image(systemName: "wallet.bifold")
                .font(.system(size: 48, weight: .light))
                .foregroundStyle(themeManager.theme.accent.opacity(0.5))
            
            Text(String.localized("wallet.empty.title"))
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(themeManager.theme.textPrimary)
            
            Text(String.localized("wallet.empty.desc"))
                .font(.system(size: 14))
                .foregroundStyle(themeManager.theme.textSecondary)
                .multilineTextAlignment(.center)
        }
        .padding(.top, 80)
    }
    
    private var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView().tint(themeManager.theme.accent)
            Text(String.localized("wallet.loading"))
                .font(.system(size: 14))
                .foregroundStyle(themeManager.theme.textSecondary)
        }
    }
}
