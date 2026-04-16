//
//  WalletRootView.swift
//  Hissedar
//
//  Created by Sinan Dinç on 3/30/26.
//


import SwiftUI
import Factory

struct WalletRootView: View {
    
    @State private var vm = WalletViewModel()
    @State private var copiedAddress = false
    
    var body: some View {
        ZStack {
            Color.hsBackground.ignoresSafeArea()
            
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
                Text("Blockchain Cüzdan")
                    .font(.system(size: 17, weight: .bold))
                    .foregroundStyle(Color.hsTextPrimary)
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
                        .fill(
                            LinearGradient(
                                colors: [Color.hsPurple600, Color.hsPurple400],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 48, height: 48)
                    
                    Image(systemName: "wallet.bifold.fill")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundStyle(.white)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Polygon Cüzdan")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(Color.hsTextPrimary)
                    
                    HStack(spacing: 4) {
                        Circle()
                            .fill(wallet.isWhitelisted ? Color.hsSuccess : Color.hsWarning)
                            .frame(width: 8, height: 8)
                        Text(wallet.isWhitelisted ? "KYC Onaylı" : "Onay Bekleniyor")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundStyle(Color.hsTextSecondary)
                    }
                }
                
                Spacer()
                
                Image("polygon-logo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 28, height: 28)
                    .opacity(0) // Logo yoksa gizle, eklenince opacity 1 yap
            }
            
            // Address
            HStack {
                Text(wallet.walletAddress)
                    .font(.system(size: 13, weight: .medium, design: .monospaced))
                    .foregroundStyle(Color.hsTextSecondary)
                    .lineLimit(1)
                    .truncationMode(.middle)
                
                Spacer()
                
                Button {
                    UIPasteboard.general.string = wallet.walletAddress
                    withAnimation { copiedAddress = true }
                    Task {
                        try? await Task.sleep(for: .seconds(2))
                        withAnimation { copiedAddress = false }
                    }
                } label: {
                    Image(systemName: copiedAddress ? "checkmark" : "doc.on.doc")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(copiedAddress ? Color.hsSuccess : Color.hsPurple400)
                }
            }
            .padding(12)
            .background(Color.hsBackground)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            
            // Actions
            HStack(spacing: 12) {
                if let url = wallet.polygonscanURL {
                    Link(destination: url) {
                        HStack(spacing: 6) {
                            Image(systemName: "arrow.up.right.square")
                                .font(.system(size: 13, weight: .semibold))
                            Text("Polygonscan")
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
        .padding(16)
        .background(Color.hsBackgroundSecondary)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .strokeBorder(Color.hsBorder, lineWidth: 1)
        )
        .padding(.horizontal)
    }
    
    // MARK: - Stats
    
    private var statsSection: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
            statItem(
                icon: "checkmark.seal.fill",
                value: "\(vm.confirmedCount)",
                label: "Onaylı",
                color: Color.hsSuccess
            )
            statItem(
                icon: "clock.fill",
                value: "\(vm.pendingCount)",
                label: "Bekleyen",
                color: Color.hsWarning
            )
            statItem(
                icon: "bitcoinsign.circle.fill",
                value: "\(vm.totalMinted)",
                label: "Token",
                color: Color.hsPurple400
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
                .foregroundStyle(Color.hsTextPrimary)
            Text(label)
                .font(.system(size: 11, weight: .medium))
                .foregroundStyle(Color.hsTextSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(Color.hsBackgroundSecondary)
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .strokeBorder(Color.hsBorder, lineWidth: 1)
        )
    }
    
    // MARK: - Transactions
    
    private var transactionsSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 8) {
                Image(systemName: "list.bullet.rectangle.fill")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(Color.hsPurple400)
                Text("Blockchain İşlemleri")
                    .font(.system(size: 17, weight: .bold))
                    .foregroundStyle(Color.hsTextPrimary)
            }
            .padding(.bottom)
            .padding(.horizontal)
            
            if vm.transactions.isEmpty {
                Text("Henüz blockchain işlemi yok")
                    .font(.system(size: 14))
                    .foregroundStyle(Color.hsTextTertiary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 32)
            } else {
                ForEach(vm.transactions) { tx in
                    transactionRow(tx)
                    
                    if (vm.transactions.last?.id != tx.id){
                        Divider()
                    }
                }
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
                    Text(tx.txType == "mint" ? "Token Mint" : tx.txType.capitalized)
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(Color.hsTextPrimary)
                    
                    Text("× \(tx.tokenAmount)")
                        .font(.system(size: 12, weight: .bold, design: .monospaced))
                        .foregroundStyle(Color.hsPurple400)
                }
                
                if tx.isConfirmed, let url = tx.polygonscanURL {
                    Link(destination: url) {
                        HStack(spacing: 4) {
                            Text(tx.shortTxHash)
                                .font(.system(size: 11, weight: .medium, design: .monospaced))
                            Image(systemName: "arrow.up.right")
                                .font(.system(size: 9, weight: .bold))
                        }
                        .foregroundStyle(Color.hsPurple400)
                    }
                } else {
                    Text(tx.statusLabel)
                        .font(.system(size: 11, weight: .medium))
                        .foregroundStyle(Color.hsTextTertiary)
                }
            }
            
            Spacer()
            
            // Time
            VStack(alignment: .trailing, spacing: 4) {
                Text(tx.createdAt.formatted(.dateTime.hour().minute()))
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(Color.hsTextSecondary)
                Text(tx.createdAt.formatted(.dateTime.month(.abbreviated).day()))
                    .font(.system(size: 11))
                    .foregroundStyle(Color.hsTextTertiary)
            }
        }
        .padding(14)
        .background(Color.hsBackgroundSecondary)
    }
    
    private func statusColor(_ tx: BlockchainTransaction) -> Color {
        switch tx.status {
        case "confirmed": return Color.hsSuccess
        case "pending": return Color.hsWarning
        case "failed": return Color.hsError
        default: return Color.hsTextTertiary
        }
    }
    
    // MARK: - Empty / Loading
    
    private var noWalletView: some View {
        VStack(spacing: 16) {
            Image(systemName: "wallet.bifold")
                .font(.system(size: 48, weight: .light))
                .foregroundStyle(Color.hsPurple400.opacity(0.5))
            
            Text("Cüzdan Oluşturulmadı")
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(Color.hsTextPrimary)
            
            Text("İlk token satın alımınızda\notomatik olarak oluşturulacak.")
                .font(.system(size: 14))
                .foregroundStyle(Color.hsTextSecondary)
                .multilineTextAlignment(.center)
        }
        .padding(.top, 80)
    }
    
    private var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView().tint(Color.hsPurple400)
            Text("Cüzdan yükleniyor...")
                .font(.system(size: 14))
                .foregroundStyle(Color.hsTextSecondary)
        }
    }
}
