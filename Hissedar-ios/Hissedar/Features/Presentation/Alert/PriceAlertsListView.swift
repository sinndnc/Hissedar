//
//  PriceAlertsListView.swift
//  Hissedar
//
//  Kullanıcının tüm fiyat alarmlarını listeleyen ekran.
//

import SwiftUI
import Factory
import Combine

struct PriceAlertsListView: View {

    @StateObject private var vm = PriceAlertsViewModel()
    @State private var assetTitles: [String: String] = [:]
    @Environment(ThemeManager.self) private var themeManager
    
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
        .navigationBarTitleDisplayMode(.inline)
        .background(themeManager.theme.background)
        .navigationTitle(String.localized("profile.alert.title"))
        .task { await load() }
        .refreshable { await load() }
        .alert(String.localized("common.error"), isPresented: .constant(vm.errorMessage != nil)) {
            Button(String.localized("common.ok")) { vm.clearMessages() }
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
                    .swipeActions(edge: .trailing) {
                        Button(role: .destructive) {
                            Task { await vm.deleteAlert(alert) }
                        } label: {
                            Label(String.localized("common.delete"), systemImage: "trash")
                        }
                    }
                    .contextMenu {
                        Button(role: .destructive) {
                            Task { await vm.deleteAlert(alert) }
                        } label: {
                            Label(String.localized("common.delete"), systemImage: "trash")
                        }
                    }
                }

                Text(String.localized("profile.alert.footer_hint"))
                    .font(.system(size: 11))
                    .foregroundStyle(themeManager.theme.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)
                    .padding(.top, 8)
                    .padding(.bottom, 32)
            }
        }
    }

    private var headerSummary: some View {
        HStack(spacing: 12) {
            statCard(count: vm.activeCount, label: String.localized("profile.alert.status.active"), color: Color.hsSuccess)
            statCard(count: vm.alerts.count - vm.activeCount, label: String.localized("profile.alert.status.passive"), color: Color.hsTextSecondary)
            statCard(count: vm.alerts.count, label: String.localized("profile.alert.status.total"), color: Color.hsPurple400)
        }
    }

    private func statCard(count: Int, label: String, color: Color) -> some View {
        VStack(spacing: 4) {
            Text("\(count)")
                .font(.system(size: 22, weight: .bold, design: .monospaced))
                .foregroundStyle(color)
            Text(label)
                .font(.system(size: 11, weight: .medium))
                .foregroundStyle(themeManager.theme.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(themeManager.theme.backgroundSecondary)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .strokeBorder(themeManager.theme.border, lineWidth: 0.5)
        )
    }

    // MARK: - Loading

    private var loadingView: some View {
        VStack(spacing: 14) {
            ProgressView().tint(themeManager.theme.accent).scaleEffect(1.3)
            Text(String.localized("common.loading"))
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(themeManager.theme.textSecondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // MARK: - Empty

    private var emptyView: some View {
        VStack(spacing: 14) {
            Image(systemName: "bell.slash")
                .font(.system(size: 44, weight: .light))
                .foregroundStyle(themeManager.theme.textSecondary.opacity(0.4))

            Text(String.localized("profile.alert.empty_title"))
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(themeManager.theme.textPrimary)

            Text(String.localized("profile.alert.empty_desc"))
                .font(.system(size: 13))
                .foregroundStyle(themeManager.theme.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // MARK: - Data Loading Logic

    private func load() async {
        guard let userId = await authVM.currentUserId else { return }
        await vm.loadAllAlerts(userId: userId)
        await loadAssetTitles()
    }

    private func loadAssetTitles() async {
        for alert in vm.alerts {
            let key = "\(alert.assetType.rawValue):\(alert.assetId)"
            guard assetTitles[key] == nil else { continue }

            do {
                await marketVM.fetchDetail(id: alert.assetId)
                if let detail = marketVM.selectedDetail, detail.id == alert.assetId {
                    // UI güncellenmesi için MainActor'da setlemesi daha sağlıklı olabilir
                    await MainActor.run {
                        assetTitles[key] = detail.title
                    }
                }
            } catch {
                // Fallback hatası sessizce geçilir
            }
        }
    }

    private func titleFor(_ alert: AssetPriceAlert) -> String {
        let key = "\(alert.assetType.rawValue):\(alert.assetId)"
        return assetTitles[key] ?? alert.assetType.label
    }
}
