//
//  ExchangeSuccessSheet.swift
//  Hissedar
//
//  Created by Sinan Dinç on 4/13/26.
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
                    .fill(Color.hsPurple600.opacity(0.12))
                    .frame(width: 80, height: 80)
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 48))
                    .foregroundStyle(Color.hsPurple600)
            }

            VStack(spacing: 6) {
                Text(String.localized("exchange.success.title"))
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
                    detailRow(String.localized("exchange.success.spent"), value: formatTRY(result.trySpent ?? 0))
                    detailRow(String.localized("exchange.success.received"), value: formatHSR(result.hsrReceived ?? 0), highlight: true)
                } else {
                    detailRow(String.localized("exchange.success.spent"), value: formatHSR(result.hsrSpent ?? 0))
                    detailRow(String.localized("exchange.success.received"), value: formatTRY(result.tryReceived ?? 0), highlight: true)
                }

                Divider()

                detailRow(String.localized("exchange.success.fee"), value: formatTRY(result.fee))
                detailRow(String.localized("exchange.success.rate"), value: "1 HSR = \(formatTRY(result.exchangeRate))")

                Divider()

                detailRow(String.localized("exchange.success.new_try"), value: formatTRY(result.newTryBalance))
                detailRow(String.localized("exchange.success.new_hsr"), value: formatHSR(result.newHsrBalance))
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
                Text(String.localized("common.ok"))
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(Color.hsPurple600)
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
            return String(format: String.localized("exchange.success.summary_buy"), formatTRY(result.trySpent ?? 0), formatHSR(result.hsrReceived ?? 0))
        case .sellHSR:
            return String(format: String.localized("exchange.success.summary_sell"), formatHSR(result.hsrSpent ?? 0), formatTRY(result.tryReceived ?? 0))
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
                .foregroundStyle(highlight ? Color.hsTextPrimary : Color.hsTextSecondary)
        }
    }

    private func formatTRY(_ value: Decimal) -> String {
        CurrencyFormatter.format(value, currency: .TRY)
    }

    private func formatHSR(_ value: Decimal) -> String {
        "\(CurrencyFormatter.formatValue(value, currency: .TRY)) HSR"
    }
}
