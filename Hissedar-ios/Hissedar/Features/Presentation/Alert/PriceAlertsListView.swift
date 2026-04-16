//
//  PriceAlertsListView.swift
//  Hissedar
//
//  Kullanıcının tüm fiyat alarmlarını listeleyen ekran.
//  Profil/Ayarlar sayfasından link ile açılır.
//

import SwiftUI

struct PriceAlertsListView: View {

    @StateObject private var vm = PriceAlertsViewModel()
    @State private var propertyTitles: [String: String] = [:]  // propertyId -> title

    var body: some View {
        Group {
            if vm.isLoading && vm.alerts.isEmpty {
                ProgressView("Yükleniyor...")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if vm.alerts.isEmpty {
                emptyState
            } else {
                alertsList
            }
        }
        .navigationTitle("Alarmlarım")
        .navigationBarTitleDisplayMode(.inline)
        .task { await load() }
        .refreshable { await load() }
        .alert("Hata", isPresented: .constant(vm.errorMessage != nil)) {
            Button("Tamam") { vm.clearMessages() }
        } message: {
            Text(vm.errorMessage ?? "")
        }
    }

    // MARK: - Liste

    private var alertsList: some View {
        List {
            Section {
                ForEach(vm.alerts) { alert in
                    PriceAlertRowView(
                        alert: alert,
                        propertyTitle: propertyTitles[alert.propertyId] ?? "Mülk",
                        onToggle: {
                            Task { await vm.toggleActive(alert) }
                        },
                        onDelete: {
                            Task { await vm.deleteAlert(alert) }
                        }
                    )
                }
            } header: {
                HStack {
                    Text("\(vm.activeCount) aktif")
                    Spacer()
                    Text("\(vm.alerts.count) toplam")
                }
                .font(.caption)
                .foregroundStyle(.secondary)
            } footer: {
                Text("Alarmı silmek için satırı sola kaydırın. Pasif alarmlar tetiklenmez.")
                    .font(.caption)
            }
        }
        .listStyle(.insetGrouped)
    }

    // MARK: - Boş durum

    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "bell.slash")
                .font(.system(size: 48))
                .foregroundStyle(.secondary)

            Text("Henüz alarm kurmadınız")
                .font(.headline)

            Text("Bir mülk detayında 'Fiyat Alarmı Kur' butonuna dokunarak alarm oluşturabilirsiniz.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // MARK: - Load

    private func load() async {
        guard let userId = AppState.shared.currentUser?.id else { return }
        await vm.loadAllAlerts(userId: userId)
        await loadPropertyTitles()
    }

    /// Alarmlarda geçen mülklerin title'larını getirir (listede göstermek için).
    private func loadPropertyTitles() async {
        let uniqueIds = Set(vm.alerts.map { $0.propertyId })
        let missingIds = uniqueIds.filter { propertyTitles[$0] == nil }
        guard !missingIds.isEmpty else { return }

        // NOT: Burada mevcut SupabaseClient.fetchProperties() metodunu kullanıyoruz.
        // Eğer bulk-fetch-by-ids yöntemin varsa onu kullanmak daha verimli olur.
        do {
            let allProperties = try await SupabaseClient.shared.fetchProperties(status: "active")
            for property in allProperties {
                propertyTitles[property.id] = property.title
            }
        } catch {
            // Title yüklenemezse "Mülk" fallback'i gösterilir, UX bozulmaz
        }
    }
}