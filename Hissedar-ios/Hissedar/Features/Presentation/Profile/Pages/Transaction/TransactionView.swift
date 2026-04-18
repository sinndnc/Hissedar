//
//  TransactionsView.swift
//  Hissedar
//

import SwiftUI

enum TransactionFilter: String, CaseIterable {
    case all, buy, sell, deposit, withdraw, dividend
    
    var localizedTitle: String {
        /// rawValue: "all", "buy", "sell" … → "transactions.filter.all" vb.
        String.localized("transactions.filter.\(rawValue)")
    }
    
    var transactionType: TransactionType? {
        switch self {
        case .all:      nil
        case .buy:      .buy
        case .sell:     .sell
        case .deposit:  .deposit
        case .withdraw: .withdraw
        case .dividend: .dividend
        }
    }
}

struct TransactionsView: View {
    @State private var vm = TransactionsViewModel()
    @Environment(ThemeManager.self) private var themeManager
    
    var body: some View {
        ZStack {
            themeManager.theme.background.ignoresSafeArea()
            
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
        .navigationTitle(String.localized("transactions.nav_title"))
        .task { await vm.loadTransactions() }
        .sheet(item: $vm.selectedTransaction) { tx in
            TransactionDetailSheet(transaction: tx)
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
                .presentationBackground(themeManager.theme.backgroundSecondary)
        }
    }
    
    // MARK: - Header
    
    private var headerSection: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 6) {
                ForEach(TransactionFilter.allCases, id: \.self) { filter in
                    FilterChip(
                        title: filter.localizedTitle,
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
        .background(themeManager.theme.background)
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
                            .padding(.leading, 67)
                    }
                }
            }
        }
    }
    
    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "tray")
                .font(.system(size: 40))
                .foregroundStyle(themeManager.theme.textTertiary)
            
            Text(String.localized("transactions.empty.title"))
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(themeManager.theme.textSecondary)
            
            Text(String.localized("transactions.empty.desc"))
                .font(.system(size: 12))
                .foregroundStyle(themeManager.theme.textTertiary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 60)
    }
}

// MARK: - TransactionDetailSheet

struct TransactionDetailSheet: View {
    let transaction: TransactionItem
    @Environment(\.dismiss) private var dismiss
    @Environment(ThemeManager.self) private var themeManager
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 0) {
                    DetailRow(label: String.localized("transactions.detail.type"), value: transaction.type.label)
                    DetailRow(label: String.localized("transactions.detail.status")) {
                        StatusBadge(status: transaction.status)
                    }
                    DetailRow(
                        label: String.localized("transactions.detail.amount"),
                        value: "\(transaction.type.isPositive ? "+" : "-")\(transaction.formattedAmount)"
                    )
                    
                    if transaction.tokenAmount > 0 {
                        DetailRow(label: String.localized("transactions.detail.token_count"), value: "\(transaction.tokenAmount)")
                    }
                    
                    if let price = transaction.pricePerToken {
                        DetailRow(label: String.localized("transactions.detail.token_price"), value: "₺\(price)")
                    }
                    
                    if let fee = transaction.fee, fee > 0 {
                        DetailRow(label: String.localized("transactions.detail.fee"), value: "₺\(fee)")
                    }
                    
                    DetailRow(label: String.localized("transactions.detail.currency"), value: transaction.currency)
                    
                    DetailRow(
                        label: String.localized("transactions.detail.asset_type"),
                        value: assetTypeLabel(transaction.assetType)
                    )
                    
                    DetailRow(label: String.localized("transactions.detail.date"), value: transaction.fullDate)
                    
                    blockchainSection
                }
                .padding(.horizontal)
            }
            .background(themeManager.theme.backgroundSecondary)
            .navigationTitle(String.localized("transactions.detail.nav_title"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(String.localized("common.close")) { dismiss() }
                        .foregroundStyle(themeManager.theme.accent)
                }
            }
        }
    }
    
    @ViewBuilder
    private var blockchainSection: some View {
        VStack(spacing: 0) {
            HStack(spacing: 6) {
                Image(systemName: "link")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(themeManager.theme.accent)
                Text(String.localized("transactions.detail.blockchain.title"))
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(themeManager.theme.textPrimary)
                Spacer()
                
                blockchainStatusBadge
            }
            .padding(.vertical, 16)
            
            if let hash = transaction.txHash, !hash.isEmpty, hash != "pending" {
                HStack {
                    Text(String.localized("TX Hash"))
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(themeManager.theme.textSecondary)
                    
                    Spacer()
                    
                    if let url = transaction.polygonscanURL {
                        Link(destination: url) {
                            HStack(spacing: 4) {
                                Text(transaction.truncatedHash)
                                    .font(.system(size: 13, weight: .medium, design: .monospaced))
                                Image(systemName: "arrow.up.right")
                                    .font(.system(size: 10, weight: .bold))
                            }
                            .foregroundStyle(themeManager.theme.accent)
                        }
                    }
                    
                    Button {
                        UIPasteboard.general.string = hash
                    } label: {
                        Image(systemName: "doc.on.doc")
                            .font(.system(size: 11))
                            .foregroundStyle(themeManager.theme.accent)
                    }
                }
                .padding(.vertical, 12)
            }
        }
    }
    
    @ViewBuilder
    private var blockchainStatusBadge: some View {
        if transaction.hasBlockchainTx {
            badgeView(text: "On-chain", color: themeManager.theme.success)
        } else if transaction.isBlockchainPending {
            badgeView(text: String.localized("transactions.status.processing"), color: themeManager.theme.warning)
        } else {
            badgeView(text: "Off-chain", color: themeManager.theme.textTertiary)
        }
    }
    
    private func badgeView(text: String, color: Color) -> some View {
        Text(text)
            .font(.system(size: 11, weight: .semibold))
            .foregroundStyle(color)
            .padding(.horizontal, 8)
            .padding(.vertical, 3)
            .background(color.opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: 6))
    }
    
    /// "asset_type" alanı API'den snake_case gelir (örn: "real_estate").
    /// Noktalı key formatına dönüştürüp localize edilir.
    private func assetTypeLabel(_ type: String) -> String {
        // API'den gelen değer zaten "property", "apartment" gibi
        // xcstrings'de "asset.type.property" şeklinde kayıtlı
        let normalized = type.lowercased().replacingOccurrences(of: "_", with: "")
        let key = "asset.type.\(normalized)"
        let localized = String.localized(key)
        // Eğer key bulunamazsa (localize edilmemiş) ham değeri döndür
        return localized == key ? type : localized
    }
}

// MARK: - TransactionRow

struct TransactionRow: View {
    let transaction: TransactionItem
    @Environment(ThemeManager.self) private var themeManager
    
    var body: some View {
        HStack(spacing: 12) {
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
            
            VStack(alignment: .leading, spacing: 3) {
                if let description = transaction.description {
                    Text(description)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(themeManager.theme.textPrimary)
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
                        .foregroundStyle(themeManager.theme.textSecondary)
                    
                    if transaction.status != .confirmed {
                        Circle()
                            .fill(themeManager.theme.textTertiary)
                            .frame(width: 3, height: 3)
                        
                        StatusBadge(status: transaction.status)
                    }
                    
                    if transaction.hasBlockchainTx {
                        Image(systemName: "link")
                            .font(.system(size: 9, weight: .bold))
                            .foregroundStyle(themeManager.theme.success)
                    } else if transaction.isBlockchainPending {
                        Image(systemName: "link")
                            .font(.system(size: 9, weight: .bold))
                            .foregroundStyle(themeManager.theme.warning)
                    }
                }
            }
            
            Spacer(minLength: 4)
            
            VStack(alignment: .trailing, spacing: 2) {
                Text("\(transaction.type.isPositive ? "+" : "-")\(transaction.formattedAmount)")
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .foregroundStyle(
                        transaction.type.isPositive
                        ? themeManager.theme.success
                        : themeManager.theme.textPrimary
                    )
                    .monospacedDigit()
                
                if transaction.tokenAmount > 0 {
                    Text("\(transaction.tokenAmount) token")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundStyle(themeManager.theme.textSecondary)
                }
            }
        }
        .padding(15)
        .background(themeManager.theme.backgroundSecondary)
    }
}

// MARK: - FilterChip

struct FilterChip: View {
    let title: String
    let isActive: Bool
    let action: () -> Void
    
    @Environment(ThemeManager.self) private var themeManager
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(
                    isActive
                    ? themeManager.theme.accent
                    : themeManager.theme.textSecondary
                )
                .padding(.horizontal, 14)
                .padding(.vertical, 7)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(
                            isActive
                            ? themeManager.theme.accent.opacity(0.15)
                            : themeManager.theme.backgroundTertiary
                        )
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
    @Environment(ThemeManager.self) private var themeManager
    
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
                .foregroundStyle(themeManager.theme.textSecondary)
            
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
                    .foregroundStyle(themeManager.theme.textPrimary)
            }
        }
        .padding(.vertical, 12)
        .overlay(alignment: .bottom) {
            Rectangle()
                .fill(themeManager.theme.border)
                .frame(height: 1)
        }
    }
}

// MARK: - Preview

#Preview {
    TransactionsView()
        .preferredColorScheme(.dark)
}
