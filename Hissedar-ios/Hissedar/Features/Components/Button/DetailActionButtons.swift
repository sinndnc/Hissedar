//
//  DetailActionButtons.swift
//  Hissedar
//
//  Created by Sinan Dinç on 4/8/26.
//
import SwiftUI

struct DetailActionButtons: View {
    let buyLabel: String
    let sellLabel: String
    let onBuy: () -> Void
    let onSell: () -> Void

    init(
        buyLabel: String = "Satın Al",
        sellLabel: String = "Sat",
        onBuy: @escaping () -> Void = {},
        onSell: @escaping () -> Void = {}
    ) {
        self.buyLabel = buyLabel
        self.sellLabel = sellLabel
        self.onBuy = onBuy
        self.onSell = onSell
    }

    var body: some View {
        HStack(spacing: 12) {
            Button(action: onBuy) {
                HStack(spacing: 8) {
                    Image(systemName: "cart.fill")
                        .font(.system(size: 15, weight: .semibold))
                    Text(buyLabel)
                        .font(.system(size: 16, weight: .bold))
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .foregroundStyle(.white)
                .background(
                    LinearGradient(
                        colors: [Color.hsPurple600, Color.hsPurple700],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .shadow(color: Color.hsPurple600.opacity(0.3), radius: 12, y: 4)
            }

            Button(action: onSell) {
                HStack(spacing: 8) {
                    Image(systemName: "minus.circle.fill")
                        .font(.system(size: 15, weight: .semibold))
                    Text(sellLabel)
                        .font(.system(size: 16, weight: .bold))
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(Color.red)
                .foregroundStyle(Color.hsTextPrimary)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .strokeBorder(Color.hsError.opacity(0.25), lineWidth: 1)
                )
            }
        }
    }
}
