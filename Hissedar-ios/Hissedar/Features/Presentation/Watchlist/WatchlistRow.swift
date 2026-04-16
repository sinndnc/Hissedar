//
//  WatchlistRow.swift
//  Hissedar
//
//  Created by Sinan Dinç on 3/24/26.
//

import Foundation
import SwiftUI

struct WatchlistRow: View {
    let item: AssetItem
    
    var body: some View {
        HStack(spacing: 15) {
            // Icon
            ZStack{
                if let imageUrl = item.imageUrl {
                    AsyncImage(url: URL(string: imageUrl)!)
                        .scaledToFit()
                        .frame(width: 44, height: 44)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }else{
                    Text(item.imageUrl ?? "H")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .frame(width: 44, height: 44)
                        .background(Color(hex: "12131A"))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }
            }
            
            VStack(alignment: .leading,spacing: 10){
                // Info
                VStack(alignment: .leading, spacing: 3) {
                    Text(item.title)
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(Color(hex: "F0F1F5"))
                        .lineLimit(1)
                    
                    Text(item.subtitle ?? "")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(Color(hex: "8B8D9E"))
                        .lineLimit(1)
                }
                
                ProgressView(value: Double.random(in: 0.0...0.9))
                    .frame(height: 3)
                    .progressViewStyle(.linear)
                    .tint(Color.hsPurple400)
            }
            
            // Price + Change
            VStack(alignment: .trailing, spacing: 3) {
                AmountBadge(
                    price: item.formattedHSRPrice
                )
                
                ChangeBadge(
                    change: item.formattedChange,
                    isPositive: item.isPositive
                )
            }
        }
        .padding(.horizontal)
        .padding(.vertical,10)
        .background(Color.hsBackgroundSecondary)
    }
}

private struct MiniSparkline: View {
    let data: [Double]
    let isPositive: Bool
    
    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height
            
            Path { path in
                guard data.count > 1 else { return }
                let mn = data.min() ?? 0
                let mx = data.max() ?? 1
                let range = mx - mn == 0 ? 1 : mx - mn
                
                for (i, val) in data.enumerated() {
                    let x = w * CGFloat(i) / CGFloat(data.count - 1)
                    let y = h * (1 - CGFloat((val - mn) / range)) * 0.8 + h * 0.1
                    if i == 0 { path.move(to: CGPoint(x: x, y: y)) }
                    else { path.addLine(to: CGPoint(x: x, y: y)) }
                }
            }
            .stroke(
                isPositive ? Color(hex: "00E87B") : Color(hex: "FF4D6A"),
                style: StrokeStyle(lineWidth: 1.5, lineCap: .round, lineJoin: .round)
            )
        }
    }
}
