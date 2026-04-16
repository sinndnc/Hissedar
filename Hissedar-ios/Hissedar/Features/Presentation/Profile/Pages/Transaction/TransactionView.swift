//
//  TransactionsView.swift
//  Hissedar
//
//

import SwiftUI

enum TransactionFilter: String, CaseIterable {
    case all = "Tümü"
    case buy = "Alım"
    case sell = "Satım"
    case deposit = "Yatırma"
    case withdraw = "Çekme"
    case dividend = "Kâr Payı"
    
    var transactionType: TransactionType? {
        switch self {
        case .all: nil
        case .buy: .buy
        case .sell: .sell
        case .deposit: .deposit
        case .withdraw: .withdraw
        case .dividend: .dividend
        }
    }
}

struct TransactionsView: View {
    @State private var vm = TransactionsViewModel()
    
    var body: some View {
        ZStack {
            Color.hsBackground.ignoresSafeArea()
            
            ScrollView(.vertical, showsIndicators: false) {
                LazyVStack(spacing: 0, pinnedViews: .sectionHeaders) {
                    SearchBar(searchText: $vm.searchText)
                        .padding(.horizontal)
                        .padding(.vertical, 10)
                    
                    Section {
                        transactionsList
                    } header: {
                        headerSection
                    }
                }
            }
        }
        .navigationTitle("Transactions")
        .task { await vm.loadTransactions() }
        .sheet(item: $vm.selectedTransaction) { tx in
            TransactionDetailSheet(transaction: tx)
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
                .presentationBackground(Color.hsBackgroundSecondary)
        }
    }
    
    // MARK: - Header
    
    private var headerSection: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 6) {
                ForEach(TransactionFilter.allCases, id: \.self) { filter in
                    FilterChip(
                        title: filter.rawValue,
                        isActive: vm.activeFilter == filter
                    ) {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            vm.activeFilter = filter
                        }
                    }
                }
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 10)
    }
    
    // MARK: - List
    
    private var transactionsList: some View {
        Group {
            if vm.filteredTransactions.isEmpty {
                emptyState
            } else {
                ForEach(vm.filteredTransactions) { tx in
                    TransactionRow(transaction: tx)
                        .onTapGesture { vm.selectedTransaction = tx }
                    
                    if vm.filteredTransactions.last?.id != tx.id {
                        Divider()
                    }
                }
            }
        }
    }
    
    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "tray")
                .font(.system(size: 40))
                .foregroundStyle(Color.hsTextTertiary)
            
            Text("İşlem bulunamadı")
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(Color.hsTextSecondary)
            
            Text("Filtrelerinizi değiştirmeyi deneyin")
                .font(.system(size: 12))
                .foregroundStyle(Color.hsTextTertiary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 60)
    }
}

// MARK: - TransactionRow

struct TransactionRow: View {
    let transaction: TransactionItem
    
    var body: some View {
        HStack(spacing: 12) {
            // Icon
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(transaction.type.color.opacity(0.12))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(transaction.type.color.opacity(0.08), lineWidth: 1)
                    )
                
                Image(systemName: transaction.type.icon)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(transaction.type.color)
            }
            .frame(width: 40, height: 40)
            
            // Info
            VStack(alignment: .leading, spacing: 3) {
                if let description = transaction.description {
                    Text(description)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(Color.hsTextPrimary)
                        .lineLimit(1)
                }
                
                HStack(spacing: 6) {
                    Text(transaction.type.label)
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(transaction.type.color)
                    
                    Circle()
                        .fill(Color.hsTextTertiary)
                        .frame(width: 3, height: 3)
                    
                    Text(transaction.createdAt)
                        .font(.system(size: 12))
                        .foregroundStyle(Color.hsTextSecondary)
                    
                    if transaction.status != .confirmed {
                        Circle()
                            .fill(Color.hsTextTertiary)
                            .frame(width: 3, height: 3)
                        
                        StatusBadge(status: transaction.status)
                    }
                    
                    // Blockchain badge
                    if transaction.hasBlockchainTx {
                        Image(systemName: "link")
                            .font(.system(size: 9, weight: .bold))
                            .foregroundStyle(Color.hsSuccess)
                    } else if transaction.isBlockchainPending {
                        Image(systemName: "link")
                            .font(.system(size: 9, weight: .bold))
                            .foregroundStyle(Color.hsWarning)
                    }
                }
            }
            
            Spacer(minLength: 4)
            
            // Value
            VStack(alignment: .trailing, spacing: 2) {
                Text("\(transaction.type.isPositive ? "+" : "-")\(transaction.formattedAmount)")
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .foregroundStyle(transaction.type.isPositive ? Color.hsSuccess : .hsTextPrimary)
                    .monospacedDigit()
                
                if transaction.tokenAmount > 0 {
                    Text("\(transaction.tokenAmount) token")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundStyle(Color.hsTextSecondary)
                }
            }
        }
        .padding(15)
        .background(Color.hsBackgroundSecondary)
    }
}

// MARK: - Detail Sheet

struct TransactionDetailSheet: View {
    let transaction: TransactionItem
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Details
                DetailRow(label: "İşlem Tipi", value: transaction.type.label)
                DetailRow(label: "Durum") {
                    StatusBadge(status: transaction.status)
                }
                DetailRow(
                    label: "Tutar",
                    value: "\(transaction.type.isPositive ? "+" : "-")\(transaction.formattedAmount)"
                )
                
                if transaction.tokenAmount > 0 {
                    DetailRow(label: "Token Adedi", value: "\(transaction.tokenAmount)")
                }
                
                if let price = transaction.pricePerToken {
                    DetailRow(label: "Token Fiyatı", value: "₺\(price)")
                }
                
                if let fee = transaction.fee, fee > 0 {
                    DetailRow(label: "Komisyon", value: "₺\(fee)")
                }
                
                DetailRow(label: "Para Birimi", value: transaction.currency)
                
                DetailRow(
                    label: "Varlık Tipi",
                    value: assetTypeLabel(transaction.assetType)
                )
                
                DetailRow(label: "Tarih", value: transaction.fullDate)
                
                // Blockchain section
                blockchainSection
            }
            .padding(.horizontal)
            .toolbar{ closeButton }
            .scrollBounceBehavior(.basedOnSize)
            .navigationTitle("Transaciton Detail")
        }
    }
    
    // MARK: - Blockchain Section
    @ToolbarContentBuilder
    private var closeButton: some ToolbarContent {
        ToolbarItem(placement: .topBarLeading) {
            Button { dismiss() } label: {
                Text("Close")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(Color.hsPurple400)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.hsPurple600.opacity(0.12))
                    )
            }
        }
    }
    
    
    @ViewBuilder
    private var blockchainSection: some View {
        // Divider before blockchain section
        Rectangle()
            .fill(Color.hsPurple400.opacity(0.3))
            .frame(height: 1)
            .padding(.vertical, 8)
        
        // Blockchain header
        HStack(spacing: 6) {
            Image(systemName: "link")
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(Color.hsPurple400)
            Text("Blockchain")
                .font(.system(size: 14, weight: .bold))
                .foregroundStyle(Color.hsTextPrimary)
            Spacer()
            
            if transaction.hasBlockchainTx {
                HStack(spacing: 4) {
                    Circle()
                        .fill(Color.hsSuccess)
                        .frame(width: 6, height: 6)
                    Text("On-chain")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundStyle(Color.hsSuccess)
                }
            } else if transaction.isBlockchainPending {
                HStack(spacing: 4) {
                    ProgressView()
                        .scaleEffect(0.6)
                        .tint(Color.hsWarning)
                    Text("İşleniyor")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundStyle(Color.hsWarning)
                }
            } else {
                Text("Off-chain")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(Color.hsTextTertiary)
            }
        }
        .padding(.vertical, 8)
        
        // TX Hash row with Polygonscan link
        if let hash = transaction.txHash, !hash.isEmpty, hash != "pending" {
            HStack {
                Text("TX Hash")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(Color.hsTextSecondary)
                
                Spacer()
                
                if let url = transaction.polygonscanURL {
                    Link(destination: url) {
                        HStack(spacing: 4) {
                            Text(transaction.truncatedHash)
                                .font(.system(size: 13, weight: .medium, design: .monospaced))
                            Image(systemName: "arrow.up.right")
                                .font(.system(size: 10, weight: .bold))
                        }
                        .foregroundStyle(Color.hsPurple400)
                    }
                } else {
                    Text(transaction.truncatedHash)
                        .font(.system(size: 13, weight: .medium, design: .monospaced))
                        .foregroundStyle(Color.hsTextPrimary)
                }
                
                Button {
                    UIPasteboard.general.string = hash
                } label: {
                    Image(systemName: "doc.on.doc")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundStyle(Color.hsPurple400)
                }
            }
            .padding(.vertical, 12)
            .overlay(alignment: .bottom) {
                Rectangle()
                    .fill(Color.hsBorder)
                    .frame(height: 1)
            }
        }
    }
    
    private func assetTypeLabel(_ type: String) -> String {
        switch type {
        case "property": "Gayrimenkul"
        case "art": "Sanat"
        case "nft": "NFT"
        case "token": "Token"
        default: type.capitalized
        }
    }
}

// MARK: - FilterChip

struct FilterChip: View {
    let title: String
    let isActive: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(isActive ? Color.hsPurple400 : .hsTextSecondary)
                .padding(.horizontal, 14)
                .padding(.vertical, 7)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(isActive ? Color.hsPurple600.opacity(0.15) : Color.hsBackgroundTertiary)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(isActive ? Color.hsPurple600.opacity(0.25) : .clear, lineWidth: 1)
                )
        }
        .buttonStyle(.plain)
    }
}



// MARK: - StatusBadge

struct StatusBadge: View {
    let status: TransactionStatus
    
    var body: some View {
        Text(status.label)
            .font(.system(size: 11, weight: .semibold))
            .tracking(0.3)
            .foregroundStyle(status.color)
            .padding(.horizontal, 8)
            .padding(.vertical, 3)
            .background(
                RoundedRectangle(cornerRadius: 6)
                    .fill(status.color.opacity(0.1))
            )
    }
}

// MARK: - DetailRow
struct DetailRow: View {
    let label: String
    var value: String? = nil
    var isMono: Bool = false
    var trailingContent: (() -> AnyView)? = nil
    
    init(label: String, value: String, isMono: Bool = false) {
        self.label = label
        self.value = value
        self.isMono = isMono
    }
    
    init<Content: View>(label: String, @ViewBuilder content: @escaping () -> Content) {
        self.label = label
        self.trailingContent = { AnyView(content()) }
    }
    
    var body: some View {
        HStack {
            Text(label)
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(Color.hsTextSecondary)
            
            Spacer()
            
            if let trailingContent {
                trailingContent()
            } else if let value {
                Text(value)
                    .font(
                        isMono
                        ? .system(size: 13, weight: .medium, design: .monospaced)
                        : .system(size: 14, weight: .medium)
                    )
                    .foregroundStyle(Color.hsTextPrimary)
            }
        }
        .padding(.vertical, 12)
        .overlay(alignment: .bottom) {
            Rectangle()
                .fill(Color.hsBorder)
                .frame(height: 1)
        }
    }
}

// MARK: - Preview

#Preview {
    TransactionsView()
        .preferredColorScheme(.dark)
}
