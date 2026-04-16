//
//  PriceAlertsViewModel.swift
//  Hissedar
//
//  Fiyat alarm sistemi için ViewModel.
//  Hem "Alarmlarım" listesi hem de mülk detaydan alarm oluşturma için kullanılır.
//

import Foundation
import Combine

@MainActor
final class PriceAlertsViewModel: ObservableObject {

    // MARK: - Liste State

    @Published var alerts: [PriceAlert] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    // MARK: - Form State (Alarm Oluşturma Sheet'i)

    @Published var isCreatingAlert = false
    @Published var formErrorMessage: String?
    @Published var successMessage: String?

    // Seçili koşul tipi (segmented control)
    @Published var selectedCondition: PriceAlertCondition = .below

    // Fiyat-hedef alanı (below/above için)
    @Published var targetPriceInput: String = ""

    // Yüzde alanı (percent_change için)
    @Published var percentInput: String = ""
    @Published var percentDirection: PercentDirection = .down

    // Davranış
    @Published var behavior: PriceAlertBehavior = .oneShot

    // MARK: - Yardımcı tip

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

    // MARK: - Deps

    private let supabase = SupabaseClient.shared

    // MARK: - Liste İşlemleri

    /// Tüm alarmları getir (Alarmlarım sayfası için)
    func loadAllAlerts(userId: String) async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            alerts = try await supabase.fetchPriceAlerts(userId: userId)
        } catch {
            errorMessage = "Alarmlar yüklenemedi: \(error.localizedDescription)"
        }
    }

    /// Belirli bir mülk için alarmları getir (PropertyDetailView için)
    func loadAlerts(userId: String, propertyId: String) async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            alerts = try await supabase.fetchPriceAlerts(
                userId: userId,
                propertyId: propertyId
            )
        } catch {
            errorMessage = "Alarmlar yüklenemedi: \(error.localizedDescription)"
        }
    }

    // MARK: - Alarm Oluştur

    /// Form state'ine göre alarm oluşturur.
    /// - Parameters:
    ///   - userId: Oturum açan kullanıcı
    ///   - propertyId: Alarm kurulacak mülk
    ///   - currentPrice: Mülkün şu anki token_price'ı (percent_change için base_price olarak kullanılır)
    /// - Returns: Başarılıysa true
    @discardableResult
    func createAlert(
        userId: String,
        propertyId: String,
        currentPrice: Decimal
    ) async -> Bool {
        formErrorMessage = nil
        successMessage = nil

        // Validasyon + request oluştur
        let request: CreatePriceAlertRequest
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
                propertyId: propertyId,
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
                propertyId: propertyId,
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
                propertyId: propertyId,
                percentDelta: signedPercent,
                basePrice: currentPrice,
                behavior: behavior
            )
        }

        // Network
        isCreatingAlert = true
        defer { isCreatingAlert = false }

        do {
            let newAlert = try await supabase.createPriceAlert(request)
            // Yeni alarmı listenin en başına koy
            alerts.insert(newAlert, at: 0)
            successMessage = "Alarm başarıyla oluşturuldu"
            resetForm()
            return true
        } catch {
            formErrorMessage = "Alarm oluşturulamadı: \(error.localizedDescription)"
            return false
        }
    }

    // MARK: - Aktif/Pasif Toggle

    func toggleActive(_ alert: PriceAlert) async {
        // Optimistic update — önce UI'da değiştir, sonra backend
        let newValue = !alert.isActive
        updateAlertLocally(id: alert.id, isActive: newValue)

        do {
            try await supabase.setPriceAlertActive(
                alertId: alert.id,
                isActive: newValue
            )
        } catch {
            // Hata olursa geri al
            updateAlertLocally(id: alert.id, isActive: alert.isActive)
            errorMessage = "Durum güncellenemedi: \(error.localizedDescription)"
        }
    }

    // MARK: - Sil

    func deleteAlert(_ alert: PriceAlert) async {
        // Optimistic remove
        let backup = alerts
        alerts.removeAll { $0.id == alert.id }

        do {
            try await supabase.deletePriceAlert(alertId: alert.id)
        } catch {
            alerts = backup
            errorMessage = "Alarm silinemedi: \(error.localizedDescription)"
        }
    }

    // MARK: - Form Yardımcıları

    /// Form state'ini sıfırla (sheet kapandığında veya başarılı create sonrası)
    func resetForm() {
        selectedCondition = .below
        targetPriceInput = ""
        percentInput = ""
        percentDirection = .down
        behavior = .oneShot
        formErrorMessage = nil
    }

    /// TR locale'e uygun decimal parse ("2.500,50" veya "2500.50" her ikisi de çalışır)
    private func parseDecimal(_ input: String) -> Decimal? {
        let trimmed = input.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return nil }

        // TR format: binlik . (nokta), ondalık , (virgül)
        // EN format: binlik , (virgül), ondalık . (nokta)
        // Basit yaklaşım: tüm . ve boşlukları kaldır, virgülü noktaya çevir
        let normalized = trimmed
            .replacingOccurrences(of: ".", with: "")
            .replacingOccurrences(of: " ", with: "")
            .replacingOccurrences(of: ",", with: ".")

        return Decimal(string: normalized)
    }

    private func updateAlertLocally(id: String, isActive: Bool) {
        guard let idx = alerts.firstIndex(where: { $0.id == id }) else { return }
        let old = alerts[idx]
        alerts[idx] = PriceAlert(
            id: old.id,
            userId: old.userId,
            propertyId: old.propertyId,
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

    // MARK: - Computed Helpers

    /// Aktif alarmların sayısı (Alarmlarım sayfasında header için)
    var activeCount: Int {
        alerts.filter { $0.isActive }.count
    }

    /// Mesaj'ları temizle (sheet kapanırken)
    func clearMessages() {
        errorMessage = nil
        formErrorMessage = nil
        successMessage = nil
    }
}