//
//  ExchangeView.swift
//  Hissedar
//
//  Created by Sinan Dinç on 4/13/26.
//

import SwiftUI

struct ExchangeView: View {
    @State private var vm = ExchangeViewModel()
    @Environment(\.dismiss) private var dismiss
    
    // Klavye odağını kontrol eden değişken
    @FocusState private var isAmountFocused: Bool
    @Environment(ThemeManager.self) private var themeManager
    
    var body: some View {
        NavigationStack {
            ZStack {
                themeManager.theme.background.ignoresSafeArea()
                
                VStack(spacing: 0) {
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 10) {
                            // MARK: - Swap Cards
                            VStack(spacing: -12) {
                                swapInputCard(
                                    title: String.localized("exchange.label.selling"),
                                    currency: vm.direction == .buyHSR ? "TRY" : "HSR",
                                    balance: vm.formattedAvailable,
                                    isSource: true
                                )
                                
                                swapToggleIcon
                                
                                swapInputCard(
                                    title: String.localized("exchange.label.buying"),
                                    currency: vm.direction == .buyHSR ? "HSR" : "TRY",
                                    balance: vm.direction == .buyHSR ? vm.wallet?.formattedAvailableHSR ?? "0 HSR" : vm.wallet?.formattedAvailableTRY ?? "₺0",
                                    isSource: false
                                )
                            }
                            
                            rateInfoSection
                            
                            Spacer(minLength: 10)
                        }
                        .padding(.horizontal)
                    }
                    
                    VStack {
                        quickAmountButtons
                        exchangeButton
                    }
                    .padding()
                }
            }
            .task { await vm.load() }
            .navigationTitle(String.localized("exchange.nav_title"))
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    isAmountFocused = true
                }
            }
            .onDisappear {
                isAmountFocused = false
            }
        }
    }
    
    private func swapInputCard(title: String, currency: String, balance: String, isSource: Bool) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.system(size: 11, weight: .bold))
                .foregroundColor(.gray)
            
            HStack {
                HStack(spacing: 8) {
                    Circle()
                        .fill(currency == "TRY" ? Color.red : Color.purple)
                        .frame(width: 28, height: 28)
                        .overlay(Text(currency == "TRY" ? "₺" : "H")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(themeManager.theme.textPrimary))
                    Text(currency)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(themeManager.theme.textPrimary)
                    Image(systemName: "chevron.down")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(themeManager.theme.textSecondary)
                }
                .padding(.horizontal, 10).padding(.vertical, 6)
                .background(themeManager.theme.backgroundTertiary)
                .cornerRadius(20)
                
                Spacer()
                
                if isSource {
                    TextField("0", text: $vm.amountText)
                        .font(.system(size: 32, weight: .medium))
                        .foregroundColor(themeManager.theme.textPrimary)
                        .multilineTextAlignment(.trailing)
                        .keyboardType(.decimalPad)
                        .focused($isAmountFocused)
                } else {
                    Text(vm.formattedOutput.isEmpty ? "0.00" : vm.formattedOutput)
                        .font(.system(size: 32, weight: .medium))
                        .foregroundColor(themeManager.theme.textSecondary)
                        .lineLimit(1)
                }
            }
            
            HStack {
                Text("\(String.localized("exchange.balance_label")): \(balance)")
                Spacer()
                Text("≈ $0.00")
            }
            .font(.system(size: 11))
            .foregroundColor(themeManager.theme.textSecondary)
        }
        .padding(15)
        .background(themeManager.theme.backgroundSecondary)
        .cornerRadius(20)
        .overlay(
            RoundedRectangle(cornerRadius: 25)
                .stroke(themeManager.theme.backgroundTertiary, lineWidth: 1)
        )
    }
    
    private var swapToggleIcon: some View {
        Button(action: { withAnimation(.spring()) { vm.toggleDirection() } }) {
            Image(systemName: "arrow.up.arrow.down")
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(themeManager.theme.textPrimary)
                .padding(12)
                .background(themeManager.theme.background)
                .clipShape(Circle())
                .overlay(Circle().stroke(themeManager.theme.background, lineWidth: 4))
        }
        .zIndex(1)
    }
    
    private var rateInfoSection: some View {
        HStack {
            HStack(spacing: 4) {
                Circle().fill(Color.green).frame(width: 6, height: 6)
                Text(vm.formattedRate)
            }
            Spacer()
            Text(String(format: String.localized("exchange.fee_label"), "\(vm.feePercent)"))
        }
        .foregroundColor(.gray)
        .padding(.horizontal, 12)
        .font(.system(size: 11, weight: .medium))
    }
    
    private var quickAmountButtons: some View {
        HStack(spacing: 10) {
            ForEach(["%25", "%50", "%75", String.localized("common.all")], id: \.self) { label in
                Button(action: { /* Yüzde hesaplama */ }) {
                    Text(label)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(themeManager.theme.textSecondary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(themeManager.theme.backgroundTertiary)
                        .cornerRadius(10)
                }
            }
        }
    }
    
    private var exchangeButton: some View {
        Button(action: { Task { await vm.exchange() } }) {
            HStack {
                if vm.isExchanging {
                    ProgressView().tint(.white)
                } else {
                    Image(systemName: "arrow.right")
                    Text(vm.direction == .buyHSR ? String.localized("exchange.button.buy_hsr") : String.localized("exchange.button.sell_hsr"))
                }
            }
            .font(.headline)
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                vm.isValidAmount ?
                themeManager.theme.accent :
                themeManager.theme.textSecondary
            )
            .cornerRadius(16)
        }
        .disabled(!vm.isValidAmount || vm.isExchanging)
    }
}
