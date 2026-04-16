//
//  ExchangeSuccessSheet.swift
//  Hissedar
//
//  Created by Sinan Dinç on 4/13/26.
//
//  Başarılı dönüşüm sonrası gösterilen sonuç ekranı.
//

import SwiftUI

struct ExchangeSuccessSheet: View {

    let result: ExchangeResult
    let direction: ExchangeDirection
    let onDismiss: () -> Void

    var body: some View {
        VStack(spacing: 24) {

            Spacer()

            // Başarı ikonu
            ZStack {
                Circle()
                    .fill(Color.hEmerald.opacity(0.12))
                    .frame(width: 80, height: 80)
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 48))
                    .foregroundStyle(Color.hEmerald)
            }

            VStack(spacing: 6) {
                Text("Dönüşüm Başarılı!")
                    .font(.title2.bold())
                    .foregroundStyle(Color.hsTextPrimary)

                Text(summaryText)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }

            // Detay kartı
            VStack(spacing: 12) {
                if direction == .buyHSR {
                    detailRow("Harcanan", value: formatTRY(result.trySpent ?? 0))
                    detailRow("Alınan", value: formatHSR(result.hsrReceived ?? 0), highlight: true)
                } else {
                    detailRow("Harcanan", value: formatHSR(result.hsrSpent ?? 0))
                    detailRow("Alınan", value: formatTRY(result.tryReceived ?? 0), highlight: true)
                }

                Divider()

                detailRow("Komisyon", value: formatTRY(result.fee))
                detailRow("Kur", value: "1 HSR = \(formatTRY(result.exchangeRate))")

                Divider()

                detailRow("Yeni TRY Bakiye", value: formatTRY(result.newTryBalance))
                detailRow("Yeni HSR Bakiye", value: formatHSR(result.newHsrBalance))
            }
            .padding(16)
            .background(Color.hsTextSecondary)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .strokeBorder(Color.hsBorder, lineWidth: 0.5)
            )

            Spacer()

            Button {
                onDismiss()
            } label: {
                Text("Tamam")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(Color.hEmerald)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
        }
        .padding(20)
        .background(Color.hsBackground)
        .presentationDetents([.large])
        .presentationDragIndicator(.visible)
    }

    // MARK: - Helpers

    private var summaryText: String {
        switch direction {
        case .buyHSR:
            return "\(formatTRY(result.trySpent ?? 0)) karşılığında \(formatHSR(result.hsrReceived ?? 0)) satın aldınız."
        case .sellHSR:
            return "\(formatHSR(result.hsrSpent ?? 0)) karşılığında \(formatTRY(result.tryReceived ?? 0)) aldınız."
        }
    }

    private func detailRow(_ label: String, value: String, highlight: Bool = false) -> some View {
        HStack {
            Text(label)
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Spacer()
            Text(value)
                .font(highlight ? .subheadline.bold() : .subheadline)
                .foregroundStyle(highlight ? Color.hEmerald : Color.hsTextPrimary)
        }
    }

    private func formatTRY(_ value: Decimal) -> String {
        CurrencyFormatter.format(value, currency: .TRY)
    }

    private func formatHSR(_ value: Decimal) -> String {
        "\(CurrencyFormatter.formatValue(value, currency: .TRY)) HSR"
    }
}
