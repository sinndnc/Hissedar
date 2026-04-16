import SwiftUI

// MARK: - Wallets View
struct WalletsView: View {
    
    @State private var selectedWallet: WalletItem? = nil
    @State private var showDepositSheet = false
    @State private var showWithdrawSheet = false
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 24) {
                totalBalanceCard
                quickActions
                walletsList
                recentActivity
            }
            .padding(.horizontal, 20)
            .padding(.top, 8)
            .padding(.bottom, 40)
        }
        .background(Color.hsBackground)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("Cüzdanlarım")
                    .font(.hHeadline)
                    .foregroundStyle(Color.hWhite)
            }
        }
    }
    
    // MARK: - Total Balance Card
    private var totalBalanceCard: some View {
        VStack(spacing: 16) {
            VStack(spacing: 6) {
                Text("Toplam Bakiye")
                    .font(.hCaption)
                    .foregroundStyle(Color.hsTextPrimary)
                
                Text("₺124.850,00")
                    .font(.system(size: 34, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.hWhite)
                
                HStack(spacing: 4) {
                    Image(systemName: "arrow.up.right")
                        .font(.system(size: 11, weight: .semibold))
                    Text("+₺2.340 bu ay")
                        .font(.hLabel)
                }
                .foregroundStyle(Color.hJade)
            }
            
            // Mini sparkline placeholder
            RoundedRectangle(cornerRadius: 4)
                .fill(
                    LinearGradient(
                        colors: [Color.hJade.opacity(0.4), Color.hJade.opacity(0.05)],
                        startPoint: .top, endPoint: .bottom
                    )
                )
                .frame(height: 48)
                .overlay(
                    // Simple wave path as sparkline
                    WalletSparkline()
                        .stroke(Color.hJade, style: StrokeStyle(lineWidth: 2, lineCap: .round))
                        .padding(.horizontal, 8)
                )
        }
        .frame(maxWidth: .infinity)
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.hsBackgroundSecondary)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.hJade.opacity(0.15), lineWidth: 1)
                )
        )
    }
    
    // MARK: - Quick Actions
    private var quickActions: some View {
        HStack(spacing: 12) {
            WalletActionButton(
                icon: "arrow.down.to.line",
                title: "Para Yatır",
                color: Color.hJade
            ) {
                showDepositSheet = true
            }
            
            WalletActionButton(
                icon: "arrow.up.from.line",
                title: "Para Çek",
                color: Color.hGold
            ) {
                showWithdrawSheet = true
            }
            
            WalletActionButton(
                icon: "arrow.left.arrow.right",
                title: "Transfer",
                color: Color.hSilver
            ) {
                // Transfer action
            }
        }
    }
    
    // MARK: - Wallets List
    private var walletsList: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Cüzdanlar")
                .font(.hBodyMedium)
                .foregroundStyle(Color.hWhite)
            
            VStack(spacing: 0) {
                ForEach(WalletItem.sampleWallets) { wallet in
                    WalletRowView(wallet: wallet)
                    
                    if wallet.id != WalletItem.sampleWallets.last?.id {
                        Divider()
                            .background(Color.hWhite.opacity(0.06))
                            .padding(.leading, 52)
                    }
                }
            }
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.hsBackgroundSecondary)
            )
        }
    }
    
    // MARK: - Recent Activity
    private var recentActivity: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text("Son İşlemler")
                    .font(.hBodyMedium)
                    .foregroundStyle(Color.hWhite)
                Spacer()
                Text("Tümünü Gör")
                    .font(.hLabel)
                    .foregroundStyle(Color.hJade)
            }
            
            VStack(spacing: 0) {
                ForEach(WalletTransaction.samples) { tx in
                    WalletTransactionRow(transaction: tx)
                    
                    if tx.id != WalletTransaction.samples.last?.id {
                        Divider()
                            .background(Color.hWhite.opacity(0.06))
                            .padding(.leading, 52)
                    }
                }
            }
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.hsBackgroundSecondary)
            )
        }
    }
}

// MARK: - Wallet Action Button
struct WalletActionButton: View {
    let icon: String
    let title: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 10) {
                ZStack {
                    Circle()
                        .fill(color.opacity(0.12))
                        .frame(width: 48, height: 48)
                    
                    Image(systemName: icon)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(color)
                }
                
                Text(title)
                    .font(.hLabel)
                    .foregroundStyle(Color.hWhite)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.hsBackgroundSecondary)
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Wallet Row
struct WalletRowView: View {
    let wallet: WalletItem
    
    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(wallet.accentColor.opacity(0.12))
                    .frame(width: 40, height: 40)
                
                Image(systemName: wallet.icon)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(wallet.accentColor)
            }
            
            VStack(alignment: .leading, spacing: 3) {
                Text(wallet.name)
                    .font(.hBody)
                    .foregroundStyle(Color.hWhite)
                
                Text(wallet.subtitle)
                    .font(.hLabel)
                    .foregroundStyle(Color.hsTextPrimary)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 3) {
                Text(wallet.balance)
                    .font(.hBodyMedium)
                    .foregroundStyle(Color.hWhite)
                
                Text(wallet.change)
                    .font(.hLabel)
                    .foregroundStyle(wallet.isPositive ? Color.hJade : Color.hRust)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
    }
}

// MARK: - Transaction Row
struct WalletTransactionRow: View {
    let transaction: WalletTransaction
    
    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(transaction.isIncoming ? Color.hJade.opacity(0.12) : Color.hRust.opacity(0.12))
                    .frame(width: 40, height: 40)
                
                Image(systemName: transaction.isIncoming ? "arrow.down.left" : "arrow.up.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(transaction.isIncoming ? Color.hJade : Color.hRust)
            }
            
            VStack(alignment: .leading, spacing: 3) {
                Text(transaction.title)
                    .font(.hBody)
                    .foregroundStyle(Color.hWhite)
                
                Text(transaction.date)
                    .font(.hLabel)
                    .foregroundStyle(Color.hsTextPrimary)
            }
            
            Spacer()
            
            Text(transaction.amount)
                .font(.hBodyMedium)
                .foregroundStyle(transaction.isIncoming ? Color.hJade : Color.hWhite)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
    }
}

// MARK: - Sparkline Shape
struct WalletSparkline: Shape {
    func path(in rect: CGRect) -> Path {
        let points: [CGFloat] = [0.6, 0.5, 0.65, 0.4, 0.55, 0.3, 0.35, 0.2, 0.25, 0.15]
        var path = Path()
        let stepX = rect.width / CGFloat(points.count - 1)
        
        for (i, point) in points.enumerated() {
            let x = CGFloat(i) * stepX
            let y = rect.height * point
            if i == 0 {
                path.move(to: CGPoint(x: x, y: y))
            } else {
                let prevX = CGFloat(i - 1) * stepX
                let prevY = rect.height * points[i - 1]
                let controlX1 = prevX + stepX * 0.4
                let controlX2 = x - stepX * 0.4
                path.addCurve(
                    to: CGPoint(x: x, y: y),
                    control1: CGPoint(x: controlX1, y: prevY),
                    control2: CGPoint(x: controlX2, y: y)
                )
            }
        }
        return path
    }
}

// MARK: - Models
struct WalletItem: Identifiable {
    let id = UUID()
    let name: String
    let subtitle: String
    let icon: String
    let balance: String
    let change: String
    let isPositive: Bool
    let accentColor: Color
    
    static let sampleWallets: [WalletItem] = [
        WalletItem(name: "TL Cüzdan", subtitle: "Ana hesap", icon: "turkishlirasign.circle.fill", balance: "₺84.250", change: "+₺1.200", isPositive: true, accentColor: .hJade),
        WalletItem(name: "Gayrimenkul", subtitle: "3 varlık", icon: "building.2.fill", balance: "₺32.100", change: "+₺890", isPositive: true, accentColor: .hGold),
        WalletItem(name: "Sanat & NFT", subtitle: "5 varlık", icon: "paintpalette.fill", balance: "₺8.500", change: "-₺250", isPositive: false, accentColor: .hMint),
    ]
}

struct WalletTransaction: Identifiable {
    let id = UUID()
    let title: String
    let date: String
    let amount: String
    let isIncoming: Bool
    
    static let samples: [WalletTransaction] = [
        WalletTransaction(title: "Kira Geliri", date: "27 Mar 2026", amount: "+₺1.450", isIncoming: true),
        WalletTransaction(title: "Token Alımı", date: "25 Mar 2026", amount: "-₺3.200", isIncoming: false),
        WalletTransaction(title: "Para Yatırma", date: "22 Mar 2026", amount: "+₺10.000", isIncoming: true),
        WalletTransaction(title: "Komisyon", date: "20 Mar 2026", amount: "-₺45", isIncoming: false),
    ]
}
