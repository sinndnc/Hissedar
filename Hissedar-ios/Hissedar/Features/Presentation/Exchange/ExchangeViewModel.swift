//
//  ExchangeViewModel.swift
//  Hissedar
//
//  Created by Sinan Dinç on 4/13/26.
//
//  TRY ↔ HSR dönüşüm ekranının ViewModel'i.
//  ExchangeRepository üzerinden buy_hsr / sell_hsr RPC çağrıları yapar.
//

import SwiftUI
import Factory

@MainActor
@Observable
final class ExchangeViewModel {

    // MARK: - Dependencies

    private let exchangeRepo = Container.shared.exchangeRepository()
    private let portfolioRepo = Container.shared.portfolioRepository()
    private let authService = Container.shared.authService()

    // MARK: - State

    var wallet: Wallet?
    var direction: ExchangeDirection = .buyHSR
    var amountText: String = ""
    var feePercent: Decimal = 1.0          // %1 komisyon (platform_config'den çekilebilir)

    var isLoading = false
    var isExchanging = false
    var error: String?
    var lastResult: ExchangeResult?
    var showSuccess = false

    var exchangeHistory: [TokenExchange] = []
    var isLoadingHistory = false

    // MARK: - Computed — Girdi

    var inputAmount: Decimal {
        Decimal(string: amountText.replacingOccurrences(of: ",", with: ".")) ?? 0
    }

    var isValidAmount: Bool {
        inputAmount > 0 && inputAmount <= availableBalance
    }

    /// Hangi yöne dönüşüm yapıyorsa, o tarafın bakiyesi
    var availableBalance: Decimal {
        switch direction {
        case .buyHSR:  wallet?.availableTRY ?? 0
        case .sellHSR: wallet?.availableHSR ?? 0
        }
    }

    var formattedAvailable: String {
        switch direction {
        case .buyHSR:  wallet?.formattedAvailableTRY ?? "₺0"
        case .sellHSR: wallet?.formattedAvailableHSR ?? "0 HSR"
        }
    }

    var sourceCurrencyLabel: String {
        direction == .buyHSR ? "TRY" : "HSR"
    }

    var targetCurrencyLabel: String {
        direction == .buyHSR ? "HSR" : "TRY"
    }

    // MARK: - Computed — Hesaplama

    var fee: Decimal {
        inputAmount * (feePercent / 100)
    }

    var netAmount: Decimal {
        inputAmount - fee
    }

    /// Phase 1: 1:1 kur. İleride dinamik olabilir.
    var exchangeRate: Decimal { 1.0 }

    var outputAmount: Decimal {
        netAmount / exchangeRate
    }

    var formattedFee: String {
        CurrencyFormatter.format(fee, currency: .TRY)
    }

    var formattedOutput: String {
        switch direction {
        case .buyHSR:
            return "\(CurrencyFormatter.formatValue(outputAmount, currency: .TRY)) HSR"
        case .sellHSR:
            return CurrencyFormatter.format(outputAmount, currency: .TRY)
        }
    }

    var formattedRate: String {
        "1 HSR = \(CurrencyFormatter.format(exchangeRate, currency: .TRY))"
    }

    // MARK: - Quick Amounts

    var quickAmounts: [Decimal] {
        let balance = availableBalance
        guard balance > 0 else { return [] }

        // %25, %50, %75, %100
        return [0.25, 0.50, 0.75, 1.0].map { ratio in
            (balance * ratio).rounded(0, .down)
        }.filter { $0 > 0 }
    }

    func quickAmountLabel(_ amount: Decimal) -> String {
        let ratio = availableBalance > 0 ? amount / availableBalance : 0
        if ratio >= 1.0 { return "Tümü" }
        return "%\(Int(Double(truncating: ratio as NSDecimalNumber) * 100))"
    }

    // MARK: - Actions

    func load() async {
        guard let userId = await authService.currentUserId else { return }
        isLoading = true
        error = nil
        defer { isLoading = false }

        do {
            wallet = try await portfolioRepo.getWallet(userId: userId)
        } catch {
            self.error = "Cüzdan yüklenemedi: \(error.localizedDescription)"
        }
    }

    func loadHistory() async {
        guard let userId = await authService.currentUserId else { return }
        isLoadingHistory = true
        defer { isLoadingHistory = false }

        do {
            exchangeHistory = try await exchangeRepo.fetchExchangeHistory(userId: userId)
        } catch {
            print("Exchange history error: \(error)")
        }
    }

    func toggleDirection() {
        direction = (direction == .buyHSR) ? .sellHSR : .buyHSR
        amountText = ""
        lastResult = nil
        error = nil
    }

    func setAmount(_ amount: Decimal) {
        amountText = "\(amount)"
    }

    func exchange() async {
        guard isValidAmount else { return }
        guard let userId = await authService.currentUserId else {
            error = "Oturum bulunamadı"
            return
        }

        isExchanging = true
        error = nil
        defer { isExchanging = false }

        do {
            let result: ExchangeResult

            switch direction {
            case .buyHSR:
                result = try await exchangeRepo.buyHSR(
                    userId: userId,
                    tryAmount: inputAmount,
                    feePercent: feePercent
                )
            case .sellHSR:
                result = try await exchangeRepo.sellHSR(
                    userId: userId,
                    hsrAmount: inputAmount,
                    feePercent: feePercent
                )
            }

            guard result.success else {
                error = "İşlem başarısız oldu"
                return
            }

            lastResult = result

            // Wallet bakiyelerini güncelle (yeni bakiyeler response'dan geliyor)
            if var w = wallet {
                // Wallet struct immutable, yeniden fetch et
                await load()
            }

            showSuccess = true
            amountText = ""

            // Geçmişi de yenile
            await loadHistory()

        } catch {
            self.error = parseError(error)
        }
    }

    // MARK: - Error Parsing

    private func parseError(_ error: Error) -> String {
        let msg = error.localizedDescription
        if msg.contains("Yetersiz TRY") {
            return "Yetersiz TRY bakiye"
        } else if msg.contains("Yetersiz HSR") {
            return "Yetersiz HSR bakiye"
        } else if msg.contains("Geçersiz miktar") {
            return "Geçersiz miktar girdiniz"
        } else if msg.contains("Cüzdan bulunamadı") {
            return "Cüzdan bulunamadı. Lütfen tekrar deneyin."
        }
        return "Bir hata oluştu: \(msg)"
    }
}

// MARK: - Decimal Rounding Helper

private extension Decimal {
    func rounded(_ scale: Int, _ mode: NSDecimalNumber.RoundingMode) -> Decimal {
        var value = self
        var result = Decimal()
        NSDecimalRound(&result, &value, scale, mode)
        return result
    }
}
