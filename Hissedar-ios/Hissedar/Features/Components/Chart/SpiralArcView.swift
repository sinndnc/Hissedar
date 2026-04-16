//
//  ProgramItem.swift
//  Hissedar
//
//  Created by Sinan Dinç on 4/14/26.
//

import SwiftUI

struct SpiralArcView: View {
    let items: [AssetItem]
    
    // Tasarım parametreleri
    private let maxVisibleArcs = 5
    private let gap: CGFloat = 15 // Halkalar arası boşluk
    private let lineWeight: CGFloat = 7 // Çizgi kalınlığı
    
    private var totalPortfolioValue: Decimal {
        items.reduce(0) { $0 + ($1.currentValue * Decimal($1.tokenAmount ?? 0)) }
    }
    
    var body: some View {
        GeometryReader { geometry in
            // Ekranın en küçük kenarına göre bir tam çap belirliyoruz
            let fullSize = min(geometry.size.width, geometry.size.height)
            let center = CGPoint(x: geometry.size.width * 0.475, y: geometry.size.height / 2)
            
            // Verileri hesapla
            let configs = arcConfigs(availableWidth: fullSize)
            
            ZStack {
                ForEach(configs) { arc in
                    // 1. Arka Plan Yayı (Sabit %75 uzunlukta)
                    Circle()
                        .trim(from: 0, to: 0.75)
                        .stroke(Color.gray.opacity(0.1), style: StrokeStyle(lineWidth: lineWeight, lineCap: .round))
                        .frame(width: arc.radius * 2, height: arc.radius * 2)
                        .rotationEffect(.degrees(-90))
                    
                    // 2. İlerleme Yayı (%75'in, varlığın portföydeki yüzdesi kadarı)
                    Circle()
                        .trim(from: 0, to: arc.progress * 0.75)
                        .stroke(arc.color, style: StrokeStyle(lineWidth: lineWeight, lineCap: .round))
                        .frame(width: arc.radius * 2, height: arc.radius * 2)
                        .rotationEffect(.degrees(-90))
                        .animation(.spring(response: 0.6, dampingFraction: 0.8), value: arc.progress)
                    
                    // 3. Etiketler (Dinamik Konumlandırma)
                    ArcLabelView(arc: arc)
                        .position(
                            x: center.x,
                            y: center.y - arc.radius
                        )
                }
            }
        }
        .aspectRatio(1, contentMode: .fit) // Her zaman kare kalmasını sağlar
    }
    
    private func arcConfigs(availableWidth: CGFloat) -> [ArcConfig] {
        let totalValue = totalPortfolioValue
        guard totalValue > 0 else { return [] }
        
        let sortedItems = items.sorted {
            ($0.currentValue * Decimal($0.tokenAmount ?? 0)) > ($1.currentValue * Decimal($1.tokenAmount ?? 0))
        }
        
        var configs: [ArcConfig] = []
        
        // En dış halkanın yarıçapı: (Kullanılabilir genişlik / 2) - Çizgi Payı
        let maxRadius = (availableWidth / 2) - 20
        
        // İLK 5 VARLIK
        let topItems = sortedItems.prefix(maxVisibleArcs)
        for (index, item) in topItems.enumerated() {
            let itemValue = item.currentValue * Decimal(item.tokenAmount ?? 0)
            let weight = Double(truncating: (itemValue / totalValue) as NSDecimalNumber)
            
            configs.append(ArcConfig(
                title: item.title,
                color: colorForIndex(index),
                // Yarıçapı her halka için 'gap' kadar küçültüyoruz
                radius: maxRadius - (CGFloat(index) * gap),
                progress: weight
            ))
        }
        
        // DİĞERLERİ (6. Halka)
        if sortedItems.count > maxVisibleArcs {
            let othersValue = sortedItems.dropFirst(maxVisibleArcs).reduce(0) { $0 + ($1.currentValue * Decimal($1.tokenAmount ?? 0)) }
            let othersWeight = Double(truncating: (othersValue / totalValue) as NSDecimalNumber)
            
            if othersWeight > 0 {
                configs.append(ArcConfig(
                    title: "Diğerleri",
                    color: Color.gray.opacity(0.4),
                    radius: maxRadius - (CGFloat(maxVisibleArcs) * gap),
                    progress: othersWeight
                ))
            }
        }
        return configs
    }
    
    private func colorForIndex(_ index: Int) -> Color {
        let colors: [Color] = [
            .hsPurple900,
            .hsPurple800,
            .hsPurple600,
            .hsPurple400,
            .hsPurple300
        ]
        return colors[index % colors.count]
    }
}


struct ArcConfig : Identifiable{
    let id = UUID() // Benzersiz kimlik
    let title: String
    let color: Color
    let radius: CGFloat
    let progress: Double
}

struct ArcLabelView: View {
    let arc: ArcConfig
    
    var body: some View {
        HStack(alignment: .center, spacing: 4) {
            Text(arc.title)
                .foregroundStyle(Color.hsTextSecondary)
                .font(.system(size: 11, weight: .light))
            
            Text("%\(Int(arc.progress * 100))")
                .frame(width: 25, alignment: .trailing)
                .foregroundStyle(Color.hsTextPrimary)
                .font(.system(size: 12, weight: .semibold, design: .monospaced))
        }
        .padding(.horizontal, 4)
        .fixedSize()
        .frame(width: 0, height: 0, alignment: .trailing)
    }
}


struct SizeKey: PreferenceKey {
    static var defaultValue: Anchor<CGRect>? = nil
    static func reduce(value: inout Anchor<CGRect>?, nextValue: () -> Anchor<CGRect>?) {
        value = nextValue() ?? value
    }
}
