//
//  PriceAlertsListView.swift
//  Hissedar
//
//  Kullanıcının tüm fiyat alarmlarını listeleyen ekran.
//  Profil/Ayarlar sayfasından NavigationLink ile açılır.
//

import SwiftUI
import Factory
import Combine

struct PriceAlertsListView: View {

    @StateObject private var vm = PriceAlertsViewModel()
    @State private var assetTitles: [String: String] = [:]  // "type:id" -> title

    @Injected(\.authRepository) private var authVM
    @Injected(\.marketViewModel) private var marketVM

    var body: some View {
        Group {
            if vm.isLoading && vm.alerts.isEmpty {
                loadingView
            } else if vm.alerts.isEmpty {
                emptyView
            } else {
                alertsList
            }
        }
        .navigationTitle("Alarmlarım")
        .navigationBarTitleDisplayMode(.inline)
        .background(Color.hsBackground)
        .task { await load() }
        .refreshable { await load() }
        .alert("Hata", isPresented: .constant(vm.errorMessage != nil)) {
            Button("Tamam") { vm.clearMessages() }
        } message: {
            Text(vm.errorMessage ?? "")
        }
    }

    // MARK: - Alerts list

    private var alertsList: some View {
        ScrollView {
            LazyVStack(spacing: 10) {
                headerSummary
                    .padding(.horizontal, 16)
                    .padding(.top, 12)

                ForEach(vm.alerts) { alert in
                    PriceAlertRowView(
                        alert: alert,
                        assetTitle: titleFor(alert),
                        onToggle: {
                            Task { await vm.toggleActive(alert) }
                        }
                    )
                    .padding(.horizontal, 16)
                    .swipeActions {
                        Button(role: .destructive) {
                            Task { await vm.deleteAlert(alert) }
                        } label: {
                            Label("Sil", systemImage: "trash")
                        }
                    }
                    .contextMenu {
                        Button(role: .destructive) {
                            Task { await vm.deleteAlert(alert) }
                        } label: {
                            Label("Sil", systemImage: "trash")
                        }
                    }
                }

                Text("Pasif alarmlar tetiklenmez. Silmek için sağa kaydırın veya basılı tutun.")
                    .font(.system(size: 11))
                    .foregroundStyle(Color.hsTextSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)
                    .padding(.top, 8)
                    .padding(.bottom, 32)
            }
        }
    }

    private var headerSummary: some View {
        HStack(spacing: 12) {
            statCard(count: vm.activeCount, label: "Aktif", color: Color.hsSuccess)
            statCard(count: vm.alerts.count - vm.activeCount, label: "Pasif", color: Color.hsTextSecondary)
            statCard(count: vm.alerts.count, label: "Toplam", color: Color.hsPurple400)
        }
    }

    private func statCard(count: Int, label: String, color: Color) -> some View {
        VStack(spacing: 4) {
            Text("\(count)")
                .font(.system(size: 22, weight: .bold, design: .monospaced))
                .foregroundStyle(color)
            Text(label)
                .font(.system(size: 11, weight: .medium))
                .foregroundStyle(Color.hsTextSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(Color.hsBackgroundSecondary)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .strokeBorder(Color.hsBorder, lineWidth: 0.5)
        )
    }

    // MARK: - Loading

    private var loadingView: some View {
        VStack(spacing: 14) {
            ProgressView().tint(Color.hsPurple400).scaleEffect(1.3)
            Text("Yükleniyor...")
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(Color.hsTextSecondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // MARK: - Empty

    private var emptyView: some View {
        VStack(spacing: 14) {
            Image(systemName: "bell.slash")
                .font(.system(size: 44, weight: .light))
                .foregroundStyle(Color.hsTextSecondary.opacity(0.4))

            Text("Henüz alarm kurmadınız")
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(Color.hsTextPrimary)

            Text("Bir varlık detay sayfasında zil ikonuna dokunarak fiyat alarmı oluşturabilirsiniz.")
                .font(.system(size: 13))
                .foregroundStyle(Color.hsTextSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // MARK: - Load

    private func load() async {
        guard let userId = authVM.currentUserId else { return }
        await vm.loadAllAlerts(userId: userId)
        await loadAssetTitles()
    }

    /// Alarmlarda geçen asset'lerin title'larını market VM üzerinden cache'le.
    /// (Her alarm için tek tek detail fetch etmek verimsiz olur.)
    private func loadAssetTitles() async {
        // marketViewModel'deki mevcut asset cache/list'i kullan
        // Eğer marketVM'de `allAssets: [AssetItem]` benzeri bir property varsa oradan al.
        // Yoksa her unique asset için fetchDetail yapmak zorunda kalırız.
        //
        // NOT: Bu kısmı kendi marketViewModel API'na göre adapte et.
        // Aşağıdaki örnek: marketVM.allAssets şeklinde bir [AssetItem] property'si varsayar.

        for alert in vm.alerts {
            let key = "\(alert.assetType.rawValue):\(alert.assetId)"
            guard assetTitles[key] == nil else { continue }

            // Örnek: eğer marketVM'den direkt alabiliyorsan
            // if let item = marketVM.allAssets.first(where: { $0.id == alert.assetId }) {
            //     assetTitles[key] = item.title
            //     continue
            // }

            // Fallback: detail fetch et (tekil)
            do {
                await marketVM.fetchDetail(id: alert.assetId)
                if let detail = marketVM.selectedDetail, detail.id == alert.assetId {
                    assetTitles[key] = detail.title
                }
            } catch {
                // Sessiz fallback
            }
        }
    }

    private func titleFor(_ alert: AssetPriceAlert) -> String {
        let key = "\(alert.assetType.rawValue):\(alert.assetId)"
        return assetTitles[key] ?? alert.assetType.label
    }
}
