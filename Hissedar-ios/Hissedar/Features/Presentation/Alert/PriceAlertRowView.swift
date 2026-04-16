//
//  PriceAlertRowView.swift
//  Hissedar
//
//  Reusable alarm satırı (Alarmlarım listesi için).
//

import SwiftUI

struct PriceAlertRowView: View {

    let alert: AssetPriceAlert
    let assetTitle: String?  // nil = sadece koşul gösterilir

    var onToggle: (() -> Void)? = nil

    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            // İkon
            Image(systemName: alert.conditionType.systemIcon)
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(iconColor)
                .frame(width: 38, height: 38)
                .background(iconColor.opacity(0.12))
                .clipShape(RoundedRectangle(cornerRadius: 10))

            // İçerik
            VStack(alignment: .leading, spacing: 4) {
                if let assetTitle {
                    Text(assetTitle)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(Color.hsTextPrimary)
                        .lineLimit(1)
                }

                Text(alert.conditionDescription)
                    .font(.system(size: assetTitle == nil ? 14 : 12,
                                  weight: assetTitle == nil ? .semibold : .regular))
                    .foregroundStyle(assetTitle == nil ? Color.hsTextPrimary : Color.hsTextSecondary)
                    .lineLimit(1)

                HStack(spacing: 6) {
                    // Asset type pill
                    Text(alert.assetType.label.uppercased())
                        .font(.system(size: 9, weight: .bold))
                        .tracking(0.5)
                        .foregroundStyle(alert.assetType.accentColor)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(alert.assetType.accentColor.opacity(0.12))
                        .clipShape(Capsule())

                    // Behavior pill
                    HStack(spacing: 3) {
                        Image(systemName: alert.behavior == .recurring
                              ? "arrow.triangle.2.circlepath"
                              : "1.circle")
                            .font(.system(size: 9))
                        Text(alert.behavior.displayName)
                            .font(.system(size: 10, weight: .medium))
                    }
                    .foregroundStyle(Color.hsTextSecondary)

                    if alert.triggerCount > 0 {
                        Text("•")
                            .foregroundStyle(Color.hsTextSecondary)
                        Text("\(alert.triggerCount)x")
                            .font(.system(size: 10, weight: .medium, design: .monospaced))
                            .foregroundStyle(Color.hsTextSecondary)
                    }
                }
            }

            Spacer()

            if let onToggle {
                Toggle("", isOn: Binding(
                    get: { alert.isActive },
                    set: { _ in onToggle() }
                ))
                .labelsHidden()
                .tint(Color.hsPurple600)
            }
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 14)
        .background(Color.hsBackgroundSecondary)
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .strokeBorder(Color.hsBorder, lineWidth: 0.5)
        )
        .opacity(alert.isActive ? 1.0 : 0.55)
    }

    private var iconColor: Color {
        switch alert.conditionType {
        case .below:         return Color.hsError
        case .above:         return Color.hsSuccess
        case .percentChange: return Color.hsPurple400
        }
    }
}
