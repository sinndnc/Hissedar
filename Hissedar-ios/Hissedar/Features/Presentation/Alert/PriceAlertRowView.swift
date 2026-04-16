//
//  PriceAlertRowView.swift
//  Hissedar
//
//  Tek bir alarm satırını render eden reusable component.
//

import SwiftUI

struct PriceAlertRowView: View {

    let alert: PriceAlert
    let propertyTitle: String?  // nil ise sadece koşul gösterilir (detay sayfasında olduğu gibi)

    var onToggle: (() -> Void)? = nil
    var onDelete: (() -> Void)? = nil

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            // İkon
            Image(systemName: alert.conditionType.systemIcon)
                .font(.title2)
                .foregroundStyle(iconColor)
                .frame(width: 36, height: 36)
                .background(iconColor.opacity(0.12))
                .clipShape(RoundedRectangle(cornerRadius: 8))

            // İçerik
            VStack(alignment: .leading, spacing: 4) {
                if let title = propertyTitle {
                    Text(title)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .lineLimit(1)
                }

                Text(alert.conditionDescription)
                    .font(propertyTitle == nil ? .subheadline : .caption)
                    .fontWeight(propertyTitle == nil ? .semibold : .regular)
                    .foregroundStyle(propertyTitle == nil ? .primary : .secondary)

                HStack(spacing: 8) {
                    if alert.behavior == .recurring {
                        Label("Sürekli", systemImage: "arrow.triangle.2.circlepath")
                            .font(.caption2)
                            .foregroundStyle(.blue)
                    } else {
                        Label("Tek sefer", systemImage: "1.circle")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }

                    if alert.triggerCount > 0 {
                        Text("•")
                            .foregroundStyle(.secondary)
                        Text("\(alert.triggerCount) kez tetiklendi")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                }
            }

            Spacer()

            // Switch
            if let onToggle = onToggle {
                Toggle("", isOn: Binding(
                    get: { alert.isActive },
                    set: { _ in onToggle() }
                ))
                .labelsHidden()
            }
        }
        .padding(.vertical, 4)
        .contentShape(Rectangle())
        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
            if let onDelete = onDelete {
                Button(role: .destructive) {
                    onDelete()
                } label: {
                    Label("Sil", systemImage: "trash")
                }
            }
        }
    }

    private var iconColor: Color {
        switch alert.conditionType {
        case .below:         return .red
        case .above:         return .green
        case .percentChange: return .orange
        }
    }
}