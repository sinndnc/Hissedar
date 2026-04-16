//
//  PriceAlertsViewModel.swift
//  Hissedar
//
//  Fiyat alarm sistemi için ViewModel.
//  Factory @Injected ile PriceAlertsService kullanır.
//

import Foundation
import Factory
import Combine

@MainActor
final class PriceAlertsViewModel: ObservableObject {

    // MARK: - Liste State

    @Published var alerts: [AssetPriceAlert] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    // MARK: - Form State

    @Published var isCreatingAlert = false
    @Published var formErrorMessage: String?
    @Published var successMessage: String?

    @Published var selectedCondition: PriceAlertCondition = .below
    @Published var targetPriceInput: String = ""
    @Published var percentInput: String = ""
    @Published var percentDirection: PercentDirection = .down
    @Published var behavior: PriceAlertBehavior = .oneShot

    // MARK: - Yardımcı

    enum PercentDirection: String, CaseIterable, Identifiable {
        case up, down
        var id: String { rawValue }
        var displayName: String {
            switch self {
            case .up:   return "Artarsa"
            case .down: return "Düşerse"
            }
        }
        var sign: Decimal {
            switch self {
            case .up:   return 1
            case .down: return -1
            }
        }
    }

    // MARK: - DI

    @Injected(\.priceAlertsService) private var service

    // MARK: - Liste İşlemleri

    func loadAllAlerts(userId: String) async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            alerts = try await service.fetchAlerts(userId: userId)
        } catch {
            errorMessage = "Alarmlar yüklenemedi: \(error.localizedDescription)"
        }
    }

    func loadAlerts(userId: String, assetId: String, assetType: AssetType) async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            alerts = try await service.fetchAlerts(
                userId: userId,
                assetId: assetId,
                assetType: assetType
            )
        } catch {
            errorMessage = "Alarmlar yüklenemedi: \(error.localizedDescription)"
        }
    }

    // MARK: - Alarm Oluştur

    @discardableResult
    func createAlert(
        userId: String,
        assetId: String,
        assetType: AssetType,
        currentPrice: Decimal
    ) async -> Bool {
        formErrorMessage = nil
        successMessage = nil

        let request: CreateAssetPriceAlertRequest
        switch selectedCondition {
        case .below:
            guard let target = parseDecimal(targetPriceInput), target > 0 else {
                formErrorMessage = "Geçerli bir hedef fiyat girin"
                return false
            }
            guard target < currentPrice else {
                formErrorMessage = "Hedef fiyat, mevcut fiyattan (\(currentPrice.tlFormatted)) düşük olmalı"
                return false
            }
            request = .below(
                userId: userId,
                assetId: assetId,
                assetType: assetType,
                targetPrice: target,
                behavior: behavior
            )

        case .above:
            guard let target = parseDecimal(targetPriceInput), target > 0 else {
                formErrorMessage = "Geçerli bir hedef fiyat girin"
                return false
            }
            guard target > currentPrice else {
                formErrorMessage = "Hedef fiyat, mevcut fiyattan (\(currentPrice.tlFormatted)) yüksek olmalı"
                return false
            }
            request = .above(
                userId: userId,
                assetId: assetId,
                assetType: assetType,
                targetPrice: target,
                behavior: behavior
            )

        case .percentChange:
            guard let percent = parseDecimal(percentInput), percent > 0 else {
                formErrorMessage = "Geçerli bir yüzde değeri girin"
                return false
            }
            let signedPercent = percent * percentDirection.sign
            request = .percentChange(
                userId: userId,
                assetId: assetId,
                assetType: assetType,
                percentDelta: signedPercent,
                basePrice: currentPrice,
                behavior: behavior
            )
        }

        isCreatingAlert = true
        defer { isCreatingAlert = false }

        do {
            let newAlert = try await service.createAlert(request)
            alerts.insert(newAlert, at: 0)
            successMessage = "Alarm başarıyla oluşturuldu"
            resetForm()
            return true
        } catch {
            formErrorMessage = "Alarm oluşturulamadı: \(error.localizedDescription)"
            return false
        }
    }

    // MARK: - Toggle / Delete (Optimistic)

    func toggleActive(_ alert: AssetPriceAlert) async {
        let newValue = !alert.isActive
        updateAlertLocally(id: alert.id, isActive: newValue)

        do {
            try await service.setAlertActive(alertId: alert.id, isActive: newValue)
        } catch {
            updateAlertLocally(id: alert.id, isActive: alert.isActive)
            errorMessage = "Durum güncellenemedi: \(error.localizedDescription)"
        }
    }

    func deleteAlert(_ alert: AssetPriceAlert) async {
        let backup = alerts
        alerts.removeAll { $0.id == alert.id }

        do {
            try await service.deleteAlert(alertId: alert.id)
        } catch {
            alerts = backup
            errorMessage = "Alarm silinemedi: \(error.localizedDescription)"
        }
    }

    // MARK: - Form Yardımcıları

    func resetForm() {
        selectedCondition = .below
        targetPriceInput = ""
        percentInput = ""
        percentDirection = .down
        behavior = .oneShot
        formErrorMessage = nil
    }

    private func parseDecimal(_ input: String) -> Decimal? {
        let trimmed = input.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return nil }

        let normalized = trimmed
            .replacingOccurrences(of: ".", with: "")
            .replacingOccurrences(of: " ", with: "")
            .replacingOccurrences(of: ",", with: ".")

        return Decimal(string: normalized)
    }

    private func updateAlertLocally(id: String, isActive: Bool) {
        guard let idx = alerts.firstIndex(where: { $0.id == id }) else { return }
        let old = alerts[idx]
        alerts[idx] = AssetPriceAlert(
            id: old.id,
            userId: old.userId,
            assetId: old.assetId,
            assetType: old.assetType,
            conditionType: old.conditionType,
            targetPrice: old.targetPrice,
            percentDelta: old.percentDelta,
            basePrice: old.basePrice,
            behavior: old.behavior,
            isActive: isActive,
            lastTriggeredAt: old.lastTriggeredAt,
            triggerCount: old.triggerCount,
            createdAt: old.createdAt,
            updatedAt: Date()
        )
    }

    // MARK: - Computed

    var activeCount: Int {
        alerts.filter { $0.isActive }.count
    }

    func clearMessages() {
        errorMessage = nil
        formErrorMessage = nil
        successMessage = nil
    }
}
