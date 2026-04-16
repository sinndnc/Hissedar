import SwiftUI

// MARK: - Rent Income View
struct RentIncomeView: View {
    
    @State private var selectedPeriod: RentPeriod = .monthly
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 24) {
                incomeHeader
                periodSelector
                incomeChart
                breakdownSection
                upcomingPayments
            }
            .padding(.horizontal, 20)
            .padding(.top, 8)
            .padding(.bottom, 40)
        }
        .background(Color.hsBackground)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("Kira Gelirleri")
                    .font(.hHeadline)
                    .foregroundStyle(Color.hWhite)
            }
        }
    }
    
    // MARK: - Income Header
    private var incomeHeader: some View {
        VStack(spacing: 8) {
            Text("Toplam Kira Geliri")
                .font(.hCaption)
                .foregroundStyle(Color.hsTextPrimary)
            
            Text("₺3.240")
                .font(.system(size: 38, weight: .bold, design: .rounded))
                .foregroundStyle(Color.hWhite)
            
            HStack(spacing: 6) {
                HStack(spacing: 3) {
                    Image(systemName: "arrow.up.right")
                        .font(.system(size: 10, weight: .bold))
                    Text("+%12.5")
                        .font(.hLabel)
                }
                .foregroundStyle(Color.hJade)
                
                Text("geçen aya göre")
                    .font(.hLabel)
                    .foregroundStyle(Color.hsTextPrimary)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.hsBackgroundSecondary)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.hJade.opacity(0.12), lineWidth: 1)
                )
        )
    }
    
    // MARK: - Period Selector
    private var periodSelector: some View {
        HStack(spacing: 4) {
            ForEach(RentPeriod.allCases, id: \.self) { period in
                Button {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        selectedPeriod = period
                    }
                } label: {
                    Text(period.title)
                        .font(.hLabel)
                        .foregroundStyle(selectedPeriod == period ? Color.hCharcoal : Color.hsTextPrimary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(
                            Capsule()
                                .fill(selectedPeriod == period ? Color.hJade : Color.clear)
                        )
                }
                .buttonStyle(.plain)
            }
        }
        .padding(4)
        .background(
            Capsule()
                .fill(Color.hsBackgroundSecondary)
        )
    }
    
    // MARK: - Income Chart
    private var incomeChart: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Gelir Grafiği")
                .font(.hBodyMedium)
                .foregroundStyle(Color.hWhite)
            
            HStack(alignment: .bottom, spacing: 8) {
                ForEach(RentChartData.samples) { item in
                    VStack(spacing: 6) {
                        RoundedRectangle(cornerRadius: 6)
                            .fill(
                                item.isCurrent
                                ? LinearGradient(colors: [Color.hJade, Color.hJade.opacity(0.6)], startPoint: .top, endPoint: .bottom)
                                : LinearGradient(colors: [Color.hWhite.opacity(0.15), Color.hWhite.opacity(0.05)], startPoint: .top, endPoint: .bottom)
                            )
                            .frame(height: item.height)
                        
                        Text(item.label)
                            .font(.system(size: 10))
                            .foregroundStyle(item.isCurrent ? Color.hJade : Color.hsTextPrimary)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .frame(height: 160)
            .padding(.top, 8)
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.hsBackgroundSecondary)
        )
    }
    
    // MARK: - Breakdown
    private var breakdownSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Gelir Dağılımı")
                .font(.hBodyMedium)
                .foregroundStyle(Color.hWhite)
            
            VStack(spacing: 0) {
                ForEach(RentBreakdown.samples) { item in
                    HStack(spacing: 14) {
                        Circle()
                            .fill(item.color)
                            .frame(width: 10, height: 10)
                        
                        Text(item.name)
                            .font(.hBody)
                            .foregroundStyle(Color.hWhite)
                        
                        Spacer()
                        
                        Text(item.amount)
                            .font(.hBodyMedium)
                            .foregroundStyle(Color.hWhite)
                        
                        Text(item.percentage)
                            .font(.hLabel)
                            .foregroundStyle(Color.hsTextPrimary)
                            .frame(width: 42, alignment: .trailing)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 14)
                    
                    if item.id != RentBreakdown.samples.last?.id {
                        Divider()
                            .background(Color.hWhite.opacity(0.06))
                            .padding(.leading, 40)
                    }
                }
            }
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.hsBackgroundSecondary)
            )
        }
    }
    
    // MARK: - Upcoming Payments
    private var upcomingPayments: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text("Yaklaşan Ödemeler")
                    .font(.hBodyMedium)
                    .foregroundStyle(Color.hWhite)
                Spacer()
                Image(systemName: "bell.badge")
                    .font(.system(size: 14))
                    .foregroundStyle(Color.hGold)
            }
            
            VStack(spacing: 10) {
                ForEach(UpcomingRent.samples) { rent in
                    HStack(spacing: 14) {
                        VStack(spacing: 2) {
                            Text(rent.day)
                                .font(.system(size: 18, weight: .bold, design: .rounded))
                                .foregroundStyle(Color.hWhite)
                            Text(rent.month)
                                .font(.system(size: 10))
                                .foregroundStyle(Color.hsTextPrimary)
                        }
                        .frame(width: 44, height: 44)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.hWhite.opacity(0.05))
                        )
                        
                        VStack(alignment: .leading, spacing: 3) {
                            Text(rent.property)
                                .font(.hBody)
                                .foregroundStyle(Color.hWhite)
                            Text(rent.status)
                                .font(.hLabel)
                                .foregroundStyle(rent.statusColor)
                        }
                        
                        Spacer()
                        
                        Text(rent.amount)
                            .font(.hBodyMedium)
                            .foregroundStyle(Color.hJade)
                    }
                    .padding(14)
                    .background(
                        RoundedRectangle(cornerRadius: 14)
                            .fill(Color.hsBackgroundSecondary)
                    )
                }
            }
        }
    }
}

// MARK: - Period
enum RentPeriod: CaseIterable {
    case weekly, monthly, yearly
    
    var title: String {
        switch self {
        case .weekly: "Haftalık"
        case .monthly: "Aylık"
        case .yearly: "Yıllık"
        }
    }
}

// MARK: - Chart Data
struct RentChartData: Identifiable {
    let id = UUID()
    let label: String
    let height: CGFloat
    let isCurrent: Bool
    
    static let samples: [RentChartData] = [
        .init(label: "Eki", height: 80, isCurrent: false),
        .init(label: "Kas", height: 95, isCurrent: false),
        .init(label: "Ara", height: 90, isCurrent: false),
        .init(label: "Oca", height: 110, isCurrent: false),
        .init(label: "Şub", height: 120, isCurrent: false),
        .init(label: "Mar", height: 140, isCurrent: true),
    ]
}

// MARK: - Breakdown
struct RentBreakdown: Identifiable {
    let id = UUID()
    let name: String
    let amount: String
    let percentage: String
    let color: Color
    
    static let samples: [RentBreakdown] = [
        .init(name: "Kadıköy Residence", amount: "₺1.780", percentage: "%55", color: .hJade),
        .init(name: "Levent Plaza Ofis", amount: "₺960", percentage: "%30", color: .hGold),
        .init(name: "Ataşehir Konut", amount: "₺500", percentage: "%15", color: .hMint),
    ]
}

// MARK: - Upcoming Rent
struct UpcomingRent: Identifiable {
    let id = UUID()
    let day: String
    let month: String
    let property: String
    let amount: String
    let status: String
    let statusColor: Color
    
    static let samples: [UpcomingRent] = [
        .init(day: "01", month: "Nis", property: "Kadıköy Residence", amount: "+₺1.780", status: "5 gün kaldı", statusColor: .hGold),
        .init(day: "01", month: "Nis", property: "Levent Plaza", amount: "+₺960", status: "5 gün kaldı", statusColor: .hGold),
        .init(day: "15", month: "Nis", property: "Ataşehir Konut", amount: "+₺500", status: "19 gün kaldı", statusColor: .hsTextPrimary),
    ]
}
