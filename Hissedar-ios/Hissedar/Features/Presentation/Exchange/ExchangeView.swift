//
//  ExchangeView.swift
//  Hissedar
//
//  Created by Sinan Dinç on 4/13/26.
//
//  TRY ↔ HSR dönüşüm ekranı.
//  Kullanıcı cüzdanındaki TRY bakiyesini HSR token'a çevirir (veya tam tersi).
//
import SwiftUI

struct ExchangeView: View {
    @State private var vm = ExchangeViewModel()
    @Environment(\.dismiss) private var dismiss
    
    // Klavye odağını kontrol eden değişken
    @FocusState private var isAmountFocused: Bool
    
    // Tasarım Renkleri
    let bgDark = Color(red: 0.05, green: 0.05, blue: 0.08)
    let cardBG = Color(red: 0.08, green: 0.08, blue: 0.12)
    
    var body: some View {
        NavigationStack{
            ZStack {
                Color.hsBackground.ignoresSafeArea()
                
                VStack(spacing: 0) {
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 10) {
                            // MARK: - Swap Cards
                            VStack(spacing: -12) {
                                swapInputCard(
                                    title: "SATIYORSUN",
                                    currency: vm.direction == .buyHSR ? "TRY" : "HSR",
                                    balance: vm.formattedAvailable,
                                    isSource: true
                                )
                                
                                swapToggleIcon
                                
                                swapInputCard(
                                    title: "ALIYORSUN",
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
                    
                    VStack{
                        quickAmountButtons
                        exchangeButton
                    }
                    .padding()
                }
            }
            .navigationTitle("Swap")
            .task { await vm.load() }
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
                        .fill(currency == "TRY" ? Color.orange : Color.purple)
                        .frame(width: 28, height: 28)
                        .overlay(Text(currency == "TRY" ? "₺" : "H").font(.system(size: 12, weight: .bold)).foregroundColor(.white))
                    Text(currency).font(.system(size: 16, weight: .bold)).foregroundColor(.white)
                    Image(systemName: "chevron.down").font(.system(size: 10, weight: .bold)).foregroundColor(.gray)
                }
                .padding(.horizontal, 10).padding(.vertical, 6)
                .background(Color.white.opacity(0.08)).cornerRadius(20)
                
                Spacer()
                
                if isSource {
                    TextField("0", text: $vm.amountText)
                        .font(.system(size: 32, weight: .medium))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.trailing)
                        .keyboardType(.decimalPad)
                        .focused($isAmountFocused)
                } else {
                    Text(vm.formattedOutput.isEmpty ? "0.00" : vm.formattedOutput)
                        .font(.system(size: 32, weight: .medium))
                        .foregroundColor(.white.opacity(0.4))
                        .lineLimit(1)
                }
            }
            
            HStack {
                Text("Bakiye: \(balance)")
                Spacer()
                Text("≈ $0.00")
            }
            .font(.system(size: 11))
            .foregroundColor(.gray)
        }
        .padding(15)
        .background(Color.hsBackgroundSecondary)
        .cornerRadius(20)
        .overlay(
            RoundedRectangle(cornerRadius: 25)
                .stroke(Color.hsBackgroundTertiary, lineWidth: 1)
        )
    }
    
    private var swapToggleIcon: some View {
        Button(action: { withAnimation(.spring()) { vm.toggleDirection() } }) {
            Image(systemName: "arrow.up.arrow.down")
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(.white)
                .padding(12)
                .background(Color.hsBackground)
                .clipShape(Circle())
                .overlay(Circle().stroke(Color.hsBackground, lineWidth: 4))
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
            Text("%\(vm.feePercent) komisyon")
        }
        .foregroundColor(.gray)
        .padding(.horizontal, 12)
        .font(.system(size: 11,weight: .medium))
    }
    
    private var quickAmountButtons: some View {
        HStack(spacing: 10) {
            ForEach(["%25", "%50", "%75", "Tümü"], id: \.self) { label in
                Button(action: { /* Yüzde hesaplama */ }) {
                    Text(label)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.white.opacity(0.8))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(Color.white.opacity(0.05))
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
                    Text(vm.direction == .buyHSR ? "HSR Satın Al" : "HSR Sat")
                }
            }
            .font(.headline)
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(vm.isValidAmount ? Color.hsPurple600 : Color.gray.opacity(0.2))
            .cornerRadius(16)
        }
        .disabled(!vm.isValidAmount || vm.isExchanging)
    }
}
