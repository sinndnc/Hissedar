//
//  MockChartData.swift
//  Hissedar
//
//  Created by Sinan Dinç on 4/8/26.
//

import SwiftUI
import Foundation
import Charts

struct PriceData: Identifiable {
    let id = UUID()
    let date: Date
    let price: Double
}

// Örnek veri seti
let mockData: [PriceData] = [
    .init(date: Date().addingTimeInterval(-600), price: 18200),
    .init(date: Date().addingTimeInterval(-500), price: 18100),
    .init(date: Date().addingTimeInterval(-400), price: 18350),
    .init(date: Date().addingTimeInterval(-300), price: 18150),
    .init(date: Date().addingTimeInterval(-200), price: 18250),
    .init(date: Date().addingTimeInterval(-100), price: 18210)
]

struct PriceChartView: View {
    let data: [PriceData] = mockData
    let brandPurple = Color.hsPurple600

    @State private var selectedDate: Date? = nil
    @State private var selectedTimeRange: String = "1G"
    let timeRanges = ["1G", "1H", "1A", "3A", "1Y", "Tümü"]

    var currentDisplayPrice: Double {
        guard let selectedDate else {
            return data.last?.price ?? 0.0
        }
        // En yakın veri noktasını bul (gün karşılaştırması değil, zaman farkı)
        return data.min(by: {
            abs($0.date.timeIntervalSince(selectedDate)) < abs($1.date.timeIntervalSince(selectedDate))
        })?.price ?? data.last?.price ?? 0.0
    }

    var minY: Double { (data.map { $0.price }.min() ?? 0) * 0.995 }
    var maxY: Double { (data.map { $0.price }.max() ?? 0) * 1.005 }

    var body: some View {
        VStack(spacing: 0) {
            // MARK: - Header
            HStack(alignment: .firstTextBaseline) {
                Text("$\(currentDisplayPrice, specifier: "%.2f")")
                    .font(.system(size: 30, weight: .bold, design: .monospaced))
                    .foregroundStyle(Color.hsTextPrimary)
                    .animation(.none, value: currentDisplayPrice) // titreme engelle

                ChangeBadge(change: "%1.20", isPositive: true)
                Spacer()
            }
            .padding(.horizontal)
            .padding(.top)

            // MARK: - Chart
            Chart {
                ForEach(data) { item in
                    LineMark(
                        x: .value("Zaman", item.date),
                        y: .value("Fiyat", item.price)
                    )
                    .interpolationMethod(.cardinal)
                    .foregroundStyle(brandPurple)
                    .lineStyle(StrokeStyle(lineWidth: 2))
                    
                    AreaMark(
                        x: .value("Zaman", item.date),
                        yStart: .value("Min", minY),
                        yEnd: .value("Fiyat", item.price)
                    )
                    .interpolationMethod(.cardinal)
                    .foregroundStyle(
                        LinearGradient(
                            colors: [
                                brandPurple.opacity(0.4),
                                .hsBackgroundSecondary
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                }
                
                if let selectedDate {
                    RuleMark(x: .value("Selected", selectedDate))
                        .foregroundStyle(Color.hsTextPrimary.opacity(0.5))
                        .lineStyle(StrokeStyle(lineWidth: 1, dash: [5]))
                        .annotation(position: .top, overflowResolution: .init(
                            x: .fit(to: .chart), // <-- kenar taşmasını engeller
                            y: .disabled
                        )) {
                            Text(selectedDate, format: .dateTime.hour().minute())
                                .font(.caption2)
                                .padding(4)
                                .background(Color.hsBackgroundSecondary)
                                .cornerRadius(4)
                        }
                }
            }
            .frame(height: 200)
            .chartXAxis(.hidden)
            .frame(maxWidth: .infinity)
            .chartYScale(domain: minY...maxY)
            .chartYAxis {
                AxisMarks(position: .trailing, values: .automatic(desiredCount: 4)) { value in
                    AxisValueLabel {
                        if let v = value.as(Double.self) {
                            Text("$\(v, specifier: "%.0f")")
                                .font(.system(size: 10))
                                .foregroundColor(.gray)
                        }
                    }
                }
            }
            .chartOverlay { proxy in
                GeometryReader { geometry in
                    Color.clear
                        .contentShape(Rectangle())
                        .gesture(
                            DragGesture(minimumDistance: 0)
                                .onChanged { value in
                                    let plotFrame = proxy.plotAreaFrame
                                    let localX = value.location.x - geometry[plotFrame].origin.x
                                    let clampedX = max(0, min(localX, geometry[plotFrame].width))
                                    if let date: Date = proxy.value(atX: clampedX) {
                                        selectedDate = date
                                    }
                                }
                                .onEnded { _ in
                                    selectedDate = nil
                                }
                        )
                }
            }
            
            Divider()
            
            // MARK: - Time Range Selector
            HStack(spacing: 0) {
                ForEach(timeRanges, id: \.self) { range in
                    Text(range)
                        .font(.system(size: 13, weight: .bold))
                        .frame(maxWidth: .infinity)
                        .frame(height: 40)
                        .foregroundColor(selectedTimeRange == range ? brandPurple : .gray)
                        .background(selectedTimeRange == range ? brandPurple.opacity(0.1) : .clear)
                        .onTapGesture {
                            withAnimation { selectedTimeRange = range }
                        }
                }
            }
            .background(Color.hsBackgroundSecondary)

            Divider()
        }
    }
}
